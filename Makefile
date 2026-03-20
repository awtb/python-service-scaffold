.PHONY: render test-rendered compose-config-rendered check-template clean-generated

PROJECT_NAME ?= Health Service
PROJECT_SLUG ?= health-service
PACKAGE_NAME ?= health_service
PROJECT_DESCRIPTION ?= Minimal FastAPI service
PYTHON_VERSION ?= 3.13
RENDER_DIR ?= examples/generated/$(PROJECT_SLUG)

render:
	rm -rf $(RENDER_DIR)
	copier copy --defaults \
		-d project_name='$(PROJECT_NAME)' \
		-d project_slug='$(PROJECT_SLUG)' \
		-d package_name='$(PACKAGE_NAME)' \
		-d project_description='$(PROJECT_DESCRIPTION)' \
		-d python_version='$(PYTHON_VERSION)' \
		. $(RENDER_DIR)

test-rendered: render
	$(MAKE) -C $(RENDER_DIR) test

compose-config-rendered: render
	docker compose -f $(RENDER_DIR)/compose.yaml config

check-template: render
	$(MAKE) -C $(RENDER_DIR) test
	docker compose -f $(RENDER_DIR)/compose.yaml config

clean-generated:
	rm -rf examples/generated/*
