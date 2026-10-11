# Justfile for cl-web

# Configuration
image_name       := env_var_or_default("IMAGE_NAME", "nmunro/cl-web")
image_tag        := env_var_or_default("IMAGE_TAG", "26.09-4")
default_sbcl     := env_var_or_default("SBCL_VERSION_TAG", "2.6.9")
sbcl_versions    := env_var_or_default("SBCL_VERSIONS", "2.6.9 2.6.8 2.6.7 2.6.6")
platforms        := env_var_or_default("PLATFORMS", "linux/arm64,linux/amd64")
local_env        := env_var_or_default("LOCAL", "")

# List available recipes
default:
    @just --justfile {{justfile()}} --list

# Ensure buildx multi-arch builder exists and is active
builder:
    @docker buildx create --name multi-arch --use --bootstrap 2>/dev/null || docker buildx use multi-arch

# Build an image (multi-arch push by default, or single-arch --load if local is set)
build sbcl=default_sbcl local=local_env: builder
    docker buildx build \
        {{ if local != "" { "" } else { "--platform=" + platforms } }} \
        --build-arg SBCL_VERSION=sbcl-bin/{{sbcl}} \
        -t {{image_name}}:{{image_tag}}-sbcl-{{sbcl}} \
        -t {{image_name}}:sbcl-{{sbcl}} \
        {{ if sbcl == default_sbcl { "-t " + image_name + ":" + image_tag + " -t " + image_name + ":latest" } else { "" } }} \
        {{ if local != "" { "--load" } else { "--push" } }} .

# Build all SBCL variants (multi-arch push, or load if local is set)
build-all local=local_env: builder
    @for ver in {{sbcl_versions}}; do \
        just build "$ver" "{{local}}"; \
    done

# Build and push multi-arch image for a specific SBCL version
push sbcl=default_sbcl: builder
    docker buildx build \
        --platform={{platforms}} \
        --build-arg SBCL_VERSION=sbcl-bin/{{sbcl}} \
        -t {{image_name}}:{{image_tag}}-sbcl-{{sbcl}} \
        -t {{image_name}}:sbcl-{{sbcl}} \
        {{ if sbcl == default_sbcl { "-t " + image_name + ":" + image_tag + " -t " + image_name + ":latest" } else { "" } }} \
        --push .

# Build and push multi-arch images for all SBCL variants
push-all: builder
    @for ver in {{sbcl_versions}}; do \
        just -f {{justfile()}} push "$ver"; \
    done

# Build locally for current architecture and load into Docker
load sbcl=default_sbcl: builder
    docker buildx build \
        --build-arg SBCL_VERSION=sbcl-bin/{{sbcl}} \
        -t {{image_name}}:{{image_tag}}-sbcl-{{sbcl}} \
        -t {{image_name}}:sbcl-{{sbcl}} \
        {{ if sbcl == default_sbcl { "-t " + image_name + ":" + image_tag + " -t " + image_name + ":latest" } else { "" } }} \
        --load .

# Build locally and load all SBCL variants into Docker
load-all: builder
    @for ver in {{sbcl_versions}}; do \
        just -f {{justfile()}} load "$ver"; \
    done

# Display tags to be built (for a specific version or all variants)
tags sbcl="":
    #!/usr/bin/env sh
    show_tags() {
        ver="$1"
        echo "SBCL ${ver}:"
        echo "  - {{image_name}}:{{image_tag}}-sbcl-${ver}"
        echo "  - {{image_name}}:sbcl-${ver}"
        if [ "$ver" = "{{default_sbcl}}" ]; then
            echo "  - {{image_name}}:{{image_tag}}"
            echo "  - {{image_name}}:latest"
        fi
    }
    if [ -n "{{sbcl}}" ]; then
        show_tags "{{sbcl}}"
    else
        echo "Tags across all variants:"
        for ver in {{sbcl_versions}}; do
            show_tags "$ver"
        done
    fi

# Run an interactive shell in the container
shell sbcl=default_sbcl:
    @docker run --rm -it --entrypoint /bin/sh {{image_name}}:{{image_tag}}-sbcl-{{sbcl}}
