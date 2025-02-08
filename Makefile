clone:
	@echo "----------------- CLONING MICROSERVICES FROM GITHUB -----------------"
	git clone https://github.com/SagarMaheshwary/microservices-api-gateway
	git clone https://github.com/SagarMaheshwary/microservices-authentication-service
	git clone https://github.com/SagarMaheshwary/microservices-user-service
	git clone https://github.com/SagarMaheshwary/microservices-upload-service
	git clone https://github.com/SagarMaheshwary/microservices-encode-service
	git clone https://github.com/SagarMaheshwary/microservices-video-catalog-service

copy-local-env:
	@echo "----------------- CREATING ENV FILE FOR EACH MICROSERVICE -----------------"
	cp ./microservices-api-gateway/.env.example ./microservices-api-gateway/.env
	cp ./microservices-authentication-service/.env.example ./microservices-authentication-service/.env
	cp ./microservices-user-service/.env.example ./microservices-user-service/.env
	cp ./microservices-upload-service/.env.example ./microservices-upload-service/.env
	cp ./microservices-encode-service/.env.example ./microservices-encode-service/.env
	cp ./microservices-video-catalog-service/.env.example ./microservices-video-catalog-service/.env

copy-docker-env:
	@echo "----------------- CREATING ENV FILE FOR EACH MICROSERVICE -----------------"
	cp ./microservices-api-gateway/.env.docker-example ./microservices-api-gateway/.env
	cp ./microservices-authentication-service/.env.docker-example ./microservices-authentication-service/.env
	cp ./microservices-user-service/.env.docker-example ./microservices-user-service/.env
	cp ./microservices-upload-service/.env.docker-example ./microservices-upload-service/.env
	cp ./microservices-encode-service/.env.docker-example ./microservices-encode-service/.env
	cp ./microservices-video-catalog-service/.env.docker-example ./microservices-video-catalog-service/.env

compose-build:
	@echo "----------------- BUILDING DOCKER CONTAINER IMAGES -----------------"
	docker compose pull
	docker compose build

compose-rebuild:
	@echo "----------------- REBUILDING DOCKER IMAGES -----------------"
	docker compose build --no-cache

compose-up:
	@echo "----------------- STARTING DOCKER CONTAINERS -----------------"
	docker compose up

migrate:
	@echo "----------------- RUNNING MIGRATIONS -----------------"
	docker exec microservices-user-service npm run migration:run
	docker exec microservices-video-catalog-db psql -U postgres -d microservices_video_catalog_service -a -f /docker-entrypoint-initdb.d/database.sql

compose-up-detached:
	@echo "----------------- STARTING DOCKER CONTAINERS IN DETACHED MODE -----------------"
	docker compose up -d

compose-down:
	@echo "----------------- REMOVING DOCKER CONTAINERS -----------------"
	docker compose down

list-images:
	@echo "----------------- IMAGES LIST (ONLY MICROSERVICES) -----------------"
	docker images --filter=reference="microservices*"

delete-images:
	@echo "----------------- DELETING ALL IMAGES/BUILD CACHE -----------------"
	docker rmi $$(docker images --filter=reference="microservices*" -q) -f
	docker rmi postgres:14 redis:7.2 rabbitmq:3.12-management dpage/pgadmin4:8.13.0 grafana/grafana-enterprise:11.3.0 prom/prometheus:v2.55.0 grafana/loki:2.7.0 kbudde/rabbitmq-exporter:1.0.0 prometheuscommunity/postgres-exporter:v0.16.0 oliver006/redis_exporter:v1.67.0 -f
	docker builder prune -f
	docker image prune -f
