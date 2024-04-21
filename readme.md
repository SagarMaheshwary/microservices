# STREAMING PLATFORM - MICROSERVICES

A streaming platform developed using Microservices architecture. (currently in development)

### TECHNOLOGIES

- Golang (v1.22)
- NodeJS (v20)
- PostgreSQL (v14)
- Redis (v7.2)

### FEATURES

- [x] Docker/Docker Compose
- [x] API Gateway
- [x] Authentication Service
- [x] User Service
- [ ] Video Streaming Service
- [ ] Tests
- [ ] CI/CD (Github Actions)

### SETUP

Once you've cloned the repo, you have two options for setting it up: you can either use Docker (recommended), or run each service locally. Additionally, a **Makefile** is included with commands to streamline the setup process. However, if you don't have **make** installed on your system then you can use alternative instructions provided in this readme.

#### Docker/Docker Compose

Make sure you have docker and docker compose ([not docker-compose](https://stackoverflow.com/a/66526176)) installed on your system.

Clone all microservices:

```bash
make clone
```

Alternative (if **make** is not available):

```bash
git clone https://github.com/SagarMaheshwary/microservices-api-gateway
git clone https://github.com/SagarMaheshwary/microservices-authentication-service
git clone https://github.com/SagarMaheshwary/microservices-user-service
```

Create **.env** file from **.env.docker-example** in each service:

```bash
make copy-docker-env
```

Alternative: (use powershell if running on windows)

```bash
cp ./microservices-api-gateway/.env.docker-example ./microservices-api-gateway/.env
cp ./microservices-authentication-service/.env.docker-example ./microservices-authentication-service/.env
cp ./microservices-user-service/.env.docker-example ./microservices-user-service/.env
```

Download and build all required Docker images:

```bash
make build
```

Alternative:

```bash
docker compose build
```

You can also use the below command to rebuild images after making changes to any microservice like installing or removing a dependency.

```bash
make rebuild
```

Alternative:

```bash
docker compose up --build --force-recreate
```

Every service is mounted with a **volume** which means any changes to the code will be automatically synced to the container so that we don't restart containers manually.

Start all Docker containers:

```bash
make up
```

Alternative:

```bash
docker compose up --build --force-recreate
```

Access the microservices at **localhost:3000**.

To run containers in the background:

```bash
make up-detached
```

Alternative:

```bash
docker compose up -d
```

To stop the containers:

```bash
make down
```

Alternative:

```bash
docker compose down
```

#### LOCAL

Each microservice repo contains instructions for local setup.

Clone all microservices:

```bash
make clone
```

Alternative (if **make** is not available):

```bash
git clone https://github.com/SagarMaheshwary/microservices-api-gateway
git clone https://github.com/SagarMaheshwary/microservices-authentication-service
git clone https://github.com/SagarMaheshwary/microservices-user-service
```

Create **.env** files with default values from **.env.example**:

```bash
make copy-local-env
```

Alternative: (use powershell if running on windows)

```bash
cp ./microservices-api-gateway/.env.example ./microservices-api-gateway/.env
cp ./microservices-authentication-service/.env.example ./microservices-authentication-service/.env
cp ./microservices-user-service/.env.example ./microservices-user-service/.env
```

Update **.env** files with your local system configuration.

### APIs

Checkout the [**microservices-api-gateway**](https://github.com/SagarMaheshwary/microservices-api-gateway) repo for available apis listing, examples, and Postman collection.
