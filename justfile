# Scaffold development tasks.

render_root         := "examples/generated"
project_name        := "Health Service"
project_slug        := "health-service"
package_name        := "health_service"
project_description := "Minimal Python service scaffold"
python_version      := "3.13"

# Show available recipes.
help:
    @just --list

# Print the current scaffold version.
version:
    @cat VERSION

# Render the canonical example project (HTTP + PostgreSQL + tests).
render:
    @just _render '{{ project_slug }}' '{{ package_name }}' '{{ project_name }}' \
        include_http_runtime=true include_postgresql_integration=true include_tests=true

# Render the canonical example project and run its tests.
test-rendered:
    @just _render-test '{{ project_slug }}' '{{ package_name }}' '{{ project_name }}' \
        include_http_runtime=true include_postgresql_integration=true include_tests=true

# Render the canonical example and show its resolved compose config.
compose-config-rendered: render
    docker compose -f {{ render_root }}/{{ project_slug }}/compose.yaml config

# Render and test the full matrix of representative variants.
check-template: test-rendered
    docker compose -f {{ render_root }}/{{ project_slug }}/compose.yaml config
    @just _render-test 'cli-service'        'cli_service'        'CLI Service' \
        include_http_runtime=false include_postgresql_integration=true
    @just _render-test 'stateless-service'  'stateless_service'  'Stateless Service' \
        include_http_runtime=true include_postgresql_integration=false
    @just _render-test 'users-service'      'users_service'      'Users Service' \
        include_http_runtime=true include_postgresql_integration=true include_users_feature=true
    @just _render-test 'stream-service'     'stream_service'     'Stream Service' \
        include_http_runtime=false include_stream_runtime=true include_redis_integration=true
    @just _render-test 'bot-service'        'bot_service'        'Bot Service' \
        include_http_runtime=true include_tg_bot_runtime=true
    @just _render-test 'templating-service' 'templating_service' 'Templating Service' \
        include_http_runtime=false include_templating_component=true

# Remove every rendered example project.
clean-generated:
    rm -rf {{ render_root }}/*

# Render a project into examples/generated/<slug>. Extra answers are bare key=value pairs.
_render slug package name *answers:
    rm -rf {{ render_root }}/{{ slug }}
    copier copy --defaults \
        -d project_name='{{ name }}' \
        -d project_slug='{{ slug }}' \
        -d package_name='{{ package }}' \
        -d project_description='{{ project_description }}' \
        -d python_version='{{ python_version }}' \
        {{ prepend("-d ", answers) }} \
        . {{ render_root }}/{{ slug }}

# Render a variant and run its test suite when the variant includes tests.
_render-test slug package name *answers:
    #!/usr/bin/env sh
    set -eu
    just _render '{{ slug }}' '{{ package }}' '{{ name }}' {{ answers }}
    if [ -d '{{ render_root }}/{{ slug }}/tests' ]; then
        cd '{{ render_root }}/{{ slug }}' && just test
    else
        echo 'Rendered project tests are disabled; skipping.'
    fi
