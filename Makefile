
SHELL := /bin/bash -euo pipefail

IMAGE := replicated/volume-mount-checker
RELEASE_VERSION :=`git describe --tags --dirty`

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
	docker build -t $(IMAGE):$(GIT_SHA) .

.PHONY: push
push:
	docker tag $(IMAGE):$(GIT_SHA) $(IMAGE):latest
	docker push $(IMAGE):$(GIT_SHA)
	docker push $(IMAGE):latest

.PHONY: release
release:
	docker pull $(IMAGE):$(GIT_SHA)
	docker tag $(IMAGE):$(GIT_SHA) $(IMAGE):$(VERSION)
	docker push $(IMAGE):$(RELEASE_VERSION)
