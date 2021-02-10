DOCKER_IMAGE_PREFIX=zondax/builder
DOCKER_IMAGE_CIRCLECI=${DOCKER_IMAGE_PREFIX}-circleci

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)

ifdef INTERACTIVE
INTERACTIVE_SETTING:="-i"
TTY_SETTING:="-t"
else
INTERACTIVE_SETTING:=
TTY_SETTING:=
endif

ifdef HASH
HASH_TAG:=$(HASH)
else
HASH_TAG:=latest
endif

default: build

build: build_circleci

build_circleci:
	cd src && docker build --rm -f Dockerfile -t $(DOCKER_IMAGE_CIRCLECI):$(HASH_TAG) -t $(DOCKER_IMAGE_CIRCLECI) .

publish_login:
	docker login
publish_circleci: build_circleci
	docker push $(DOCKER_IMAGE_CIRCLECI)
	docker push $(DOCKER_IMAGE_CIRCLECI):$(HASH_TAG)

publish: build
publish: publish_login
publish: publish_circleci

push: publish_circleci

pull:
	docker pull $(DOCKER_IMAGE_CIRCLECI):$(HASH_TAG)

define run_docker
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) \
	--privileged \
	-u $(shell id -u):$(shell id -g) \
	-v $(shell pwd):/project \
	-e DISPLAY=$(shell echo ${DISPLAY}) \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	$(1) \
	"$(2)"
endef


shell_circleci: build_circleci
	$(call run_docker,$(DOCKER_IMAGE_CIRCLECI):$(HASH_TAG),/bin/bash)
