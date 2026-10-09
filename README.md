# gh-platform

Scripts, templates and reusable workflows for managing GitHub repos.

This is a personal lab for practising GitHub Actions, repository management and release workflows at a small scale: branch rules, PR templates, semantic versioning, quality gating, promotion between environments and Jira linking. Everything here is public and meant for learning.

## What it does (or will do)

| Area | Status |
|---|---|
| Bootstrap a repo: settings, labels, templates, environments, rulesets | Planned |
| Enforce branch names and Jira keys on PRs | Planned |
| Reusable workflows: semver, build, quality gate, deploy, promote | Planned |
| Hotfix track | Planned |

## Layout

```text
scripts/             bash scripts (bootstrap, helpers)
scripts/lib/         shared shell functions
templates/           files pushed to the repos this tool manages
  pull_request_template.md
  ISSUE_TEMPLATE/
  rulesets/          ruleset definitions (JSON)
.github/workflows/   this repo's own workflows and the reusable ones
docs/                conventions and design notes
```

## Prerequisites

- `git`
- `gh` (GitHub CLI), authenticated with `gh auth login -s delete_repo`
- `jq`
- `shellcheck`
- `actionlint`
- bash 4 or newer
- .NET SDK and Node.js (via `fnm`), only for the sample app repos

## Setup

Scripts target bash on Linux, so the same code runs on the GitHub runners, in WSL and on macOS.

### Windows (WSL)

1. Install WSL with Ubuntu, then work inside the Linux filesystem (`~/code`), not `/mnt/c`.
2. Install `git`, `jq`, `shellcheck` and `curl` with `apt`.
3. Install `gh` from the official apt repository (cli.github.com/packages).
4. Install `actionlint` from the prebuilt binary on its GitHub Releases page and put it in `~/.local/bin`.
5. Install the .NET SDK from Microsoft's Ubuntu instructions and `fnm` from its README.
6. Authenticate with `gh auth login -s delete_repo` (WSL has no browser, so open the printed URL in Windows and enter the code). The extra `-s delete_repo` scope lets `gh repo delete` work; it is not granted by default.

### macOS

1. Install Homebrew (brew.sh).
2. Install the tools:
   ```bash
   brew install git gh jq shellcheck actionlint bash fnm
   brew install --cask dotnet-sdk
   ```
   `bash` installs a current bash. macOS ships bash 3.2 in `/bin/bash`, which is too old for these scripts.
3. Make sure Homebrew's bin folder comes first in your `PATH` (`brew shellenv` prints the right line to add to `~/.zshrc`), so `#!/usr/bin/env bash` finds the new bash.
4. Activate `fnm` by appending its init line to `~/.zshrc`, then reload the shell:
   ```bash
   echo 'eval "$(fnm env --use-on-cd --shell zsh)"' >> ~/.zshrc
   ```
   ```bash
   exec zsh
   ```
   The single quotes keep `$(...)` from running now, so the literal line is written to the file. Run the first command only once, or the line will be duplicated.
5. Authenticate with `gh auth login -s delete_repo` (the browser flow works directly). The extra `-s delete_repo` scope lets `gh repo delete` work; it is not granted by default.

### Both

```bash
git config --global init.defaultBranch main
git config --global core.autocrlf input
git config --global user.name "<your name>"
git config --global user.email "<id>+<username>@users.noreply.github.com"
```

Use your GitHub noreply address (github.com/settings/emails) so your real email stays out of public commits.

`--global` applies to every repo on the machine and only affects new commits; existing history is not rewritten. If this machine also holds repos that use a different identity (for example work repos), leave `user.name` and `user.email` out of the global config and set them per repo instead, from inside each repo:

```bash
git config user.email "<id>+<username>@users.noreply.github.com"
```

Without `--global` this writes to the repo's `.git/config` and overrides the global value for that repo only. Run `git config user.name "<your name>"` the same way.

Check your setup with `bash --version`, `gh auth status` and `actionlint --version`.

## Conventions

The full rules live in [docs/conventions.md](docs/conventions.md). In short:

- **Branches:** `feature/`, `bugfix/` or `chore/`, then a Jira key (e.g. `KAN-12`) or `NOJIRA`, then optional words separated by `-`. Example: `feature/KAN-12-my-super-feature`.
- **Versions:** SemVer 2.0. `main` builds are `X.Y.Z-build.N`, promoted to `X.Y.Z-rc.N`, then to the final `X.Y.Z`. Hotfix branches produce `X.Y.Z-hotfix.N`.
- **Environments:** `dev`, `qa`, `prod`.
- **Scripts:** bash, `set -euo pipefail`, clean under `shellcheck`.

## License

MIT, see [LICENSE](LICENSE).
