.PHONY: version render test-rendered compose-config-rendered check-template clean-generated

VERSION_FILE ?= VERSION
PROJECT_NAME ?= Health Service
PROJECT_SLUG ?= health-service
PACKAGE_NAME ?= health_service
PROJECT_DESCRIPTION ?= Minimal Python service scaffold
PYTHON_VERSION ?= 3.13
INCLUDE_HTTP_RUNTIME ?= true
INCLUDE_TG_BOT_RUNTIME ?= false
INCLUDE_STREAM_RUNTIME ?= false
INCLUDE_REDIS_INTEGRATION ?= false
INCLUDE_POSTGRESQL_INTEGRATION ?= true
INCLUDE_USERS_FEATURE ?= false
INCLUDE_TEMPLATING_COMPONENT ?= false
INCLUDE_PRE_COMMIT ?= false
INCLUDE_TESTS ?= true
RENDER_DIR ?= examples/generated/$(PROJECT_SLUG)

version:
	@cat $(VERSION_FILE)

render:
	rm -rf $(RENDER_DIR)
	copier copy --defaults \
		-d project_name='$(PROJECT_NAME)' \
		-d project_slug='$(PROJECT_SLUG)' \
		-d package_name='$(PACKAGE_NAME)' \
		-d project_description='$(PROJECT_DESCRIPTION)' \
			-d python_version='$(PYTHON_VERSION)' \
			-d include_http_runtime='$(INCLUDE_HTTP_RUNTIME)' \
			-d include_tg_bot_runtime='$(INCLUDE_TG_BOT_RUNTIME)' \
			-d include_stream_runtime='$(INCLUDE_STREAM_RUNTIME)' \
			-d include_redis_integration='$(INCLUDE_REDIS_INTEGRATION)' \
			-d include_postgresql_integration='$(INCLUDE_POSTGRESQL_INTEGRATION)' \
			-d include_users_feature='$(INCLUDE_USERS_FEATURE)' \
			-d include_templating_component='$(INCLUDE_TEMPLATING_COMPONENT)' \
			-d include_pre_commit='$(INCLUDE_PRE_COMMIT)' \
			-d include_tests='$(INCLUDE_TESTS)' \
			. $(RENDER_DIR)

test-rendered: render
ifeq ($(INCLUDE_TESTS),true)
	$(MAKE) -C $(RENDER_DIR) test
else
	@echo "Rendered project tests are disabled; skipping."
endif

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
		INCLUDE_TG_BOT_RUNTIME=false \
		INCLUDE_STREAM_RUNTIME=false \
		INCLUDE_REDIS_INTEGRATION=false \
		INCLUDE_POSTGRESQL_INTEGRATION=true \
		RENDER_DIR='examples/generated/cli-service'
		$(MAKE) test-rendered \
			PROJECT_NAME='Stateless Service' \
			PROJECT_SLUG='stateless-service' \
			PACKAGE_NAME='stateless_service' \
			PROJECT_DESCRIPTION='Minimal Python service scaffold' \
			INCLUDE_HTTP_RUNTIME=true \
			INCLUDE_TG_BOT_RUNTIME=false \
			INCLUDE_STREAM_RUNTIME=false \
			INCLUDE_REDIS_INTEGRATION=false \
			INCLUDE_POSTGRESQL_INTEGRATION=false \
			INCLUDE_USERS_FEATURE=false \
			RENDER_DIR='examples/generated/stateless-service'
		$(MAKE) test-rendered \
			PROJECT_NAME='Users Service' \
			PROJECT_SLUG='users-service' \
			PACKAGE_NAME='users_service' \
			PROJECT_DESCRIPTION='Minimal Python service scaffold' \
			INCLUDE_HTTP_RUNTIME=true \
			INCLUDE_TG_BOT_RUNTIME=false \
			INCLUDE_STREAM_RUNTIME=false \
			INCLUDE_REDIS_INTEGRATION=false \
			INCLUDE_POSTGRESQL_INTEGRATION=true \
			INCLUDE_USERS_FEATURE=true \
			RENDER_DIR='examples/generated/users-service'
		$(MAKE) test-rendered \
			PROJECT_NAME='Stream Service' \
			PROJECT_SLUG='stream-service' \
			PACKAGE_NAME='stream_service' \
			PROJECT_DESCRIPTION='Minimal Python service scaffold' \
			INCLUDE_HTTP_RUNTIME=false \
			INCLUDE_TG_BOT_RUNTIME=false \
			INCLUDE_STREAM_RUNTIME=true \
			INCLUDE_REDIS_INTEGRATION=true \
			INCLUDE_POSTGRESQL_INTEGRATION=false \
			INCLUDE_USERS_FEATURE=false \
			RENDER_DIR='examples/generated/stream-service'
		$(MAKE) test-rendered \
			PROJECT_NAME='Bot Service' \
			PROJECT_SLUG='bot-service' \
			PACKAGE_NAME='bot_service' \
			PROJECT_DESCRIPTION='Minimal Python service scaffold' \
			INCLUDE_HTTP_RUNTIME=true \
			INCLUDE_TG_BOT_RUNTIME=true \
			INCLUDE_STREAM_RUNTIME=false \
			INCLUDE_REDIS_INTEGRATION=false \
			INCLUDE_POSTGRESQL_INTEGRATION=false \
			INCLUDE_USERS_FEATURE=false \
			RENDER_DIR='examples/generated/bot-service'
		$(MAKE) test-rendered \
			PROJECT_NAME='Templating Service' \
			PROJECT_SLUG='templating-service' \
			PACKAGE_NAME='templating_service' \
			PROJECT_DESCRIPTION='Minimal Python service scaffold' \
			INCLUDE_HTTP_RUNTIME=false \
			INCLUDE_TG_BOT_RUNTIME=false \
			INCLUDE_STREAM_RUNTIME=false \
			INCLUDE_REDIS_INTEGRATION=false \
			INCLUDE_POSTGRESQL_INTEGRATION=false \
			INCLUDE_USERS_FEATURE=false \
			INCLUDE_TEMPLATING_COMPONENT=true \
			RENDER_DIR='examples/generated/templating-service'

clean-generated:
	rm -rf examples/generated/*
