SEVERITIES = HIGH,CRITICAL

UNAME_M = $(shell uname -m)
ARCH=
ifeq ($(UNAME_M), x86_64)
	ARCH=amd64
else ifeq ($(UNAME_M), aarch64)
	ARCH=arm64
else 
	ARCH=$(UNAME_M)
endif

BUILD_META=-build$(shell date +%Y%m%d)
ORG ?= rancher
# last commit on 2021-10-06
TAG ?= v3.5.1$(BUILD_META)

ifneq ($(DRONE_TAG),)
	TAG := $(DRONE_TAG)
endif

ifeq (,$(filter %$(BUILD_META),$(TAG)))
$(error TAG needs to end with build metadata: $(BUILD_META))
endif

.PHONY: image-build
image-build:
	docker build \
		--pull \
		--build-arg ARCH=$(ARCH) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
		--tag $(ORG)/hardened-sriov-network-device-plugin:$(TAG) \
		--tag $(ORG)/hardened-sriov-network-device-plugin:$(TAG)-$(ARCH) \
	.

.PHONY: image-push
image-push:
	docker push $(ORG)/hardened-sriov-network-device-plugin:$(TAG)-$(ARCH)

.PHONY: image-manifest
image-manifest:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend \
		$(ORG)/hardened-sriov-network-device-plugin:$(TAG) \
		$(ORG)/hardened-sriov-network-device-plugin:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push \
		$(ORG)/hardened-sriov-network-device-plugin:$(TAG)

.PHONY: image-scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed $(ORG)/hardened-sriov-network-device-plugin:$(TAG)
