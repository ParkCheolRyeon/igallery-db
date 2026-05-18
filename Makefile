.PHONY: help migrate-up migrate-down migrate-version migrate-create migrate-force db-up db-down db-psql

ENV_FILE ?= .env.local
ifneq (,$(wildcard $(ENV_FILE)))
include $(ENV_FILE)
export
endif

MIGRATIONS_DIR := migrations

help:
	@echo "Local migration targets — requires .env.local with DATABASE_URL"
	@echo ""
	@echo "  make migrate-up                apply all pending migrations"
	@echo "  make migrate-down              rollback last migration"
	@echo "  make migrate-version           show current version"
	@echo "  make migrate-force v=N         force version (escape dirty state)"
	@echo "  make migrate-create name=foo   create new up/down sql files"
	@echo ""
	@echo "  make db-up                     start local postgres (docker compose)"
	@echo "  make db-down                   stop local postgres"
	@echo "  make db-psql                   psql into local postgres"
	@echo ""
	@echo "Production migration runs in GitHub Actions only (.github/workflows/migrate.yml)"

migrate-up:
	@test -n "$(DATABASE_URL)" || (echo "❌ DATABASE_URL not set (copy .env.local.example to .env.local)"; exit 1)
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" up

migrate-down:
	@test -n "$(DATABASE_URL)" || (echo "❌ DATABASE_URL not set"; exit 1)
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" down 1

migrate-version:
	@test -n "$(DATABASE_URL)" || (echo "❌ DATABASE_URL not set"; exit 1)
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" version

migrate-force:
	@test -n "$(DATABASE_URL)" || (echo "❌ DATABASE_URL not set"; exit 1)
	@test -n "$(v)" || (echo "Usage: make migrate-force v=<version>"; exit 1)
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" force $(v)

migrate-create:
	@test -n "$(name)" || (echo "Usage: make migrate-create name=add_foo_table"; exit 1)
	migrate create -ext sql -dir $(MIGRATIONS_DIR) -seq $(name)

db-up:
	docker compose up -d postgres

db-down:
	docker compose down

db-psql:
	docker compose exec postgres psql -U postgres -d app_dp
