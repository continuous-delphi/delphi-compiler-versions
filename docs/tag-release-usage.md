# tag-release.ps1 — Usage Reference

Release tagging script for `delphi-compiler-versions`.
Located at `tools/tag-release.ps1`.

## Release checklist

Before running the script, ensure:

- [ ] All changes have been committed to the default branch and pushed to origin
- [ ] Both artifacts regenerated if data or generator changed:

  ```powershell
  pwsh tools/generate-cd-delphi-versions-inc.ps1 -Force
  pwsh tools/generate-cd-delphi-compiler-versions-pas.ps1 -Force
  ```

- [ ] All 60 tests pass: `pwsh tests/run-tests.ps1`
- [ ] `CHANGELOG.md` has an entry for `vX.Y.Z`

Then:

```powershell
pwsh tools/tag-release.ps1 -Version X.Y.Z -WhatIf   # dry run first
pwsh tools/tag-release.ps1 -Version X.Y.Z           # create and push tag
```

_Reminder_:  The actual workflow trigger can be delayed by a few minutes

## Synopsis

```powershell
pwsh tools/tag-release.ps1 -Version <X.Y.Z> [-SkipBranchCheck] [-WhatIf] [-Confirm]
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Version` | Yes | Semantic version to tag, e.g. `1.0.0`. Must match `X.Y.Z` format exactly. |
| `-SkipBranchCheck` | No | Bypasses the branch guard. All other checks still run. Use only when hotfixing from a non-default branch. |
| `-WhatIf` | No | Runs all precondition checks but does not create or push the tag. Echoes the tag name and annotated message that would be used. |
| `-Confirm` | No | Prompts for confirmation before creating and pushing the tag. |

## Preconditions checked

The script validates all of the following before touching git:

1. Canonical data file exists and is valid JSON
2. `git` is available on PATH
3. Script is running inside a git repository
4. Current branch matches the default branch derived from `origin/HEAD`
5. Working tree is clean (no uncommitted changes)
6. `origin` remote exists
7. Tags are fetched from origin (local tag list brought up to date)
8. Local HEAD is up-to-date with `origin/<default branch>`
9. Tag does not already exist (checked locally after fetch, covering both local and origin)

The release version (`-Version`) is independent of `dataVersion` and `schemaVersion`
in the JSON. Both are embedded in the annotated tag message for traceability but are
not validated against the release version.

If any check fails the script exits immediately with a descriptive error message.
No git operations are performed until all checks pass.

---

## Examples

### Normal release

```powershell
pwsh tools/tag-release.ps1 -Version 1.0.0
```

```text

delphi-compiler-versions  tag-release
======================================
  Version : 1.0.0
  Tag     : v1.0.0
  Repo    : C:\dev\delphi-compiler-versions

  ok  data file found and valid JSON
  ok  git found (git version 2.47.0.windows.1)
  ok  inside git repository
  ok  on branch 'main'
  ok  working tree is clean
  ok  origin remote found
  ok  tags fetched
  ok  HEAD is up-to-date with origin/main
  ok  tag 'v1.0.0' does not exist

All checks passed.

  Creating tag v1.0.0...
  ok  tag created
  Pushing tag to origin...
  ok  tag pushed

Released: v1.0.0
The GitHub Actions release workflow should run for this tag.
```

---

### Dry run with `-WhatIf`

Runs all precondition checks but does not create or push the tag.
Echoes the exact tag name and annotated message that would be used.
Use this to validate repo state before committing to the release.

```powershell
pwsh tools/tag-release.ps1 -Version 1.0.0 -WhatIf
```

```text
  ok  data file found and valid JSON
  ok  git found (git version 2.47.0.windows.1)
  ok  inside git repository
  ok  on branch 'main'
  ok  working tree is clean
  ok  origin remote found
  ok  tags fetched
  ok  HEAD is up-to-date with origin/main
  ok  tag 'v1.0.0' does not exist

All checks passed.

  WhatIf: would create annotated tag and push to origin
    Tag    : v1.0.0
    Message: Release v1.0.0 (dataVersion 1.0.0  schemaVersion 1.0.0)
```

