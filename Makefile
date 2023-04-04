#################################################################################
#
# Makefile to build the project
#
#################################################################################

PROJECT_NAME = de-project
REGION = us-east-1
PYTHON_INTERPRETER = python
WD=$(shell pwd)
PYTHONPATH=${WD}
FULL_PYTHONPATH=${PYTHONPATH}:${PYTHONPATH}/src/extraction_lambda:${PYTHONPATH}/src/transform_lambda
SHELL := /bin/bash
PROFILE = default
PIP:=pip


## Create python interpreter environment.
create-environment:
	@echo ">>> About to create environment: $(PROJECT_NAME)..."
	@echo ">>> check python3 version"
	( \
		$(PYTHON_INTERPRETER) --version; \
	)
	@echo ">>> Setting up VirtualEnv."
	( \
	    $(PIP) install -q virtualenv virtualenvwrapper; \
	    virtualenv venv --python=$(PYTHON_INTERPRETER); \
	)

# Define utility variable to help calling Python from the virtual environment
ACTIVATE_ENV := source venv/bin/activate

# Execute python related functionalities from within the project's environment
define execute_in_env
	$(ACTIVATE_ENV) && $1
endef

## Build the environment requirements
requirements: create-environment
	$(call execute_in_env, $(PIP) install -r ./requirements.txt)

################################################################################################################
# Set Up

##Install requirments for lambda deployment
lambda-deployment-packages:
	@if ! which zip > /dev/null; then \
    echo "Error: zip is not installed. Please install zip and try again."; \
    exit 1; \
	fi

	@if [ -d "archives/extraction_lambda" ]; then \
  		rm -rf "archives/extraction_lambda"; \
	fi
	mkdir -p ./archives/extraction_lambda
	$(call execute_in_env, $(PIP) install -r ./deployment/extraction_requirements.txt -t ./archives/extraction_lambda/)
	cp -r ./src/extraction_lambda/* ./archives/extraction_lambda/

	@if [ -d "archives/transform_lambda" ]; then \
  		rm -rf "archives/transform_lambda"; \
	fi
	mkdir -p ./archives/transform_lambda
	$(call execute_in_env, $(PIP) install -r ./deployment/transform_requirements.txt -t ./archives/transform_lambda/)
	cp -r ./src/transform_lambda/* ./archives/transform_lambda/

	@if [ -d "archives/load_lambda" ]; then \
  		rm -rf "archives/load_lambda"; \
	fi
	mkdir -p ./archives/load_lambda
	$(call execute_in_env, $(PIP) install -r ./deployment/load_requirements.txt -t ./archives/load_lambda/)
	cp -r ./src/load_lambda/* ./archives/load_lambda/


## Install bandit
bandit:
	$(call execute_in_env, $(PIP) install bandit)

## Install safety
safety:
	$(call execute_in_env, $(PIP) install safety)

## Install flake8
flake:
	$(call execute_in_env, $(PIP) install flake8)

## Install coverage
coverage:
	$(call execute_in_env, $(PIP) install coverage)

## Set up dev requirements (bandit, safety, flake8)
dev-setup: bandit safety flake coverage

# Build / Run

## Run the security test (bandit + safety)
security-test:
	$(call execute_in_env, safety check -r ./requirements.txt -r ./deployment/extraction_requirements.txt)
	$(call execute_in_env, bandit -lll */*.py *c/*/*.py)

## Run the flake8 code check
run-flake:
	$(call execute_in_env, flake8  ./src/*/*.py ./test/*/*.py)

## Run the unit tests
unit-test:
	$(call execute_in_env, PYTHONPATH=${FULL_PYTHONPATH} pytest -vrP test/${test_folder})

## Run the coverage check
check-coverage:
	$(call execute_in_env, PYTHONPATH=${FULL_PYTHONPATH} coverage run --omit 'venv/*' -m pytest test/ && coverage report -m)

## Run all checks
run-checks: security-test run-flake unit-test check-coverage


