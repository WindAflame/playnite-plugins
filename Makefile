# Dev entry points for the plugins (uv + Python) and the docs site (npm workspaces).
# Run `make` or `make help` to list targets.

# Path to Playnite's Toolbox.exe, used by `make pack`. Falls back to the
# PLAYNITE_TOOLBOX env var (read by tools/pack-extensions.py) when unset.
TOOLBOX ?=

.DEFAULT_GOAL := help
.PHONY: help install build pack docs-dev docs-build clean

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Install docs dependencies (npm)
	npm install

build: ## Copy every plugin under plugins/ into dist/
	uv run tools/build-extension.py

pack: build ## Pack each dist/<plugin> into dist/pext/<plugin>.pext (TOOLBOX=<path to Toolbox.exe>)
	uv run tools/pack-extensions.py $(if $(TOOLBOX),--toolbox "$(TOOLBOX)")

docs-dev: ## Preview the docs site locally
	npm run dev --workspace docs

docs-build: ## Build the docs site into dist/docs/
	npm run build --workspace docs

clean: ## Remove all build output (dist/)
	rm -rf dist
