#!/usr/bin/env bash
# setup.sh — Install afk-kit to ~/.afk/ and symlink bins
#
# Usage:
#   ./setup.sh                          Install afk-kit tools
#   ./setup.sh --target-project PATH    Also bootstrap governance templates into a project
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AFK_HOME="${AFK_HOME:-$HOME/.afk}"
BIN_DIR="${HOME}/.local/bin"
TARGET_PROJECT=""

# ─── Parse arguments ────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-project)
      TARGET_PROJECT="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: ./setup.sh [--target-project PATH]"
      echo ""
      echo "Options:"
      echo "  --target-project PATH   Bootstrap governance templates into a project directory"
      echo "  --help, -h              Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run ./setup.sh --help for usage"
      exit 1
      ;;
  esac
done

echo ""
echo "afk-kit setup"
echo "============="
echo ""
echo "Repo:       $SCRIPT_DIR"
echo "Home:       $AFK_HOME"
echo "Bin:        $BIN_DIR"
if [[ -n "$TARGET_PROJECT" ]]; then
  echo "Target:     $TARGET_PROJECT"
fi
echo ""

# ─── Create directories ──────────────────────────────────────────────────────
echo "Creating directories..."
mkdir -p "$AFK_HOME"/{skills,prd-sessions,builds,learning}
mkdir -p "$BIN_DIR"
echo "  [ok] Directories created"

# ─── Copy skills ──────────────────────────────────────────────────────────────
echo "Installing skills..."
if [[ -d "$SCRIPT_DIR/skills" ]]; then
  cp -R "$SCRIPT_DIR/skills/"* "$AFK_HOME/skills/"
  echo "  [ok] Skills copied to $AFK_HOME/skills/"
else
  echo "  [warn] No skills directory found in repo"
fi

# ─── Copy learning seed file ─────────────────────────────────────────────────
if [[ -f "$SCRIPT_DIR/learning/QUALITY-PATTERNS.md" && ! -f "$AFK_HOME/learning/QUALITY-PATTERNS.md" ]]; then
  cp "$SCRIPT_DIR/learning/QUALITY-PATTERNS.md" "$AFK_HOME/learning/"
  echo "  [ok] Quality patterns seed file installed"
else
  echo "  [skip] Quality patterns already exist"
fi

# ─── Symlink bins ─────────────────────────────────────────────────────────────
echo "Symlinking binaries..."
for script in "$SCRIPT_DIR/bin/"*; do
  name=$(basename "$script")
  chmod +x "$script"
  ln -sf "$script" "$BIN_DIR/$name"
  echo "  [ok] $name → $BIN_DIR/$name"
done

# ─── Make lib scripts executable ──────────────────────────────────────────────
chmod +x "$SCRIPT_DIR/lib/"*.sh 2>/dev/null || true

# ─── Copy MCP config template ────────────────────────────────────────────────
if [[ -f "$SCRIPT_DIR/.mcp.json.template" && ! -f "$AFK_HOME/.mcp.json" ]]; then
  cp "$SCRIPT_DIR/.mcp.json.template" "$AFK_HOME/.mcp.json"
  echo "  [ok] MCP config template copied (edit $AFK_HOME/.mcp.json with your API keys)"
else
  echo "  [skip] MCP config already exists"
fi

# ─── Verify PATH ─────────────────────────────────────────────────────────────
echo ""
if echo "$PATH" | tr ':' '\n' | grep -q "$BIN_DIR"; then
  echo "[ok] $BIN_DIR is on your PATH"
else
  echo "[warn] $BIN_DIR is NOT on your PATH"
  echo ""
  echo "Add to your shell config (~/.zshrc or ~/.bashrc):"
  echo ""
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
fi

