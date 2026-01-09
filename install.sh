#!/usr/bin/env bash
# OpenSpec + Ticket + OpenCode Starter Kit - Installer
# https://github.com/legout/openspec-ticket-opencode-starter

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/main"

# Files to install
OPENCODE_FILES=(
  ".opencode/agent/os-tk-agent.md"
  ".opencode/command/os-proposal.md"
  ".opencode/command/os-show.md"
  ".opencode/command/os-status.md"
  ".opencode/command/tk-bootstrap.md"
  ".opencode/command/tk-close-and-sync.md"
  ".opencode/command/tk-queue.md"
  ".opencode/command/tk-refactor.md"
  ".opencode/command/tk-start.md"
  ".opencode/command/tk-start-multi.md"
  ".opencode/skill/openspec/SKILL.md"
  ".opencode/skill/ticket/SKILL.md"
)

echo "Installing OpenSpec + Ticket + OpenCode Starter Kit..."

# Create directories
mkdir -p .opencode/agent .opencode/command .opencode/skill/openspec .opencode/skill/ticket

# Download .opencode files (overwrites existing)
for file in "${OPENCODE_FILES[@]}"; do
  echo "  → $file"
  curl -sSL "$REPO_URL/$file" -o "$file"
done

# Handle AGENTS.md with markers
MARKER_START="<!-- OPENSPEC-TK-START -->"
MARKER_END="<!-- OPENSPEC-TK-END -->"

# Download new AGENTS.md content (includes markers)
NEW_AGENTS=$(curl -sSL "$REPO_URL/AGENTS.md")

if [[ -f "AGENTS.md" ]]; then
  echo "  → AGENTS.md (updating existing file)"

  # Check if markers exist
  if grep -q "$MARKER_START" AGENTS.md; then
    # Remove old content between markers (inclusive) and append new content
    # Using perl for cross-platform compatibility (GNU and BSD sed differ for multiline)
    perl -i -0pe "s/\Q$MARKER_START\E.*?\Q$MARKER_END\E//gs" AGENTS.md || true
    echo "$NEW_AGENTS" >> AGENTS.md
  else
    # No markers exist - just append
    echo "" >> AGENTS.md
    echo "$NEW_AGENTS" >> AGENTS.md
  fi
else
  echo "  → AGENTS.md (creating new file)"
  echo "$NEW_AGENTS" > AGENTS.md
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
echo ""
echo "  4. oh-my-opencode (optional, for orchestration)"
echo "     Prompt OpenCode: \"Install and configure oh-my-opencode\""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "NEXT STEPS:"
echo "  1. git add AGENTS.md .opencode"
echo "  2. git commit -m 'Add OpenSpec + ticket + OpenCode workflow'"
echo ""
