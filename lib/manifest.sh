#!/usr/bin/env bash
# manifest.sh — Handoff manifest read/write/validate
# Source after common.sh

MANIFEST_VERSION="1.0"

# ─── Write handoff manifest ──────────────────────────────────────────────────
manifest_write() {
  local output_path="$1"
  local feature_name="$2"
  local feature_slug="$3"
  local project_dir="$4"
  local repo_url="$5"
  local branch="$6"
  local has_backend="$7"
  local has_frontend="$8"
  local docker_profile="$9"
  local session_dir="${10}"

  python3 -c "
import json, os

manifest = {
    'version': '$MANIFEST_VERSION',
    'created_at': '$(now_iso)',
    'feature': {
        'name': '$feature_name',
        'slug': '$feature_slug'
    },
    'project': {
        'directory': '$project_dir',
        'repo_url': '$repo_url',
        'branch': '$branch'
    },
    'stack': {
        'has_backend': '$has_backend'.lower() in ('true', '1', 'yes'),
        'has_frontend': '$has_frontend'.lower() in ('true', '1', 'yes'),
        'docker_profile': '$docker_profile'
    },
    'artifacts': {
        'session_dir': '$session_dir',
        'intake': os.path.join('$session_dir', '00-INTAKE.md'),
        'research': os.path.join('$session_dir', '01-RESEARCH.md'),
        'prd': os.path.join('$session_dir', '02-PRD.md'),
        'edd': os.path.join('$session_dir', '03-EDD.md'),
        'conflict_resolution': os.path.join('$session_dir', '04-CONFLICT-RESOLUTION.md'),
        'claude_md_sprint': os.path.join('$session_dir', 'CLAUDE-MD-SPRINT-SECTION.md')
    },
    'status': 'ready_for_build'
}

with open('$output_path', 'w') as f:
    json.dump(manifest, f, indent=2)
"
  log_success "Wrote manifest: $output_path"
}

# ─── Read manifest field ─────────────────────────────────────────────────────
manifest_get() {
  local manifest_path="$1"
  local key_path="$2"  # dot-separated: e.g. "feature.slug"

  python3 -c "
import json, sys
with open('$manifest_path') as f:
    d = json.load(f)
keys = '$key_path'.split('.')
for k in keys:
    d = d[k]
print(d)
" 2>/dev/null || echo ""
}

# ─── Validate manifest ───────────────────────────────────────────────────────
manifest_validate() {
  local manifest_path="$1"

  if [[ ! -f "$manifest_path" ]]; then
    die "Manifest not found: $manifest_path"
  fi

  if ! json_valid "$manifest_path"; then
    die "Manifest is not valid JSON: $manifest_path"
  fi

  local version
  version=$(manifest_get "$manifest_path" "version")
  if [[ "$version" != "$MANIFEST_VERSION" ]]; then
    die "Unsupported manifest version: $version (expected $MANIFEST_VERSION)"
  fi

  local status
  status=$(manifest_get "$manifest_path" "status")
  if [[ "$status" != "ready_for_build" ]]; then
    log_warn "Manifest status is '$status', expected 'ready_for_build'"
  fi

  # Check required artifacts exist
  local required_artifacts=("prd" "edd" "claude_md_sprint")
  for art in "${required_artifacts[@]}"; do
    local path
    path=$(manifest_get "$manifest_path" "artifacts.$art")
    if [[ ! -f "$path" ]]; then
      log_warn "Required artifact missing: $art ($path)"
    fi
  done

  log_success "Manifest validated: $manifest_path"
}

# ─── Find most recent manifest ───────────────────────────────────────────────
manifest_find_latest() {
  local search_dir="${AFK_HOME}/prd-sessions"

  if [[ ! -d "$search_dir" ]]; then
    die "No prd-sessions directory found at $search_dir"
  fi

  local latest
  latest=$(find "$search_dir" -name "handoff-manifest.json" -type f 2>/dev/null | sort -r | head -1)

  if [[ -z "$latest" ]]; then
    die "No manifests found in $search_dir"
  fi

  echo "$latest"
}

# ─── Find manifest by session slug ───────────────────────────────────────────
manifest_find_by_session() {
  local slug="$1"
  local search_dir="${AFK_HOME}/prd-sessions"

  local match
  match=$(find "$search_dir" -path "*${slug}*/handoff-manifest.json" -type f 2>/dev/null | head -1)

  if [[ -z "$match" ]]; then
    die "No manifest found for session: $slug"
  fi

  echo "$match"
}

# ─── Check for unresolved blockers ───────────────────────────────────────────
manifest_check_blockers() {
  local manifest_path="$1"

  local conflict_file
  conflict_file=$(manifest_get "$manifest_path" "artifacts.conflict_resolution")

  if [[ ! -f "$conflict_file" ]]; then
    log_dim "No conflict resolution file found (skipping blocker check)"
    return 0
  fi

  local blocker_count
  blocker_count=$(grep -ci "BLOCKER" "$conflict_file" 2>/dev/null || echo "0")

  if (( blocker_count > 0 )); then
    log_warn "Found $blocker_count potential BLOCKER(s) in conflict resolution"
    log_warn "Review: $conflict_file"
    if ! confirm "Continue despite blockers?"; then
      die "Resolve blockers before building"
    fi
  fi
}