# ─── Bootstrap target project (optional) ────────────────────────────────────
if [[ -n "$TARGET_PROJECT" ]]; then
  echo ""
  echo "Bootstrapping governance templates into $TARGET_PROJECT..."

  mkdir -p "$TARGET_PROJECT/docs/decisions"

  # Copy CONSTITUTION.md
  if [[ -f "$SCRIPT_DIR/templates/CONSTITUTION.md" && ! -f "$TARGET_PROJECT/CONSTITUTION.md" ]]; then
    cp "$SCRIPT_DIR/templates/CONSTITUTION.md" "$TARGET_PROJECT/CONSTITUTION.md"
    echo "  [ok] CONSTITUTION.md copied"
  else
    echo "  [skip] CONSTITUTION.md already exists"
  fi

  # Copy ADR template
  if [[ -f "$SCRIPT_DIR/templates/ADR_TEMPLATE.md" && ! -f "$TARGET_PROJECT/docs/decisions/000-template.md" ]]; then
    cp "$SCRIPT_DIR/templates/ADR_TEMPLATE.md" "$TARGET_PROJECT/docs/decisions/000-template.md"
    echo "  [ok] ADR template copied to docs/decisions/"
  else
    echo "  [skip] ADR template already exists"
  fi

  # Copy COMMIT_TEMPLATE.md
  if [[ -f "$SCRIPT_DIR/templates/COMMIT_TEMPLATE.md" && ! -f "$TARGET_PROJECT/COMMIT_TEMPLATE.md" ]]; then
    cp "$SCRIPT_DIR/templates/COMMIT_TEMPLATE.md" "$TARGET_PROJECT/COMMIT_TEMPLATE.md"
    echo "  [ok] COMMIT_TEMPLATE.md copied"
  else
    echo "  [skip] COMMIT_TEMPLATE.md already exists"
  fi

  # Create .overnight-config from template
  if [[ -f "$SCRIPT_DIR/templates/overnight-config.template" && ! -f "$TARGET_PROJECT/.overnight-config" ]]; then
    cp "$SCRIPT_DIR/templates/overnight-config.template" "$TARGET_PROJECT/.overnight-config"
    echo "  [ok] .overnight-config created"
  else
    echo "  [skip] .overnight-config already exists"
  fi

  # Copy CLAUDE.md template if not present
  if [[ -f "$SCRIPT_DIR/templates/CLAUDE.md.template" && ! -f "$TARGET_PROJECT/CLAUDE.md" ]]; then
    cp "$SCRIPT_DIR/templates/CLAUDE.md.template" "$TARGET_PROJECT/CLAUDE.md"
    echo "  [ok] CLAUDE.md template copied"
  else
    echo "  [skip] CLAUDE.md already exists"
  fi

  # Append session artifacts to .gitignore
  if [[ -f "$TARGET_PROJECT/.gitignore" ]]; then
    if ! grep -q "PROGRESS.md" "$TARGET_PROJECT/.gitignore" 2>/dev/null; then
      echo -e "\n# Overnight session files\nPROGRESS.md\nMORNING_SUMMARY.md\n.overnight-config" >> "$TARGET_PROJECT/.gitignore"
      echo "  [ok] Session artifacts added to .gitignore"
    else
      echo "  [skip] .gitignore already has session entries"
    fi
  fi

  echo ""
  echo "Target project bootstrapped. Files added:"
  echo "  CONSTITUTION.md"
  echo "  COMMIT_TEMPLATE.md"
  echo "  CLAUDE.md"
  echo "  docs/decisions/000-template.md"
  echo "  .overnight-config"
fi

# ─── Verify installation ─────────────────────────────────────────────────────
echo ""
echo "Installed files:"
echo ""
echo "  ~/.afk/"
find "$AFK_HOME" -maxdepth 2 -type f | sed "s|$AFK_HOME|  |" | sort | head -20
TOTAL=$(find "$AFK_HOME" -type f | wc -l | tr -d ' ')
echo "  ... ($TOTAL files total)"
echo ""
echo "Commands available:"
for script in "$SCRIPT_DIR/bin/"*; do
  echo "  $(basename "$script")"
done
echo ""
echo "Setup complete. Run 'afk-plan --help' to get started."
echo ""
