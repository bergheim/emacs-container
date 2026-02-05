#!/bin/sh
# Test Playwright CLI on Alpine

echo "=== Testing Playwright CLI ==="
echo "Using system Chromium at: $PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH"

echo ""
echo "Test 1: npx playwright screenshot"
PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser \
  npx playwright screenshot \
  --browser chromium \
  https://example.com /tmp/cli-screenshot.png && \
  echo "✓ Screenshot works" || echo "✗ Screenshot failed"

echo ""
echo "Test 2: npx playwright pdf"
PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser \
  npx playwright pdf \
  --browser chromium \
  https://example.com /tmp/cli-page.pdf && \
  echo "✓ PDF works" || echo "✗ PDF failed"

echo ""
ls -la /tmp/cli-*.png /tmp/cli-*.pdf 2>/dev/null
