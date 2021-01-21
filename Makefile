.PHONY: create-migration migrate validate-schema watch

APPLICATION_ENV ?= Development

ifeq ($(APPLICATION_ENV),Development)
 MYSQL_USERNAME := rs
 MYSQL_PASSWORD := rs
endif

help: #! Show this help message.
	@echo 'Usage: make [target] ...'
	@echo ''
	@echo 'Targets:'
	@fgrep -h "#!" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e "s/:.*#!/:/" | column -t -s":"

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo "Parameter variable $* not set"; \
		exit 1; \
	fi

create-migration: guard-name #! Generate a new migration (requires parameter name=<Your Migration Name>)
	MYSQL_USERNAME=$(MYSQL_USERNAME) MYSQL_PASSWORD=$(MYSQL_PASSWORD) dotnet ef migrations add \
		--project src/AuthenticationWithClientSideBlazor.Server/AuthenticationWithClientSideBlazor.Server.csproj \
		-o Data/Migrations "$(name)"

migrate: #! Run all pending migrations
	MYSQL_USERNAME=$(MYSQL_USERNAME) MYSQL_PASSWORD=$(MYSQL_PASSWORD) dotnet ef database update \
		--project src/AuthenticationWithClientSideBlazor.Server/AuthenticationWithClientSideBlazor.Server.csproj

revert-to-migration: guard-name #! Revert to the named migration (requires parameter name=<Your Migration Name>)
	MYSQL_USERNAME=$(MYSQL_USERNAME) MYSQL_PASSWORD=$(MYSQL_PASSWORD) dotnet ef database update \
		--project src/AuthenticationWithClientSideBlazor.Server/AuthenticationWithClientSideBlazor.Server.csproj "$(name)"

remove-migration: #! Removes the last generated migration
	MYSQL_USERNAME=$(MYSQL_USERNAME) MYSQL_PASSWORD=$(MYSQL_PASSWORD) dotnet ef migrations remove \
		--project src/AuthenticationWithClientSideBlazor.Server/AuthenticationWithClientSideBlazor.Server.csproj

generate-migration-sql: guard-from #! Generate sql for migration (requires parameter from=<Your Migration Name>)
	MYSQL_USERNAME=$(MYSQL_USERNAME) MYSQL_PASSWORD=$(MYSQL_PASSWORD) dotnet ef migrations script \
		--project src/AuthenticationWithClientSideBlazor.Server/AuthenticationWithClientSideBlazor.Server.csproj \
		-o Data/Migrations/generated.sql "$(from)"

validate-schema: #! Validate that the schema configuration is correct
	MYSQL_USERNAME=$(MYSQL_USERNAME) MYSQL_PASSWORD=$(MYSQL_PASSWORD) dotnet ef dbcontext info \
		--project src/AuthenticationWithClientSideBlazor.Server/AuthenticationWithClientSideBlazor.Server.csproj \

watch: #! Run the application, restarting on changes
	MYSQL_USERNAME=$(MYSQL_USERNAME) MYSQL_PASSWORD=$(MYSQL_PASSWORD) ASPNETCORE_ENVIRONMENT=Development dotnet watch run \
		--project src/AuthenticationWithClientSideBlazor.Server/AuthenticationWithClientSideBlazor.Server.csproj