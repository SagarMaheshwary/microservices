clone:
	@echo "----------------- CLONING MICROSERVICES FROM GITHUB -----------------"
	git clone https://github.com/SagarMaheshwary/microservices-api-gateway
	git clone https://github.com/SagarMaheshwary/microservices-authentication-service
	git clone https://github.com/SagarMaheshwary/microservices-user-service

copy-local-env:
	@echo "----------------- CREATING ENV FILE FOR EACH MICROSERVICE -----------------"
	cp ./microservices-api-gateway/.env.example ./microservices-api-gateway/.env
	cp ./microservices-authentication-service/.env.example ./microservices-authentication-service/.env
	cp ./microservices-user-service/.env.example ./microservices-user-service/.env

copy-docker-env:
	@echo "----------------- CREATING ENV FILE FOR EACH MICROSERVICE -----------------"
	cp ./microservices-api-gateway/.env.docker-example ./microservices-api-gateway/.env
	cp ./microservices-authentication-service/.env.docker-example ./microservices-authentication-service/.env
	cp ./microservices-user-service/.env.docker-example ./microservices-user-service/.env

build:
	@echo "----------------- BUILDING DOCKER CONTAINER IMAGES -----------------"
	docker compose build

rebuild:
	@echo "----------------- REBUILDING DOCKER IMAGES -----------------"
	docker compose up --build --force-recreate

up:
	@echo "----------------- STARTING DOCKER CONTAINERS -----------------"
	docker compose up

up-detached:
	@echo "----------------- STARTING DOCKER CONTAINERS IN DETACHED MODE -----------------"
	docker compose up -d

down:
	@echo "----------------- STOPPING DOCKER CONTAINERS -----------------"
	docker compose down
