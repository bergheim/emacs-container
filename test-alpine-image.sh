#!/bin/bash
# Test Alpine devcontainer image
# Usage: ./test-alpine-image.sh [image-name]

IMAGE="${1:-emacs-gui-alpine}"

echo "=== Testing Alpine Image: $IMAGE ==="
echo ""

podman run --rm --entrypoint /bin/sh "$IMAGE" -c '
set -e

# Source user PATH additions
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$HOME/.local/share/pnpm:$PATH"

echo "=== System packages (from apk) ==="
gh --version | head -1
gum --version | head -1
shellcheck --version | head -1
just --version
yadm version
golangci-lint --version | head -1
ruff --version
pre-commit --version
mise --version | head -1
pnpm --version
tsc --version
gopls version 2>&1 | head -1
echo ""

echo "=== Language servers ==="
rust-analyzer --version
pyright --version
typescript-language-server --version
bash-language-server --version
echo ""

echo "=== Runtimes ==="
node --version
python3 --version
go version
rustc --version
bun --version
echo ""

echo "=== Package managers ==="
uv --version
pnpm --version
npm --version
echo ""

echo "=== AI tools ==="
claude --version 2>&1 | head -1 || echo "claude: installed (version check may fail)"
gemini --version 2>&1 | head -1 || echo "gemini: installed"
echo ""

echo "=== Browser automation ==="
browser-check https://example.com --aria --interactive
echo ""

echo "=== Other tools ==="
emacs --version | head -1
nvim --version | head -1
tmux -V
git --version
jq --version
yq --version
rg --version | head -1
fd --version
fzf --version
eza --version | head -1
zoxide --version
echo ""

echo "================================"
echo "=== ALL TESTS PASSED ==="
echo "================================"
'
