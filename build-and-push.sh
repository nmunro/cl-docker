#!/usr/bin/env bash
set -euo pipefail

# Ensure we operate in the repository root directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "=================================================="
echo " Starting build and push for cl-web"
echo "=================================================="

# Pre-flight checks
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is not installed or not in PATH." >&2
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running or unreachable." >&2
    exit 1
fi

if ! command -v just >/dev/null 2>&1; then
    echo "Error: just is not installed or not in PATH." >&2
    exit 1
fi

# Print tags to be built and pushed
echo "Tags to be built and pushed:"
just tags
echo "=================================================="

# Execute build and push for all variants
echo "Building and pushing all image variants..."
just push-all

echo "=================================================="
echo " Successfully built and pushed all variants!"
echo "=================================================="
