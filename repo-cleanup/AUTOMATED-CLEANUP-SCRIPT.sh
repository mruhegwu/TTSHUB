#!/usr/bin/env bash
# =============================================================================
# AUTOMATED-CLEANUP-SCRIPT.sh
# Repository Cleanup Automation Tool
#
# Usage:
#   chmod +x AUTOMATED-CLEANUP-SCRIPT.sh
#   ./AUTOMATED-CLEANUP-SCRIPT.sh [OPTIONS]
#
# Options:
#   --backup-only        Back up all repos and exit (no interactive menu)
#   --dry-run            Print actions without executing them
#   --owner <name>       GitHub account/org to operate on (default: authenticated user)
#   --backup-dir <path>  Override backup directory
#   --help               Show this help message
#
# Requirements:
#   - Git >= 2.28
#   - GitHub CLI (gh) >= 2.0, authenticated
#   - Bash >= 4
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — override with CLI flags or environment variables
# ---------------------------------------------------------------------------
SCRIPT_VERSION="1.0.0"
OWNER="${GITHUB_OWNER:-}"
BACKUP_DIR="${GITHUB_BACKUP_DIR:-$HOME/github-backups-$(date +%Y-%m-%d)}"
DRY_RUN=false
BACKUP_ONLY=false
REPORT_FILE=""
MANIFEST_FILE=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Utility functions
# ---------------------------------------------------------------------------

log_info()    { echo -e "${GREEN}[INFO]${RESET}  $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
log_header()  { echo -e "\n${BOLD}${CYAN}=== $* ===${RESET}"; }
log_dry_run() { echo -e "${YELLOW}[DRY-RUN]${RESET} Would execute: $*"; }

die() {
  log_error "$*"
  exit 1
}

confirm() {
  local prompt="${1:-Are you sure?}"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "Confirmation prompt skipped in dry-run mode."
    return 0
  fi
  read -r -p "$(echo -e "${YELLOW}${prompt} [y/N]${RESET} ")" response
  [[ "$response" =~ ^[Yy]$ ]]
}

run_cmd() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "$*"
  else
    eval "$@"
  fi
}

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------

