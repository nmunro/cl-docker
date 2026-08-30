variable "IMAGE_NAME" {
  default = "nmunro/cl-web"
}

variable "IMAGE_TAG" {
  default = "26.09-1"
}

variable "SBCL_VERSION_TAG" {
  default = "2.6.8"
}

variable "PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

group "default" {
  targets = ["prod"]
}

target "docker-metadata-action" {}

target "_base" {
  inherits   = ["docker-metadata-action"]
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    SBCL_VERSION = "sbcl-bin/${SBCL_VERSION_TAG}"
  }
}

target "build-stage" {
  inherits = ["_base"]
  target   = "build"
  tags     = [
    "${IMAGE_NAME}:build",
    "${IMAGE_NAME}:${IMAGE_TAG}-sbcl-${SBCL_VERSION_TAG}-build",
  ]
}

target "prod" {
  inherits  = ["_base"]
  target    = "prod"
  platforms = PLATFORMS
  tags = [
    "${IMAGE_NAME}:${IMAGE_TAG}-sbcl-${SBCL_VERSION_TAG}",
    "${IMAGE_NAME}:${IMAGE_TAG}",
    "${IMAGE_NAME}:sbcl-${SBCL_VERSION_TAG}",
    "${IMAGE_NAME}:latest",
  ]
}

