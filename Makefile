.PHONY: render test-rendered compose-config-rendered check-template clean-generated

PROJECT_NAME ?= Health Service
PROJECT_SLUG ?= health-service
PACKAGE_NAME ?= health_service
PROJECT_DESCRIPTION ?= Minimal Python service scaffold
PYTHON_VERSION ?= 3.13
INCLUDE_HTTP_RUNTIME ?= true
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
		RENDER_DIR='examples/generated/cli-service'

clean-generated:
	rm -rf examples/generated/*
