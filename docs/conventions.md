# Conventions

Single source of truth for the rules used by the scripts and workflows in this repo.

## Scripts

Every script starts with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Rules:

- Provide a `usage` function and validate arguments before doing any work.
- Put shared helpers in `scripts/lib/`.
- Scripts must be idempotent: running one twice leaves the same end state and does not fail.
- Scripts must pass `shellcheck` with no warnings.
- Mark scripts executable (`chmod +x`); git records the mode.
- Line endings are LF (enforced by `.gitattributes`).

Portability (Linux runners, WSL and macOS):

- Require bash 4 or newer. macOS's `/bin/bash` is 3.2; Homebrew's bash is picked up through `#!/usr/bin/env bash` when its folder is first in `PATH`.
- Avoid GNU-only or BSD-only options in `sed`, `date`, `grep`, `stat` and `readlink`. Examples: `sed -i` and `date -d` behave differently on macOS. Use `jq` for JSON, and write the logic portably or in bash itself.
- Test scripts on both a Linux shell and a Mac before relying on them.

## Branch names

Pattern:

```text
^(feature|bugfix|chore)/(([A-Z][A-Z0-9]+-[0-9]+)|NOJIRA)(-[a-z0-9]+)*$
```

- Prefix is `feature/`, `bugfix/` or `chore/`.
- Then a Jira key (`KAN-12`) or the literal `NOJIRA` when no ticket exists.
- Then optional words in lowercase, separated by `-`.

Valid:

- `feature/KAN-12`
- `feature/KAN-12-my-super-feature`
- `bugfix/KAN-30-null-check`
- `chore/NOJIRA-bump-deps`

Invalid:

- `fix/KAN-12` (unknown prefix)
- `feature/my-feature` (no Jira key or `NOJIRA`)
- `feature/KAN-12_my_feature` (words not separated by `-`)
- `feature/KAN-12-My-Feature` (uppercase words)

Exempt from the rule: `main`, `hotfix/*`, `release/*`, `patch/*`, `dependabot/*`.

## Pull requests

- The Jira key (or `NOJIRA`) appears in the PR title or description.
- PRs are squash-merged into `main`; the branch is deleted after merge.

## Versions

SemVer 2.0, `MAJOR.MINOR.PATCH-PRE.INC`.

| Pre-release | Meaning | Tagged |
|---|---|:-:|
| `build.N` | Build from `main`; `N` starts at 0 for each new version | yes |
| `build.<yyyymmdd>.<hhmmss>` | Build from a feature or PR branch | no |
| `rc.N` | Release candidate promoted from a build | yes |
| `hotfix.N` | Build from a hotfix branch (`hotfix/*`, `release/*`, `patch/*`) | yes |

Promotion:

- `build` to `rc`: same commit and artifact, new `rc.N`.
- `rc` to release: drops the suffix.
- `hotfix` to release: drops the suffix.

Pre-releases sort before the final release of the same version, for example `1.19.0-rc.8` before `1.19.0`.

## Environments

| Environment | Receives |
|---|---|
| `dev` | `main` builds, automatically after CI |
| `qa` | release candidates (`rc.N`) |
| `prod` | final releases |

`qa` and `prod` require manual approval.
