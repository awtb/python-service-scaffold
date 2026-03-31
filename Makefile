.PHONY: render test-rendered compose-config-rendered check-template clean-generated

PROJECT_NAME ?= Health Service
PROJECT_SLUG ?= health-service
PACKAGE_NAME ?= health_service
PROJECT_DESCRIPTION ?= Minimal Python service scaffold
PYTHON_VERSION ?= 3.13
INCLUDE_HTTP_RUNTIME ?= true
INCLUDE_STREAM_RUNTIME ?= false
INCLUDE_REDIS_PLUGIN ?= false
INCLUDE_POSTGRESQL_PLUGIN ?= true
INCLUDE_USERS_PLUGIN ?= false
INCLUDE_PRE_COMMIT ?= false
RENDER_DIR ?= examples/generated/$(PROJECT_SLUG)

render:
	rm -rf $(RENDER_DIR)
	copier copy --defaults \
		-d project_name='$(PROJECT_NAME)' \
		-d project_slug='$(PROJECT_SLUG)' \
		-d package_name='$(PACKAGE_NAME)' \
		-d project_description='$(PROJECT_DESCRIPTION)' \
			-d python_version='$(PYTHON_VERSION)' \
			-d include_http_runtime='$(INCLUDE_HTTP_RUNTIME)' \
			-d include_stream_runtime='$(INCLUDE_STREAM_RUNTIME)' \
			-d include_redis_plugin='$(INCLUDE_REDIS_PLUGIN)' \
			-d include_postgresql_plugin='$(INCLUDE_POSTGRESQL_PLUGIN)' \
			-d include_users_plugin='$(INCLUDE_USERS_PLUGIN)' \
			-d include_pre_commit='$(INCLUDE_PRE_COMMIT)' \
			. $(RENDER_DIR)

test-rendered: render
	$(MAKE) -C $(RENDER_DIR) test

compose-config-rendered: render
	docker compose -f $(RENDER_DIR)/compose.yaml config

check-template: render
	$(MAKE) -C $(RENDER_DIR) test
	docker compose -f $(RENDER_DIR)/compose.yaml config
	$(MAKE) test-rendered \
		PROJECT_NAME='CLI Service' \
		PROJECT_SLUG='cli-service' \
		PACKAGE_NAME='cli_service' \
		PROJECT_DESCRIPTION='Minimal Python service scaffold' \
		INCLUDE_HTTP_RUNTIME=false \
		INCLUDE_STREAM_RUNTIME=false \
		INCLUDE_REDIS_PLUGIN=false \
		INCLUDE_POSTGRESQL_PLUGIN=true \
		RENDER_DIR='examples/generated/cli-service'
		$(MAKE) test-rendered \
			PROJECT_NAME='Stateless Service' \
			PROJECT_SLUG='stateless-service' \
			PACKAGE_NAME='stateless_service' \
			PROJECT_DESCRIPTION='Minimal Python service scaffold' \
			INCLUDE_HTTP_RUNTIME=true \
			INCLUDE_STREAM_RUNTIME=false \
			INCLUDE_REDIS_PLUGIN=false \
			INCLUDE_POSTGRESQL_PLUGIN=false \
			INCLUDE_USERS_PLUGIN=false \
			RENDER_DIR='examples/generated/stateless-service'
		$(MAKE) test-rendered \
			PROJECT_NAME='Users Service' \
			PROJECT_SLUG='users-service' \
			PACKAGE_NAME='users_service' \
			PROJECT_DESCRIPTION='Minimal Python service scaffold' \
			INCLUDE_HTTP_RUNTIME=true \
			INCLUDE_STREAM_RUNTIME=false \
			INCLUDE_REDIS_PLUGIN=false \
			INCLUDE_POSTGRESQL_PLUGIN=true \
			INCLUDE_USERS_PLUGIN=true \
			RENDER_DIR='examples/generated/users-service'
		$(MAKE) test-rendered \
			PROJECT_NAME='Stream Service' \
			PROJECT_SLUG='stream-service' \
			PACKAGE_NAME='stream_service' \
			PROJECT_DESCRIPTION='Minimal Python service scaffold' \
			INCLUDE_HTTP_RUNTIME=false \
			INCLUDE_STREAM_RUNTIME=true \
			INCLUDE_REDIS_PLUGIN=true \
			INCLUDE_POSTGRESQL_PLUGIN=false \
			INCLUDE_USERS_PLUGIN=false \
			RENDER_DIR='examples/generated/stream-service'

clean-generated:
	rm -rf examples/generated/*
