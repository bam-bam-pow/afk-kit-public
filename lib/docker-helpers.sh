#!/usr/bin/env bash
# docker-helpers.sh — Docker Compose operations for afk-build
# Source after common.sh

# ─── Copy docker-compose template if project has none ─────────────────────────
docker_ensure_compose() {
  local project_dir="$1"
  local profile="$2"        # e.g. "fastapi-react"
  local repo_root="$3"

  local compose_file="$project_dir/docker-compose.yml"
  local template="$repo_root/templates/docker-compose.${profile}.yml"

  if [[ -f "$compose_file" ]]; then
    log_info "docker-compose.yml already exists"
    return 0
  fi

  if [[ ! -f "$template" ]]; then
    die "No docker-compose template for profile '$profile' at $template"
  fi

  log_step "Copying docker-compose template ($profile)"
  run cp "$template" "$compose_file"

  # Also copy Dockerfiles if they don't exist
  case "$profile" in
    fastapi-react)
      [[ -f "$project_dir/Dockerfile.fastapi" ]] || run cp "$repo_root/templates/Dockerfile.fastapi" "$project_dir/"
      [[ -f "$project_dir/Dockerfile.react-vite" ]] || run cp "$repo_root/templates/Dockerfile.react-vite" "$project_dir/"
      ;;
    fastapi-only)
      [[ -f "$project_dir/Dockerfile.fastapi" ]] || run cp "$repo_root/templates/Dockerfile.fastapi" "$project_dir/"
      ;;
    react-only)
      [[ -f "$project_dir/Dockerfile.react-vite" ]] || run cp "$repo_root/templates/Dockerfile.react-vite" "$project_dir/"
      ;;
  esac

  log_success "Docker templates copied"
}

# ─── Validate docker-compose.yml ──────────────────────────────────────────────
docker_validate() {
  local project_dir="$1"

  log_step "Validating docker-compose.yml"
  if ! run docker compose -f "$project_dir/docker-compose.yml" config --quiet 2>/dev/null; then
    die "docker-compose.yml validation failed"
  fi
  log_success "docker-compose.yml is valid"
}

# ─── Start services ───────────────────────────────────────────────────────────
docker_up() {
  local project_dir="$1"

  log_step "Starting Docker services"
  run docker compose -f "$project_dir/docker-compose.yml" up -d --build
  log_success "Docker services started"
}

# ─── Health check: wait for a service to be healthy ───────────────────────────
docker_wait_healthy() {
  local project_dir="$1"
  local service="$2"
  local max_wait="${3:-60}"

  log_info "Waiting for $service to be healthy (max ${max_wait}s)..."

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_dim "[dry-run] Would wait for $service health check"
    return 0
  fi

  local elapsed=0
  while (( elapsed < max_wait )); do
    local health
    health=$(docker compose -f "$project_dir/docker-compose.yml" ps --format json "$service" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('Health',''))" 2>/dev/null || echo "")

    if [[ "$health" == "healthy" ]]; then
      log_success "$service is healthy"
      return 0
    fi

    # Also check if the container is running at all
    local state
    state=$(docker compose -f "$project_dir/docker-compose.yml" ps --format json "$service" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('State',''))" 2>/dev/null || echo "")

    if [[ "$state" == "running" && -z "$health" ]]; then
      # No health check defined, just wait a bit and assume OK
      sleep 3
      log_success "$service is running (no health check defined)"
      return 0
    fi

    sleep 2
    elapsed=$((elapsed + 2))
  done

  log_warn "$service did not become healthy within ${max_wait}s"
  return 1
}

# ─── Check all core services ─────────────────────────────────────────────────
docker_check_services() {
  local project_dir="$1"
  local profile="$2"

  case "$profile" in
    fastapi-react)
      docker_wait_healthy "$project_dir" "postgres" 30
      docker_wait_healthy "$project_dir" "redis" 15
      ;;
    fastapi-only)
      docker_wait_healthy "$project_dir" "postgres" 30
      docker_wait_healthy "$project_dir" "redis" 15
      ;;
    react-only)
      # No infrastructure services to check
      ;;
  esac
}

# ─── Stop services ────────────────────────────────────────────────────────────
docker_down() {
  local project_dir="$1"
  log_step "Stopping Docker services"
  run docker compose -f "$project_dir/docker-compose.yml" down
  log_success "Docker services stopped"
}