check_dependencies() {
  log_header "Checking dependencies"

  local missing=()

  if ! command -v git &>/dev/null; then
    missing+=("git")
  else
    local git_ver
    git_ver=$(git --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    log_info "Git version: $git_ver"
  fi

  if ! command -v gh &>/dev/null; then
    missing+=("gh (GitHub CLI)")
  else
    local gh_ver
    gh_ver=$(gh --version | head -1)
    log_info "GitHub CLI: $gh_ver"
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    die "Missing required tools: ${missing[*]}\nInstall them and re-run."
  fi

  # Check GitHub CLI auth
  if ! gh auth status &>/dev/null; then
    die "GitHub CLI is not authenticated. Run: gh auth login"
  fi

  log_info "All dependencies satisfied."
}

# ---------------------------------------------------------------------------
# Resolve owner
# ---------------------------------------------------------------------------

resolve_owner() {
  if [[ -z "$OWNER" ]]; then
    OWNER=$(gh api user --jq '.login' 2>/dev/null) || die "Could not determine GitHub username. Set --owner."
    log_info "Using authenticated user: $OWNER"
  fi
}

# ---------------------------------------------------------------------------
# List repositories
# ---------------------------------------------------------------------------

list_repos() {
  gh repo list "$OWNER" \
    --limit 1000 \
    --json name,description,isFork,isArchived,isPrivate,pushedAt,stargazerCount \
    2>/dev/null
}

# ---------------------------------------------------------------------------
# Backup functions
# ---------------------------------------------------------------------------

init_backup_dir() {
  if [[ "$DRY_RUN" == "false" ]]; then
    mkdir -p "$BACKUP_DIR"
  fi
  MANIFEST_FILE="$BACKUP_DIR/manifest-$(date +%Y%m%d-%H%M%S).txt"
  REPORT_FILE="$BACKUP_DIR/backup-report-$(date +%Y%m%d-%H%M%S).md"
  log_info "Backup directory: $BACKUP_DIR"
}

backup_repo() {
  local repo_name="$1"
  local dest="$BACKUP_DIR/${OWNER}_${repo_name}.git"
  local url="https://github.com/$OWNER/$repo_name.git"

  echo -n "  Cloning $repo_name ... "

  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "git clone --mirror $url $dest"
    return 0
  fi

  if git clone --mirror "$url" "$dest" &>/dev/null; then
    echo -e "${GREEN}OK${RESET}"
    # Record in manifest
    local size
    size=$(du -sh "$dest" 2>/dev/null | cut -f1 || echo "unknown")
    echo "$repo_name | $dest | $size | $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$MANIFEST_FILE"
    return 0
  else
    echo -e "${RED}FAILED${RESET}"
    log_warn "Failed to back up $repo_name — skipping."
    return 1
  fi
}

verify_backup() {
  local repo_name="$1"
  local dest="$BACKUP_DIR/${OWNER}_${repo_name}.git"

  if [[ ! -d "$dest" ]]; then
    log_warn "Backup directory not found for $repo_name: $dest"
    return 1
  fi

  echo -n "  Verifying $repo_name ... "
  if git -C "$dest" fsck --quiet 2>/dev/null; then
    echo -e "${GREEN}OK${RESET}"
    return 0
  else
    echo -e "${RED}FAILED${RESET}"
    log_warn "Integrity check failed for $repo_name"
    return 1
  fi
}

backup_all_repos() {
  log_header "Phase 1: Backing Up All Repositories"
  init_backup_dir

  local repos
  repos=$(list_repos | jq -r '.[].name')
  local total=0
  local success=0
  local failed=0

  while IFS= read -r repo; do
    total=$((total + 1))
    if backup_repo "$repo"; then
      success=$((success + 1))
    else
      failed=$((failed + 1))
    fi
  done <<< "$repos"

  log_header "Backup Summary"
  log_info "Total:   $total"
  log_info "Success: $success"
  [[ $failed -gt 0 ]] && log_warn "Failed:  $failed" || log_info "Failed:  $failed"

  if [[ "$DRY_RUN" == "false" ]]; then
    log_info "Manifest: $MANIFEST_FILE"
  fi
}

verify_all_backups() {
  log_header "Verifying Backup Integrity"

  local verified=0
  local failed=0

  for dir in "$BACKUP_DIR"/*.git; do
    [[ -d "$dir" ]] || continue
    local repo_name
    repo_name=$(basename "$dir" .git | sed "s/^${OWNER}_//")
    if verify_backup "$repo_name"; then
      verified=$((verified + 1))
    else
      failed=$((failed + 1))
    fi
  done

  log_info "Verified: $verified"
  [[ $failed -gt 0 ]] && log_warn "Failed:  $failed" || log_info "Failed:  $failed"
}

# ---------------------------------------------------------------------------
# Archive / Delete functions
# ---------------------------------------------------------------------------

archive_repo() {
  local repo_name="$1"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "gh repo archive $OWNER/$repo_name --yes"
    return 0
  fi

  if gh repo archive "$OWNER/$repo_name" --yes 2>/dev/null; then
    log_info "Archived: $OWNER/$repo_name"
  else
    log_warn "Failed to archive $OWNER/$repo_name (may already be archived)"
  fi
}

delete_repo() {
  local repo_name="$1"

  # Safety: require backup to exist before deleting
  local backup_path="$BACKUP_DIR/${OWNER}_${repo_name}.git"
  if [[ ! -d "$backup_path" && "$DRY_RUN" == "false" ]]; then
    log_error "No backup found at $backup_path — refusing to delete $repo_name."
    log_error "Run backup first, then retry."
    return 1
  fi

  if ! confirm "Delete $OWNER/$repo_name? This is IRREVERSIBLE on GitHub."; then
    log_info "Deletion of $repo_name skipped by user."
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "gh repo delete $OWNER/$repo_name --yes"
    return 0
  fi

  if gh repo delete "$OWNER/$repo_name" --yes 2>/dev/null; then
    log_info "Deleted: $OWNER/$repo_name"
  else
    log_warn "Failed to delete $OWNER/$repo_name"
  fi
}

# ---------------------------------------------------------------------------
# Interactive categorization
# ---------------------------------------------------------------------------

interactive_review() {
  log_header "Interactive Repository Review"
  log_info "For each repository, choose an action."
  log_info "Actions: (k)eep  (a)rchive  (d)elete  (s)kip/review-later"
  echo ""

  local repos_json
  repos_json=$(list_repos)

  local repo name description is_fork is_archived pushed_at

  while IFS= read -r repo; do
    name=$(echo "$repo" | jq -r '.name')
    description=$(echo "$repo" | jq -r '.description // "No description"')
    is_fork=$(echo "$repo" | jq -r '.isFork')
    is_archived=$(echo "$repo" | jq -r '.isArchived')
    pushed_at=$(echo "$repo" | jq -r '.pushedAt // "unknown"')

    if [[ "$is_archived" == "true" ]]; then
      log_info "Skipping already-archived repo: $name"
      continue
    fi

    echo ""
    echo -e "${BOLD}Repository:${RESET} $name"
    echo -e "  Description : $description"
    echo -e "  Fork        : $is_fork"
    echo -e "  Last push   : $pushed_at"
    echo -ne "  Action [(k)eep / (a)rchive / (d)elete / (s)kip]: "
    read -r action

    case "${action,,}" in
      k|keep)
        log_info "$name → KEEP (no action)"
        ;;
      a|archive)
        archive_repo "$name"
        ;;
      d|delete)
        backup_repo "$name"
        verify_backup "$name" || { log_error "Backup verification failed — aborting deletion of $name."; continue; }
        delete_repo "$name"
        ;;
      *)
        log_info "$name → SKIPPED (marked for review)"
        ;;
    esac
  done < <(echo "$repos_json" | jq -c '.[]')
}

# ---------------------------------------------------------------------------
# Generate report
# ---------------------------------------------------------------------------

generate_report() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "Would generate report at $REPORT_FILE"
    return 0
  fi

  log_header "Generating Backup Report"

  cat > "$REPORT_FILE" <<EOF
# Backup Report — $(date +%Y-%m-%d)

Generated by AUTOMATED-CLEANUP-SCRIPT.sh v$SCRIPT_VERSION

## Summary

| Field | Value |
|-------|-------|
| Owner | $OWNER |
| Backup Directory | $BACKUP_DIR |
| Generated At | $(date -u +%Y-%m-%dT%H:%M:%SZ) |

## Backed-Up Repositories

| Repository | Backup Path | Size | Timestamp |
|-----------|-------------|------|-----------|
EOF

  if [[ -f "$MANIFEST_FILE" ]]; then
    while IFS='|' read -r repo dest size ts; do
      echo "| $(echo "$repo" | xargs) | $(echo "$dest" | xargs) | $(echo "$size" | xargs) | $(echo "$ts" | xargs) |" >> "$REPORT_FILE"
    done < "$MANIFEST_FILE"
  fi

  echo "" >> "$REPORT_FILE"
  echo "_Report generated by [Repository Cleanup Toolkit](../repo-cleanup/README.md)._" >> "$REPORT_FILE"

  log_info "Report saved: $REPORT_FILE"
}

# ---------------------------------------------------------------------------
# Interactive menu
# ---------------------------------------------------------------------------

show_menu() {
  log_header "Repository Cleanup Automation Tool v$SCRIPT_VERSION"
  echo -e "Owner: ${CYAN}$OWNER${RESET}   Backup Dir: ${CYAN}$BACKUP_DIR${RESET}"
  [[ "$DRY_RUN" == "true" ]] && echo -e "${YELLOW}DRY-RUN MODE ACTIVE — no changes will be made${RESET}"
  echo ""
  echo "  1) Backup all repositories"
  echo "  2) Verify existing backups"
  echo "  3) Interactive repository review (backup + archive/delete)"
  echo "  4) Generate backup report"
  echo "  5) Run full cleanup (backup → verify → interactive review → report)"
  echo "  q) Quit"
  echo ""
  read -r -p "$(echo -e "${BOLD}Choose an option:${RESET} ")" choice

  case "$choice" in
    1) backup_all_repos ;;
    2) verify_all_backups ;;
    3) init_backup_dir; interactive_review ;;
    4) init_backup_dir; generate_report ;;
    5)
      backup_all_repos
      verify_all_backups
      interactive_review
      generate_report
      ;;
    q|Q) log_info "Exiting."; exit 0 ;;
    *) log_warn "Unknown option: $choice"; show_menu ;;
  esac
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --backup-only) BACKUP_ONLY=true ;;
      --dry-run)     DRY_RUN=true ;;
      --owner)       OWNER="$2"; shift ;;
      --backup-dir)  BACKUP_DIR="$2"; shift ;;
      --help|-h)
        sed -n '2,20p' "$0" | sed 's/^# \?//'
        exit 0
        ;;
      *) log_warn "Unknown argument: $1" ;;
    esac
    shift
  done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  parse_args "$@"
  check_dependencies
  resolve_owner

  if [[ "$BACKUP_ONLY" == "true" ]]; then
    backup_all_repos
    verify_all_backups
    generate_report
    exit 0
  fi

  show_menu
}

main "$@"
