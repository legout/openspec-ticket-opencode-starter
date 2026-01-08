#!/usr/bin/env bash
# OpenSpec + Ticket + OpenCode Starter Kit - Installer
# https://github.com/legout/openspec-ticket-opencode-starter

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/main"

# Files to install
OPENCODE_FILES=(
  ".opencode/agent/flow.md"
  ".opencode/command/os-show.md"
  ".opencode/command/os-status.md"
  ".opencode/command/tk-bootstrap.md"
  ".opencode/command/tk-close-and-sync.md"
  ".opencode/command/tk-queue.md"
)

echo "Installing OpenSpec + Ticket + OpenCode Starter Kit..."

# Create directories
mkdir -p .opencode/agent .opencode/command

# Download .opencode files
for file in "${OPENCODE_FILES[@]}"; do
  echo "  → $file"
  curl -sSL "$REPO_URL/$file" -o "$file"
done

# Handle AGENTS.md (append if exists, create if not)
AGENTS_CONTENT=$(curl -sSL "$REPO_URL/AGENTS.md")
if [[ -f "AGENTS.md" ]]; then
  echo "  → AGENTS.md (appending to existing file)"
  echo -e "\n\n---\n" >> AGENTS.md
  echo "$AGENTS_CONTENT" >> AGENTS.md
else
  echo "  → AGENTS.md (creating new file)"
  echo "$AGENTS_CONTENT" > AGENTS.md
fi

echo ""
echo "✓ Workflow files installed!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PREREQUISITES: Make sure you have these CLI tools installed:"
echo ""
echo "  1. OpenSpec (spec-driven changes)"
echo "     npm install -g @fission-ai/openspec@latest"
echo "     Then run: openspec init"
echo ""
echo "  2. ticket (tk) (git-backed task tracking)"
echo "     brew tap wedow/tools && brew install ticket"
echo "     (or see: https://github.com/wedow/ticket)"
echo ""
echo "  3. jq (optional, for 'tk query')"
echo "     brew install jq  # or: apt install jq"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "NEXT STEPS:"
echo "  1. git add AGENTS.md .opencode"
echo "  2. git commit -m 'Add OpenSpec + ticket + OpenCode workflow'"
echo ""
