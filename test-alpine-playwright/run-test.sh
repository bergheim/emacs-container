#!/bin/bash
# Run this from the HOST machine (not inside the devcontainer)
# Usage: ./run-test.sh

set -e

cd "$(dirname "$0")"

echo "Building Alpine + Playwright test image..."
podman build -t alpine-playwright-test .

echo ""
echo "Running tests..."
podman run --rm alpine-playwright-test

echo ""
echo "Checking generated files..."
# Run again to copy files out
podman run --rm -v "$(pwd)/output:/output" alpine-playwright-test sh -c '
  node test.js && cp /tmp/screenshot.png /tmp/page.pdf /output/ 2>/dev/null || true
'

if [[ -f output/screenshot.png ]]; then
  echo "Screenshot size: $(du -h output/screenshot.png | cut -f1)"
fi
if [[ -f output/page.pdf ]]; then
  echo "PDF size: $(du -h output/page.pdf | cut -f1)"
fi