---

### Interactive confirmation with `-Confirm`

Prompts before the git operations. Useful when you want all checks to run
first and then explicitly approve the push.

```powershell
pwsh tools/tag-release.ps1 -Version 1.0.0 -Confirm
```

```text
  ...all checks...

All checks passed.

Confirm
Are you sure you want to perform this action?
  Create annotated tag and push
  Target: origin  (tag: v1.0.0  message: 'Release v1.0.0 (dataVersion 1.0.0  schemaVersion 1.0.0)')
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
```

---

### Wrong format — missing patch segment

```powershell
pwsh tools/tag-release.ps1 -Version 1.0
```

```
tag-release.ps1: Cannot validate argument on parameter 'Version'. The argument
"1.0" does not match the "^[0-9]+\.[0-9]+\.[0-9]+$" pattern.
```

Rejected immediately by `ValidatePattern` before any code runs.

---

### Dirty working tree

```powershell
pwsh tools/tag-release.ps1 -Version 1.0.0
```

```text
FAIL  Working tree is not clean. Commit or stash all changes before tagging.

 M data/delphi-compiler-versions.json
```

Commit or stash all changes, then re-run.

---

### Not on the default branch

```powershell
# run from a feature branch
pwsh tools/tag-release.ps1 -Version 1.0.0
```

```text
FAIL  Must be on 'main' branch to tag a release (currently on 'feature/add-florence').
      Switch to main, or use -SkipBranchCheck to override (not recommended).
```

---

### `origin/HEAD` not set — fallback warning

If `origin/HEAD` is not configured (e.g. in a manually initialised remote),
the script warns and assumes `main`:

```text
  warn  origin/HEAD not set; assuming default branch is 'main'
```

To resolve: `git remote set-head origin -a`

---

### Local HEAD behind origin

```powershell
pwsh tools/tag-release.ps1 -Version 1.0.0
```

```text
FAIL  Local HEAD is 2 commit(s) behind origin/main. Run 'git pull' before tagging.
```

---

### Local HEAD ahead of origin

```powershell
pwsh tools/tag-release.ps1 -Version 1.0.0
```

```text
FAIL  Local HEAD is 1 commit(s) ahead of origin/main. Push your changes before tagging.
```

---

### Tag already exists

After a fetch, the single tag check covers both local and origin:

```powershell
pwsh tools/tag-release.ps1 -Version 1.0.0
```

```text
FAIL  Tag 'v1.0.0' already exists (local or origin).
      To delete locally:  git tag -d v1.0.0
      To delete on origin: git push origin --delete v1.0.0
```

---

### Emergency override — tagging from a non-default branch

Use `-SkipBranchCheck` only when a hotfix must be released from a branch other
than the default. All other preconditions still run.

```powershell
pwsh tools/tag-release.ps1 -Version 1.0.1 -SkipBranchCheck
```

```text
  ok  data file found and valid JSON
  ok  git found (git version 2.47.0.windows.1)
  ok  inside git repository
  warn  Not on 'main' (on 'hotfix/registry-path'); -SkipBranchCheck override active
  ok  working tree is clean
  ok  origin remote found
  ok  tags fetched
  ok  HEAD is up-to-date with origin/main
  ok  tag 'v1.0.1' does not exist

All checks passed.

  Creating tag v1.0.1...
  ok  tag created
  Pushing tag to origin...
  ok  tag pushed

Released: v1.0.1
The GitHub Actions release workflow should run for this tag.
```

---

### Push fails after tag is created

If the local tag is created but the push to origin fails, the script prints
cleanup guidance before rethrowing the error:

```text
ERROR: Tag/push failed.
<exception detail>

Partial failure — check the state and clean up if needed:
  Local tag exists. If the push failed, delete it with:
    git tag -d v1.0.0
  Verify origin does not have a partial push:
    git ls-remote --tags origin refs/tags/v1.0.0
```
