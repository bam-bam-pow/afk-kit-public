#!/usr/bin/env bash
# git-helpers.sh — Git operations for afk-build
# Source after common.sh

# ─── Clone repo if project dir doesn't exist ─────────────────────────────────
git_clone_if_needed() {
  local repo_url="$1"
  local project_dir="$2"

  if [[ -d "$project_dir/.git" ]]; then
    log_info "Project dir exists: $project_dir"
    return 0
  fi

  if [[ -z "$repo_url" ]]; then
    die "Project dir does not exist and no --repo-url provided"
  fi

  log_step "Cloning $repo_url → $project_dir"
  run git clone "$repo_url" "$project_dir"
  log_success "Cloned repository"
}

# ─── Pull latest from default branch ─────────────────────────────────────────
git_pull_latest() {
  local project_dir="$1"

  log_step "Pulling latest changes"
  (
    cd "$project_dir"
    local default_branch
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

    run git checkout "$default_branch"
    run git pull origin "$default_branch"
    log_success "Updated $default_branch"
  )
}

# ─── Create or switch to feature branch ───────────────────────────────────────
git_feature_branch() {
  local project_dir="$1"
  local branch_name="$2"

  log_step "Setting up branch: $branch_name"
  (
    cd "$project_dir"
    run git checkout -B "$branch_name"
    log_success "On branch $branch_name"
  )
}

# ─── Get current branch name ─────────────────────────────────────────────────
git_current_branch() {
  local project_dir="$1"
  git -C "$project_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

# ─── Check if working tree is clean ──────────────────────────────────────────
git_is_clean() {
  local project_dir="$1"
  [[ -z "$(git -C "$project_dir" status --porcelain 2>/dev/null)" ]]
}
