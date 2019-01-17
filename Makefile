###
# Project commands
##

## Variables

# Project variables
TARGET = lite
URL = http://127.0.0.1:8080

# Directories
BIN = bin
LOGS = logs
SCRIPTS = scripts
PIPELINES = pipelines
SUBMODULES = .submodules
KEYS = $(SUBMODULES)/concourse-docker/keys

# FLY = $(BIN)/fly
FLY = fly
COMPOSE_FILE = $(SUBMODULES)/concourse-docker/docker-compose.yml

# Environment variables
export PATH := ./$(SCRIPTS):$(SUBMODULES)/bash-logger:$(PATH)
export LOGFILE := $(LOGS)/$(shell date '+%Y-%m-%d').log

# Get OS and Processor type
ifeq ($(OS),Windows_NT)
	OS = windows
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		PROCESSOR = amd64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			PROCESSOR = amd64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			PROCESSOR = i386
		endif
	endif
else
	UNAME_S = $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
	OS = linux
		UNAME_P := $(shell uname -p)
		ifeq ($(UNAME_P),x86_64)
			PROCESSOR = amd64
		endif
		ifneq ($(filter %86,$(UNAME_P)),)
			PROCESSOR = i386
		endif
		ifneq ($(filter arm%,$(UNAME_P)),)
			PROCESSOR = arm
		endif
	endif
	ifeq ($(UNAME_S),Darwin)
	OS = darwin
		PROCESSOR = amd64
	endif
endif


###
# Sets up the needed directories that are ignored
##
$(shell mkdir -p $(LOGS) $(BIN))

# Collects all pipelines under the pipeline directory
ALL_PIPELINES = $(foreach pipeline,$(wildcard $(PIPELINES)/*),$(shell echo $(pipeline) | sed 's/.*_//'))

## Tasks

.PHONY: *

###
# Generates the keys needed by the docker containers
##
keys:
	docker run --rm -v $(PWD)/.submodules/concourse-docker:/srv -w /srv ubuntu:latest bash -c 'apt-get update && apt-get install -y openssh-client && ./generate-keys.sh'
# keys

###
# Starts the docker containers
##
start: keys
	env CONCOURSE_NO_REALLY_I_DONT_WANT_ANY_AUTH=true docker-compose -f $(COMPOSE_FILE) up -d
# start

###
# Stops the docker containers
##
stop:
	docker-compose -f $(COMPOSE_FILE) stop
# stop

###
# Destroys the docker containers and the keys associated
##
destroy: stop
	docker-compose -f $(COMPOSE_FILE) rm

	$(SCRIPTS)/keydegen.sh $(KEYS)
# destroy

###
# Downloads the fly binary from $(URL) to communicate with concourse
#
# Notes:
#  - Fly requires the version to match that of the concourse server
#  - The file is dumped into $(FLY)
#  - The function attempts to determine the OS and Processor Architecure
##
fly:
ifeq (,$(wildcard $(FLY)))
	wget -O $(FLY) "$(URL)/api/v1/cli?arch=$(PROCESSOR)&platform=$(OS)"
endif
	@chmod +x $(FLY)
# fly

###
# Creates a fly session under the $(TARGET) and $(URL)
##
login: fly
	@$(FLY) -t $(TARGET) login -c $(URL)
# login

## Pipelines

###
# Lists all the available pipelines to run
##
list-pipelines:
	@for pipeline in $(ALL_PIPELINES); do echo $$pipeline; done
# list pipelines

###
# Runs ALL of the pipelines
##
pipelines: $(ALL_PIPELINES)

###
# Creates dynamic tasks foreach pipeline under the $(PIPELINES) directory
##
%: #login
	@echo "Running pipeline: %"
	$(SCRIPTS)/run-pipeline.sh -t $(TARGET) -s $(PIPELINES) $(@)
# %

# Makefile
