#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat <<'EOF'
Usage: bootstrap-repo.sh [--dry-run] <owner/repo>

Apply the gh-platform conventions to a GitHub repository.

Options:
  --dry-run   print the changes instead of applying them
  -h, --help  show this help
EOF
}

DRY_RUN=0
REPO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1" ;;
    *)
      [[ -z "$REPO" ]] || die "only one repository can be given"
      REPO="$1"
      ;;
  esac
  shift
done

[[ -n "$REPO" ]] || { usage >&2; exit 2; }
[[ "$REPO" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die "expected owner/repo, got: $REPO"
export DRY_RUN

require_cmd gh jq
require_gh_auth

log "target: ${REPO} (dry-run=${DRY_RUN})"

apply_repo_settings() {
  log "applying repository settings"
  run gh api -X PATCH "repos/${REPO}" \
    -F allow_squash_merge=true \
    -F allow_merge_commit=false \
    -F allow_rebase_merge=false \
    -F delete_branch_on_merge=true \
    -F allow_update_branch=true \
    -f squash_merge_commit_title=PR_TITLE \
    -f squash_merge_commit_message=PR_BODY \
    | jq -r '{allow_squash_merge, allow_merge_commit, allow_rebase_merge, delete_branch_on_merge, allow_update_branch, squash_merge_commit_title, squash_merge_commit_message} | to_entries[] | "\(.key) = \(.value)"' \
    | while IFS= read -r line; do ok "$line"; done
  if [[ "$DRY_RUN" == "1" ]]; then
    log "dry-run: repository settings not changed"
  else
    log "repository settings applied"
  fi
}

apply_rulesets() {
  local file name id
  log "applying rulesets"
  for file in "${SCRIPT_DIR}"/../templates/rulesets/*.json; do
    name="$(jq -r '.name' "$file")"
    id="$(gh api "repos/${REPO}/rulesets" | jq -r --arg n "$name" '.[] | select(.name == $n) | .id')"
    if [[ -n "$id" ]]; then
      run gh api -X PUT "repos/${REPO}/rulesets/${id}" --input "$file" --silent
      [[ "$DRY_RUN" == "1" ]] || ok "${name} updated (id ${id})"
    else
      run gh api -X POST "repos/${REPO}/rulesets" --input "$file" --silent
      [[ "$DRY_RUN" == "1" ]] || ok "${name} created"
    fi
  done
  if [[ "$DRY_RUN" == "1" ]]; then
    log "dry-run: rulesets not changed"
  else
    log "rulesets applied"
  fi
}

apply_repo_settings
apply_rulesets
