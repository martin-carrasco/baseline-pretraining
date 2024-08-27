VER := 3.12
INSTALL_STAMP := .install.stamp
ENV_STAMP := .env.stamp
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate
CONDA := $(shell command -v conda 2> /dev/null)
POETRY := $(shell command -v poetry 2> /dev/null)
ARCH := cpu
.DEFAULT_GOAL := help

install: $(INSTALL_STAMP)
env: $(ENV_STAMP)
conda: 
	@$(CONDA_ACTIVATE) babylm
	@echo "Set conda environment"
	touch $(ENV_STAMP)

pyenv:
	@pyenv local $(VER)
	@echo "Set pyenv environment"
	touch $(ENV_STAMP)


$(ENV_STAMP):
	@if [ $(CONDA) ]; then \
		$(CONDA_ACTIVATE) babylm; \
		echo "Set conda environment"; \
	else \
		pyenv local $(VER); \
		echo "Set pyenv environment"; \
	fi
	touch $(ENV_STAMP)

$(INSTALL_STAMP): pyproject.toml poetry.lock
		@if [ -z $(POETRY) ]; then echo "Poetry could not be found. See https://python-poetry.org/docs/"; exit 2; fi
		@if [ $(ARCH) = "cpu" ]; then $(POETRY) install; else $(POETRY) install --with $(ARCH); fi
		touch $(INSTALL_STAMP)


.PHONY: clean
clean:
	rm -rf $(INSTALL_STAMP) $(ENV_STAMP)
	rm -rf .python-version

help:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo ""
	@echo "  install   install packages and prepare environment"
	@echo "  pyenv     activate pyenv"
	@echo "  conda  install packages and prepare environment for gpu121"
	@echo "  env  activate default environment manager"
	@echo "  clean       remove .python-version dir"
	@echo ""
	@echo "Check the Makefile to know exactly what each target is doing."
