#!/usr/bin/env bash
# Shared helpers. Source this file; do not execute it.

if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
  C_RESET=$'\033[0m'
  C_DIM=$'\033[2m'
  C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'
else
  C_RESET='' C_DIM='' C_RED='' C_GREEN=''
fi

log() {
  printf '%s[%s]%s %s\n' "$C_DIM" "$(date +%H:%M:%S)" "$C_RESET" "$*" >&2
}

ok() {
  printf '  %s✔%s %s\n' "$C_GREEN" "$C_RESET" "$*" >&2
}

die() {
  printf '%s[%s] ERROR: %s%s\n' "$C_RED" "$(date +%H:%M:%S)" "$*" "$C_RESET" >&2
  exit 1
}

require_cmd() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "missing required command: $cmd"
  done
}

require_gh_auth() {
  gh auth status >/dev/null 2>&1 || die "gh is not authenticated, run: gh auth login"
}

# Run a command, or only print it when DRY_RUN=1.
run() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}