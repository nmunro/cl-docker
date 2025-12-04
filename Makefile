# Makefile

IMAGE_NAME ?= sbcl-qlot
IMAGE_TAG  ?= latest
PLATFORMS  ?= linux/arm64

.PHONY: build build-arm64 push manifest builder shell

# Ensure we have a buildx builder
builder:
	@docker buildx create --name multi-arch --use --bootstrap 2>/dev/null || \
	docker buildx use multi-arch

# Build and PUSH a multi-arch image (recommended if you use a registry)
build: builder
	@docker buildx build --platform=$(PLATFORMS) -t $(IMAGE_NAME):$(IMAGE_TAG) --load .

build-arm64: builder
	@docker buildx build --platform=linux/arm64 -t $(IMAGE_NAME):arm64 --load .

shell:
	@docker run --rm -it --entrypoint /bin/sh $(IMAGE_NAME)
