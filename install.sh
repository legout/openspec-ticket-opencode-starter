#!/usr/bin/env bash
# os-tk installer
# https://github.com/legout/openspec-ticket-opencode-starter
#
# Installs:
#   - os-tk binary to ~/.local/bin/os-tk
#   - config.json in current directory (project root)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/v0.1.0/install.sh | bash
#
# To pin a specific version:
#   curl -fsSL https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/<TAG>/install.sh | bash

set -euo pipefail

# =============================================================================
# VERSION (must match os-tk VERSION)
# =============================================================================
VERSION="0.5.0"

# =============================================================================
# CONFIG
# =============================================================================
REPO="legout/openspec-ticket-opencode-starter"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_FILE="config.json"

# Determine the ref we're installing from (embedded at release time, or detect from URL)
# When invoked via curl|bash from a tag URL, the VERSION above should match
INSTALL_REF="${INSTALL_REF:-v$VERSION}"

# =============================================================================
# HELPERS
# =============================================================================
info() {
  echo "[os-tk] $*"
}

error() {
  echo "[os-tk] ERROR: $*" >&2
  exit 1
}

# =============================================================================
# MAIN
# =============================================================================
main() {
  info "Installing os-tk $VERSION..."
  echo ""

  # Check for curl
  if ! command -v curl &>/dev/null; then
    error "'curl' is required but not installed."
  fi

  # Create install directory
  mkdir -p "$INSTALL_DIR"

  # Download os-tk binary
  local os_tk_url="https://raw.githubusercontent.com/$REPO/$INSTALL_REF/os-tk"
  info "Downloading os-tk from $INSTALL_REF..."
  
  if curl -fsSL "$os_tk_url" -o "$INSTALL_DIR/os-tk"; then
    chmod +x "$INSTALL_DIR/os-tk"
    info "Installed: $INSTALL_DIR/os-tk"
  else
    error "Failed to download os-tk from $os_tk_url"
  fi

  echo ""

  # We no longer create the config here. It is created by 'os-tk init'
  # in a way that is specific to the chosen agent platform(s).

  echo "=============================================================================="
  echo " os-tk $VERSION installed!"
  echo "=============================================================================="
  echo ""
  echo " IMPORTANT: Add ~/.local/bin to your PATH if not already done:"
  echo ""
  echo "   # For bash (~/.bashrc):"
  echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  echo "   # For zsh (~/.zshrc):"
  echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  echo "   # For fish (~/.config/fish/config.fish):"
  echo "   set -gx PATH \$HOME/.local/bin \$PATH"
  echo ""
  echo " After updating your shell config, restart your shell or run:"
  echo "   source ~/.bashrc  # or ~/.zshrc"
  echo ""
  echo "=============================================================================="
  echo " NEXT STEPS"
  echo "=============================================================================="
  echo ""
  echo " 1. Initialize the workflow in your project root:"
  echo "    os-tk init"
  echo ""
  echo " 2. Commit the workflow files:"
  echo "    git add config.json .opencode AGENTS.md .gitignore"
  echo "    git commit -m 'Add OpenSpec + ticket workflow'"
  echo ""
  echo "=============================================================================="
  echo " PREREQUISITES"
  echo "=============================================================================="
  echo ""
  echo " Make sure you have these CLI tools installed:"
  echo ""
  echo " 1. jq (required for os-tk)"
  echo "    brew install jq  # or: apt install jq"
  echo ""
  echo " 2. OpenSpec (spec-driven changes)"
  echo "    npm install -g @fission-ai/openspec@latest"
  echo "    openspec init  # run in your project"
  echo ""
  echo " 3. ticket (tk) (git-backed task tracking)"
  echo "    brew tap wedow/tools && brew install ticket"
  echo ""
  echo "=============================================================================="
  echo ""
}

main "$@"
