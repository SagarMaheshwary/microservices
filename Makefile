DOCKER_REGISTRY=localhost:8009
VERSION=1.0
PROJECT_ROOT=.
NS_MICROSERVICES=microservices
NS_DATASTORES=datastores
KIND_CLUSTER_NAME=kind-kind

MICROSERVICES= \
    api-gateway \
    authentication-service \
    user-service \
    upload-service \
    encode-service \
    video-catalog-service

DATASTORES= \
    user-db \
    video-catalog-db \
    redis \
    rabbitmq

.PHONY: help clone copy-env-files docker-compose-build docker-compose-up docker-compose-up-detached docker-db-migrate kind-build-images kind-push-images kind-create-cluster kind-delete-cluster kind-deploy-all kind-delete-all

# Utility for colored output
define PRINT_COLOR
\033[1;32m$(1)\033[0m
endef

help:
	@printf "$(call PRINT_COLOR, Available commands:\n)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "} {printf "%-30s %s\n", $$1, $$2}'

clone: ## Clone all microservices from GitHub
	@printf "$(call PRINT_COLOR, Cloning microservices from GitHub\n)"
	@for service in  $(MICROSERVICES); do \
	  git clone https://github.com/SagarMaheshwary/microservices-$$service || true; \
	done

copy-env-files: ## Create .env for Docker setup for each microservice
	@printf "$(call PRINT_COLOR, Creating Docker .env files for each microservice\n)"
	@for service in  $(MICROSERVICES); do \
	  cp ./microservices-$$service/.env.docker-example ./microservices-$$service/.env || true; \
	done

docker-compose-build: ## Build Docker images
	@printf "$(call PRINT_COLOR, Building Docker container images\n)"
	@docker compose pull
	@docker compose build

docker-compose-up: ## Start Docker containers
	@printf "$(call PRINT_COLOR, Starting Docker containers\n)"
	@printf "$(call PRINT_COLOR, Note: Some containers run in detached mode. Check the docker-compose.yml file for services with 'attach: false'\n)"
	@docker compose up

docker-compose-up-detached: ## Start Docker containers in detached mode
	@printf "$(call PRINT_COLOR, Starting Docker containers in detached mode\n)"
	@docker compose up -d

docker-compose-down: ## Remove Docker containers
	@printf "$(call PRINT_COLOR, Removing all running containers\n)"
	@docker compose down

docker-delete-images:
	@printf "$(call PRINT_COLOR, Deleting all images and build cache\n)"
	@docker rmi $$(docker images --filter=reference="microservices*" -q) -f
	@docker rmi -f \
		postgres:14 \
		redis:7.2 \
		rabbitmq:3.12-management \
		dpage/pgadmin4:8.13.0 \
		grafana/grafana-enterprise:11.3.0 \
		prom/prometheus:v2.55.0 \
		grafana/loki:2.7.0 \
		kbudde/rabbitmq-exporter:1.0.0 \
		prometheuscommunity/postgres-exporter:v0.16.0 \
		oliver006/redis_exporter:v1.67.0
	@docker builder prune -f
	@docker image prune -f

docker-db-migrate: ## Run db migrates for services
	@printf "$(call PRINT_COLOR, Running migrations for user service\n)"
	@docker exec microservices-user-service npm run migration:run

kind-push-service-image:
	@printf "$(call PRINT_COLOR, Pushing $(SERVICE) image\n)"
	@docker push $(DOCKER_REGISTRY)/$(notdir $(SERVICE)):$(VERSION)

kind-create-cluster: ## Create Kubernetes kind cluster
	@printf "$(call PRINT_COLOR, Creating kind cluster\n)"
	@kind create cluster --config=./kubernetes/kind-config.yaml

	$(MAKE) kind-create-namespace
	$(MAKE) kind-deploy-metrics-server
	$(MAKE) kind-start-docker-registry

	@kubectl config set-context $(KIND_CLUSTER_NAME) --namespace=$(NS_MICROSERVICES)

kind-start-docker-registry: ## Start docker registry container for service images
	@docker run -d --rm --name kind-registry --net kind -p 8009:5000  registry:2 || true

kind-deploy-metrics-server: ## Install metrics api so we can see resource usage for pods etc
	@kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

	# This is useful when running Kubernetes in environments where the kubelet does not have a valid TLS certificate.
	@printf "$(call PRINT_COLOR, Patch the metrics-server deployment to allow insecure TLS connections to the kubelet.\n)"
	@kubectl patch deployment metrics-server \
	   --namespace kube-system \
	   --type='json' \
	   -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

	@printf "$(call PRINT_COLOR, Waiting for metrics server to be ready...\n)"
	@kubectl wait --namespace kube-system \
       --for=condition=Ready pod \
       --field-selector=status.phase=Running \
       --timeout=360s

kind-delete-cluster: ## Delete Kubernetes kind cluster
	@printf "$(call PRINT_COLOR, Deleting kind cluster\n)"
	@kind delete cluster
	@docker stop kind-registry

kind-create-namespace: ## Create Kubernetes namespaces
	@printf "$(call PRINT_COLOR, Creating Kubernetes namespaces\n)"
	@kubectl apply -f kubernetes/namespace.yaml

kind-build-images: ## Start building docker images for kubernetes
	@printf "$(call PRINT_COLOR, Building docker images for kind cluster\n)"
	@for service in  $(MICROSERVICES); do \
		$(MAKE) kind-build-service-image SERVICE=$$service; \
	done

kind-push-images: ## Push docker images to local registry
	@printf "$(call PRINT_COLOR, Pushing docker images to local registry: $(DOCKER_REGISTRY)\n)"
	@for service in  $(MICROSERVICES); do \
		$(MAKE) kind-push-service-image SERVICE=$$service; \
	done

kind-build-service-image:
	@printf "$(call PRINT_COLOR, Building $(SERVICE) image\n)"
	cd $(PROJECT_ROOT)/microservices-$(SERVICE) \
	   && docker build --target production --build-arg MODE=production -t microservices/$(notdir $(SERVICE)):$(VERSION) . \
	   && docker image tag $$(docker images -q microservices/$(notdir $(SERVICE)):$(VERSION)) $(DOCKER_REGISTRY)/$(notdir $(SERVICE)):$(VERSION)

kind-deploy-services: ## Deploy all services to Kubernetes
	@printf "$(call PRINT_COLOR, Deploying all microservices\n)"

	@for service in $(MICROSERVICES); do \
		printf "$(call PRINT_COLOR, Deploying $$service\n)"; \
	  	kubectl apply -f ./kubernetes/microservices/$$service/ConfigMap.yaml || true; \
		kubectl apply -f ./kubernetes/microservices/$$service/Secret.yaml || true; \
		kubectl apply -f ./kubernetes/microservices/$$service/Service.yaml || true; \
		kubectl apply -f ./kubernetes/microservices/$$service/Deployment.yaml || true; \
	done

	@kubectl apply -f ./kubernetes/microservices/api-gateway/Ingress.yaml

	@for datastore in $(DATASTORES); do \
		printf "$(call PRINT_COLOR, Deploying $$datastore\n)"; \
		kubectl apply -f ./kubernetes/datastores/$$datastore/ConfigMap.yaml || true; \
		kubectl apply -f ./kubernetes/datastores/$$datastore/Secret.yaml || true; \
		kubectl apply -f ./kubernetes/datastores/$$datastore/HeadlessService.yaml || true; \
		kubectl apply -f ./kubernetes/datastores/$$datastore/StatefulSet.yaml || true; \
	done

kind-delete-services: ## Delete all services from Kubernetes
	@printf "$(call PRINT_COLOR, Deleting all services\n)"

	@for service in $(MICROSERVICES); do \
		printf "$(call PRINT_COLOR, Deleting $$service\n)"; \
	  	kubectl delete cm $$service --namespace=$(NS_MICROSERVICES) || true; \
		kubectl delete secrets $$service --namespace=$(NS_MICROSERVICES) || true; \
		kubectl delete svc $$service --namespace=$(NS_MICROSERVICES) || true; \
		kubectl delete deploy $$service --namespace=$(NS_MICROSERVICES) || true; \
	done

	@kubectl delete ingress api-gateway || true

	@for datastore in $(DATASTORES); do \
		printf "$(call PRINT_COLOR, Deleting $$datastore\n)"; \
	  	kubectl delete cm $$datastore --namespace=$(NS_DATASTORES) || true; \
		kubectl delete secrets $$datastore --namespace=$(NS_DATASTORES) || true; \
		kubectl delete svc $$datastore --namespace=$(NS_DATASTORES) || true; \
		kubectl delete sts $$datastore --namespace=$(NS_DATASTORES) || true; \
	done

kind-deploy-nginx-ingress: ## Deploy NGINX ingress controller
	@printf "$(call PRINT_COLOR, Deploying NGINX Ingress Controller\n)"
	@kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

	@kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \

	@printf "$(call PRINT_COLOR, Run \"cloud-provider-kind\" in another terminal to get External IP\n)"

	@printf "$(call PRINT_COLOR, Waiting for External IP...\n)"
	@until kubectl get svc -n ingress-nginx ingress-nginx-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'; do \
	    sleep 5; \
	done

	@printf "$(call PRINT_COLOR, NGINX Ingress is available at: http://$$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')\n)"

kind-delete-nginx-ingress: ## Delete NGINX ingress controller
	@printf "$(call PRINT_COLOR, Deleting NGINX Ingress Controller\n)"
	@kubectl delete ns ingress-nginx
	@pkill -f cloud-provider-kind
