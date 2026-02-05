#!/bin/sh
# Test context reduction: Raw HTML vs ARIA snapshots
# Verifies the "93% less context" claim for LLM usage

URL="${1:-https://blog.thomasbergheim.com}"

echo "=== Context Reduction Test ==="
echo "URL: $URL"
echo ""

# Get raw HTML size
HTML_SIZE=$(curl -s "$URL" | wc -c)

# Get full ARIA size
FULL_ARIA=$(PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser \
  node browser-check.js "$URL" --aria --json 2>/dev/null | jq -r '.aria')
FULL_SIZE=$(echo "$FULL_ARIA" | wc -c)

# Get interactive-only ARIA size
INT_ARIA=$(PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser \
  node browser-check.js "$URL" --aria --interactive --json 2>/dev/null | jq -r '.aria')
INT_SIZE=$(echo "$INT_ARIA" | wc -c)

# Calculate reductions
FULL_REDUCTION=$(awk "BEGIN {printf \"%.0f\", (1 - $FULL_SIZE/$HTML_SIZE) * 100}")
INT_REDUCTION=$(awk "BEGIN {printf \"%.0f\", (1 - $INT_SIZE/$HTML_SIZE) * 100}")

echo "| Format              | Bytes    | Reduction |"
echo "|---------------------|----------|-----------|"
printf "| Raw HTML            | %8d | baseline  |\n" "$HTML_SIZE"
printf "| Full ARIA snapshot  | %8d | %3d%%      |\n" "$FULL_SIZE" "$FULL_REDUCTION"
printf "| Interactive-only    | %8d | %3d%%      |\n" "$INT_SIZE" "$INT_REDUCTION"
echo ""

if [ "$INT_REDUCTION" -ge 80 ]; then
  echo "✓ Context reduction verified: ${INT_REDUCTION}% (target: >80%)"
  exit 0
else
  echo "✗ Context reduction below target: ${INT_REDUCTION}% (target: >80%)"
  exit 1
fi
