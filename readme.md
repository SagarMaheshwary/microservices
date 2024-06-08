# STREAMING PLATFORM - MICROSERVICES

A streaming platform developed using Microservices architecture. (currently in development)

### TECHNOLOGIES

- Golang (v1.22)
- NodeJS (v20)
- PostgreSQL (v14)
- Redis (v7.2)
- RabbitMQ (3.12)
- Amazon S3
- FFMPEG

### FEATURES

- [x] Docker/Docker Compose
- [x] API Gateway
- [x] Authentication Service
- [x] User Service
- [x] Upload Service
- [x] Encode Service
- [ ] Video Catalog Service
- [ ] Video Streaming Service
- [ ] CI/CD (Github Actions)
- [ ] Architecture Diagrams

### SETUP

Once you've cloned the repository, you can use **Docker** and **Docker Compose** (note: this is not the same as [docker-compose](https://stackoverflow.com/a/66526176)) to set up and run all the services locally. Additionally, a **Makefile** is included with commands to streamline the setup process. If you don't have **make** installed on your system, you can simply run the bash commands defined in each Makefile command (be sure to remove the **@** at the start of any command, if present).

Clone all microservices:

```bash
make clone
```

Create **.env** file from **.env.docker-example** in each service.

```bash
make copy-docker-env
```

Update the **env** variables for these services:

- **microservices-encode-service:** all variables starting with AWS\_
- **microservices-upload-service:** all variables starting with AWS\_

Download and build all required Docker images:

```bash
make compose-build
```

You can also use the below command to rebuild images after making changes to any microservice like installing or removing a dependency.

```bash
make compose-rebuild
```

Start all Docker containers:

```bash
make compose-up
```

After all the containers are up and running, you need to run migrations and scripts to create the database tables for the required services. To do this, open a new terminal and execute the following command:

```bash
make migrate
```

Access the microservices at **localhost:3000**. Each service is mounted with a **volume**. This means any changes to the code are automatically synced to the container, eliminating the need to restart containers manually.

To run containers in the background:

```bash
make compose-up-detached
```

To remove the containers:

```bash
make compose-down
```

Delete the container images:

```bash
make delete-images
```

### APIs

Checkout the [**microservices-api-gateway**](https://github.com/SagarMaheshwary/microservices-api-gateway) repo for available apis listing, examples, and Postman collection.
