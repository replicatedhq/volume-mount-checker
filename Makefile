
SHELL := /bin/bash -euo pipefail

IMAGE := replicated/volume-mount-checker
RELEASE_VERSION ?= latest

GIT_TREE = $(shell git rev-parse --is-inside-work-tree 2>/dev/null)
ifneq "$(GIT_TREE)" ""
define GIT_UPDATE_INDEX_CMD
git update-index --assume-unchanged
endef
define GIT_SHA
`git rev-parse HEAD | cut -c 1-7`
endef
else
define GIT_UPDATE_INDEX_CMD
echo "Not a git repo, skipping git update-index"
endef
define GIT_SHA
""
endef
endif

.PHONY: build
build:
	docker build --pull -t $(IMAGE):$(GIT_SHA) .

.PHONY: scan
scan:
	curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b bin
	./bin/grype --fail-on medium --only-fixed $(IMAGE):$(GIT_SHA)

.PHONY: push
push:
	docker tag $(IMAGE):$(GIT_SHA) $(IMAGE):latest
	docker push $(IMAGE):$(GIT_SHA)
	docker push $(IMAGE):latest

.PHONY: release
release:
	docker pull $(IMAGE):$(GIT_SHA)
	docker tag $(IMAGE):$(GIT_SHA) $(IMAGE):$(RELEASE_VERSION)
	docker push $(IMAGE):$(RELEASE_VERSION)

.PHONY: release-replicated
release-replicated:
	docker tag $(IMAGE):$(RELEASE_VERSION) registry.replicated.com/library/volume-mount-checker:$(RELEASE_VERSION)
	docker push registry.replicated.com/library/volume-mount-checker:$(RELEASE_VERSION)
