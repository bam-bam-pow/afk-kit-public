#!/usr/bin/env bash
# common.sh — Shared utilities for afk-kit scripts
# Source this file: source "$(dirname "$0")/../lib/common.sh"

set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ─── Logging ──────────────────────────────────────────────────────────────────
log_info()    { echo -e "${BLUE}[info]${NC}  $*"; }
log_success() { echo -e "${GREEN}[ok]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[warn]${NC}  $*"; }
log_error()   { echo -e "${RED}[error]${NC} $*" >&2; }
log_step()    { echo -e "\n${BOLD}${CYAN}▸ $*${NC}"; }
log_dim()     { echo -e "${DIM}  $*${NC}"; }

die() {
  log_error "$@"
  exit 1
}

# ─── Dual-mode ask() ─────────────────────────────────────────────────────────
# Usage: result=$(ask "Prompt text" "DEFAULT_VALUE" "CLI_FLAG_VALUE")
#
# In interactive mode (CLI_FLAG_VALUE is empty): prompts the user
# In non-interactive mode (CLI_FLAG_VALUE is set): uses the flag value
# If NON_INTERACTIVE=1 and no flag value: uses default
ask() {
  local prompt="$1"
  local default="${2:-}"
  local flag_value="${3:-}"

  # If a CLI flag was provided, use it directly
  if [[ -n "$flag_value" ]]; then
    echo "$flag_value"
    return
  fi

  # Non-interactive mode: use default or fail
  if [[ "${NON_INTERACTIVE:-0}" == "1" ]]; then
    if [[ -n "$default" ]]; then
      echo "$default"
      return
    fi
    die "Non-interactive mode requires --$(echo "$prompt" | tr '[:upper:]' '[:lower:]' | tr ' ' '-') flag"
  fi

  # Interactive: prompt the user
  local reply
  if [[ -n "$default" ]]; then
    read -rp "$(echo -e "${BOLD}$prompt${NC} [$default]: ")" reply
    echo "${reply:-$default}"
  else
    read -rp "$(echo -e "${BOLD}$prompt${NC}: ")" reply
    echo "$reply"
  fi
}

# ─── Confirm (y/N) ───────────────────────────────────────────────────────────
# Returns 0 for yes, 1 for no
confirm() {
  local prompt="$1"
  local default="${2:-n}"

  if [[ "${NON_INTERACTIVE:-0}" == "1" ]]; then
    [[ "$default" =~ ^[Yy] ]] && return 0 || return 1
  fi

  local reply
  if [[ "$default" =~ ^[Yy] ]]; then
    read -rp "$(echo -e "${BOLD}$prompt${NC} [Y/n]: ")" reply
    [[ "${reply:-y}" =~ ^[Yy] ]]
  else
    read -rp "$(echo -e "${BOLD}$prompt${NC} [y/N]: ")" reply
    [[ "$reply" =~ ^[Yy] ]]
  fi
}

# ─── Slugify ──────────────────────────────────────────────────────────────────
# "My Feature Name" → "my-feature-name"
slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# ─── Date helpers ─────────────────────────────────────────────────────────────
today() {
  date +%Y-%m-%d
}

now_iso() {
  date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z
}

timestamp() {
  date +%H:%M
}

# ─── Tool checks ─────────────────────────────────────────────────────────────
require_tool() {
  local tool="$1"
  local install_hint="${2:-}"
  if ! command -v "$tool" &>/dev/null; then
    if [[ -n "$install_hint" ]]; then
      die "'$tool' not found. Install: $install_hint"
    else
      die "'$tool' not found. Please install it and try again."
    fi
  fi
}

require_tools() {
  for tool in "$@"; do
    require_tool "$tool"
  done
}

# ─── JSON helpers (using python for portability) ──────────────────────────────
# Read a key from a JSON file
json_get() {
  local file="$1"
  local key="$2"
  python3 -c "import json,sys; d=json.load(open('$file')); print(d$(echo "$key" | sed "s/\./']['/g" | sed "s/^/['/;s/$/']/" ))" 2>/dev/null || echo ""
}

# Check if a JSON file is valid
json_valid() {
  python3 -c "import json; json.load(open('$1'))" 2>/dev/null
}

# ─── DRY_RUN support ─────────────────────────────────────────────────────────
# Wraps a command — if DRY_RUN=1, prints it instead of executing
run() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_dim "[dry-run] $*"
    return 0
  fi
  "$@"
}

# ─── Resolve AFK_HOME ────────────────────────────────────────────────────
AFK_HOME="${AFK_HOME:-$HOME/.afk}"

# ─── Path to this repo (for templates, skills, etc.) ─────────────────────────
# Resolved from the sourcing script's location
resolve_repo_root() {
  local source_dir
  source_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
  # bin/ → repo root, lib/ → repo root
  if [[ "$(basename "$source_dir")" == "bin" || "$(basename "$source_dir")" == "lib" ]]; then
    echo "$(dirname "$source_dir")"
  else
    echo "$source_dir"
  fi
}
