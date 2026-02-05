#!/bin/bash
# Test all 3 browser tools on Alpine
# Run from HOST machine

set -e
cd "$(dirname "$0")"

echo "Building Alpine full test image (playwright + agent-browser + webctl)..."
podman build -f Containerfile.full -t alpine-browser-full .

echo ""
echo "Running full test..."
podman run --rm alpine-browser-full
