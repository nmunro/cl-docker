# Makefile

IMAGE_NAME     ?= nmunro/roswell
IMAGE_TAG      ?= 1.0.2
PLATFORMS      ?= linux/arm64,linux/amd64
BUILD_PLATFORM  = $(if $(LOCAL),,--platform=$(PLATFORMS))
BUILD_OUTPUT    = $(if $(LOCAL),--load,--push)

.PHONY: build build-arm64 push manifest builder shell

# Ensure we have a buildx builder
builder:
	@docker buildx create --name multi-arch --use --bootstrap 2>/dev/null || \
	docker buildx use multi-arch

# Build locally (single-arch, --load) if LOCAL is set, otherwise push multi-arch
build: builder
	@docker buildx build $(BUILD_PLATFORM) -t $(IMAGE_NAME):$(IMAGE_TAG) $(BUILD_OUTPUT) .

push: builder
	@docker buildx build --platform=$(PLATFORMS) -t $(IMAGE_NAME):$(IMAGE_TAG) --push .

shell:
	@docker run --rm -it --entrypoint /bin/sh $(IMAGE_NAME)
