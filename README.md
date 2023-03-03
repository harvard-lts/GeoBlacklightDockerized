# README

This project requires an environment that enables you to build and share containerized applications and microservices, such as [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [Minikube](https://minikube.sigs.k8s.io/docs/start/).

## Technology Stack
#### Language
Ruby 3

#### Framework
Rails 7

#### Development Operations
Docker Compose

#### Database
mySQL

#### Search
Solr

## Local Development Environment Setup Instructions

### 1: Clone the repository to a local directory
```
git clone git@github.com:harvard-lts/GeoBlacklightDockerized
```

### 2: Create app environment variables

##### Create config file for environment variables
- Make a copy of the config example file `./env-example.txt`
- Rename the file to `.env`
- Replace placeholder values as necessary

>Note: The config file `.env` is specifically excluded in `.gitignore` and `.dockerignore`. Since it contains credentials, it should NEVER be committed to any repository.

### 3. Build

Run docker compose build (may not be necessary but I like to do this)

### 4: Start

This command builds all images and runs all containers specified in the docker-compose-local.yml configuration.


This command uses the `docker-compose.yml` file to build the `Dockerfile` image `--build` and also starts the containers `up` in background mode `-d`.

```
docker-compose -f docker-compose.yml up -d --build --force-recreate
```

To restart the containers later without a full rebuild, the options `--build` and `--force-recreate` can be omitted after the images are built already.

When this finishes, and the database is up and migrations are done (takes about 3-5 minutes), geoblacklight should be available at `https://localhost:21800/`

### 5: Run commands inside a container
To run commands inside a running container, execute a shell using the `exec` command. This same technique can be used to run commands in any container that is running already.

```
docker exec -it <containerID> bash
```

## Notes

This has been configured to use MySQL/MariaDB by default (see `env-example.txt`), but if you prefer PostgreSQL, you can use the `env-psql.txt` by replacing the `config/database.yml` file with with the `config/database.yml.postgres` file, uncomment the `pg gem` line, and rebuild using the `docker-compose-psql.yml` file (which uses the DockerfilePostgres file).

This only runs in development mode, to avoid committing a junk `master.key` and credentials set (in case someone uses this and forgets to put that in `.gitignore` later). To run in another mode you can generate a new `master.key` and credentials pair locally.
