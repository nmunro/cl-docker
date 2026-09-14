# Makefile

IMAGE_NAME       ?= nmunro/cl-web
IMAGE_TAG        ?= 26.09-2
SBCL_VERSION_TAG ?= 2.6.8
PLATFORMS        ?= linux/arm64,linux/amd64

# Tags
TAG_RELEASE_SBCL = $(IMAGE_NAME):$(IMAGE_TAG)-sbcl-$(SBCL_VERSION_TAG)
TAG_RELEASE      = $(IMAGE_NAME):$(IMAGE_TAG)
TAG_SBCL         = $(IMAGE_NAME):sbcl-$(SBCL_VERSION_TAG)
TAG_LATEST       = $(IMAGE_NAME):latest

TAG_FLAGS        = -t $(TAG_RELEASE_SBCL) -t $(TAG_RELEASE) -t $(TAG_SBCL) -t $(TAG_LATEST)
BUILD_ARGS       = --build-arg SBCL_VERSION=sbcl-bin/$(SBCL_VERSION_TAG)

BUILD_PLATFORM   = $(if $(LOCAL),,--platform=$(PLATFORMS))
BUILD_OUTPUT     = $(if $(LOCAL),--load,--push)

.PHONY: build push load shell builder tags

# Ensure we have a buildx builder
builder:
	@docker buildx create --name multi-arch --use --bootstrap 2>/dev/null || \
	docker buildx use multi-arch

# Build locally (single-arch, --load) if LOCAL is set, otherwise push multi-arch
build: builder
	@docker buildx build $(BUILD_PLATFORM) $(BUILD_ARGS) $(TAG_FLAGS) $(BUILD_OUTPUT) .

push: builder
	@docker buildx build --platform=$(PLATFORMS) $(BUILD_ARGS) $(TAG_FLAGS) --push .

load: builder
	@docker buildx build $(BUILD_ARGS) $(TAG_FLAGS) --load .

tags:
	@echo "Tags to be built and pushed:"
	@echo "  - $(TAG_RELEASE_SBCL)"
	@echo "  - $(TAG_RELEASE)"
	@echo "  - $(TAG_SBCL)"
	@echo "  - $(TAG_LATEST)"

shell:
	@docker run --rm -it --entrypoint /bin/sh $(TAG_RELEASE_SBCL)
