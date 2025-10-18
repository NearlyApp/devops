# Simple Makefile for managing Docker Compose environments

INFRA_FILE = docker-compose.infra.yml
SERVICES_FILE = docker-compose.services.yml

.PHONY: deploy-infra deploy-services down clean

ensure-networks:
	@echo "🔧 Ensuring required networks exist..."
	@if ! docker network inspect devops_backend >/dev/null 2>&1; then \
		echo "Creating backend network..."; \
		docker network create devops_backend; \
	fi
	@if ! docker network inspect devops_frontend >/dev/null 2>&1; then \
		echo "Creating frontend network..."; \
		docker network create devops_frontend; \
	fi

deploy-infra:
	@$(MAKE) ensure-networks
	@echo "🚀 Deploying infrastructure..."
	docker compose -f $(INFRA_FILE) -p devops up -d

deploy-services:
	@$(MAKE) ensure-networks
	@echo "Setting up..."
	
	cd api && echo "//npm.pkg.github.com/:_authToken=${GHP_TOKEN}" > .npmrc.secret
	
	cd ..
	@echo "🚀 Deploying services..."
	docker compose -f $(SERVICES_FILE) -p devops up -d

down:
	@echo "🧹 Stopping all containers..."
	docker compose -f $(SERVICES_FILE) down
	docker compose -f $(INFRA_FILE) down

clean:
	@echo "🔥 Removing all containers, networks, and volumes..."
	docker compose -f $(SERVICES_FILE) down -v --remove-orphans
	docker compose -f $(INFRA_FILE) down -v --remove-orphans
