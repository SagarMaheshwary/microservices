MICROSERVICES= \
    api-gateway \
    authentication-service \
    user-service \
    upload-service \
    encode-service \
    video-catalog-service

.PHONY: help clone copy-env-files docker-compose-build docker-compose-up  docker-compose-detached docker-compose-down docker-delete-images docker-db-migrate

# Utility for colored output
define PRINT_COLOR
\033[1;32m$(1)\033[0m
endef

help:
	@echo "$(call PRINT_COLOR, Available commands:)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "} {printf "%-30s %s\n", $$1, $$2}'

clone: ## Clone all microservices from GitHub
	@echo "$(call PRINT_COLOR, Cloning microservices from GitHub)"
	@for service in  $(MICROSERVICES); do \
	  git clone https://github.com/SagarMaheshwary/microservices-$$service || true; \
	done

copy-env-files: ## Create .env for Docker setup for each microservice
	@echo "$(call PRINT_COLOR, Creating Docker .env files for each microservice)"
	@for service in  $(MICROSERVICES); do \
	  cp ./microservices-$$service/.env.docker-example ./microservices-$$service/.env || true; \
	done

docker-compose-build: ## Build Docker images
	@echo "$(call PRINT_COLOR, Building Docker container images)"
	docker compose pull
	docker compose build

docker-compose-up: ## Start Docker containers
	@echo "$(call PRINT_COLOR, Starting Docker containers)"
	@echo "$(call PRINT_COLOR, Note: Some containers run in detached mode. Check the docker-compose.yml file for services with 'attach: false')"
	docker compose up

docker-compose-up-detached: ## Start Docker containers in detached mode
	@echo "$(call PRINT_COLOR, Starting Docker containers in detached mode)"
	docker compose up -d

docker-compose-down: ## Remove Docker containers
	@echo "$(call PRINT_COLOR, Removing all running containers)"
	docker compose down

docker-delete-images:
	@echo "$(call PRINT_COLOR, Deleting all images and build cache)"
	docker rmi $$(docker images --filter=reference="microservices*" -q) -f
	docker rmi -f \
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
	docker builder prune -f
	docker image prune -f

docker-db-migrate:
	@echo "$(call PRINT_COLOR, Running migrations for user service and video catalog service)"
	docker exec microservices-user-service npm run migration:run
	docker exec microservices-video-catalog-db psql -U postgres -d microservices_video_catalog_service -a -f /docker-entrypoint-initdb.d/database.sql
