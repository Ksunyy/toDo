include .env
export

export PROJECT_ROOT=$(CURDIR)

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@powershell -Command "$$ans = Read-Host 'Are you sure you want to delete volume? [y/N]'; \
	if ($$ans -eq 'y') { docker compose down todoapp-postgres; \
	Remove-Item -Recurse -Force .\out\pgdata; \
	Write-Host 'Succesfully deleted' } \
	else { Write-Host 'Cleanup was cancelled' }"


env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

migrate-create:
	@powershell -Command "if ([string]::IsNullOrEmpty('$(seq)')) { \
	Write-Host 'seq is required'; \
	exit 1; \
	}; \
	docker compose run --rm todoapp-postgres-migrate \
	create \
	-ext sql \
	-dir /migrations \
	-seq \
	$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@powershell -Command "if ([string]::IsNullOrEmpty('$(action)')) { \
	Write-Host 'action is required'; \
	exit 1; \
	}; \
	docker compose run --rm todoapp-postgres-migrate \
	 -path /migrations \
	 -database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
	 "$(action)"

