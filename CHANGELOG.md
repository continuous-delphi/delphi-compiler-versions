# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Start a new release with two pound signs followed with a `[X.Y.Z]` release designation.
Every line following that matching version section line until the next version section
will be included within in the generated release doc (these change log entries are
appended to the end of `RELEASE_TEMPLATE.md` to create the release doc.)

Whatever `X.Y.Z` version used here should match the `-Version` parameter to the
release script:

- `pwsh tools/tag-release.ps1 -Version X.Y.Z`

see also: `/docs/tag-release-usage.md` for usage notes

Note: The `tag-release` script will fail if it does not find a matching version
section here.

---

## [1.1.0] - 2026-03-05

Platform support matrix

## New tool and generated artifact

- `tools/generate-platform-support-md.ps1` - generates `PlatformSupport.md`
from the canonical dataset
- `generated/PlatformSupport.md` - visual cross reference of platform
support by Delphi version

## [1.0.0] - 2026-03-05

Initial release.

### Dataset

- `data/delphi-compiler-versions.json` - canonical dataset covering Delphi 2
(VER90) through Delphi 13 Florence (VER370); 27 entries
- `schemas/delphi-compiler-versions.schema.json` - latest schema (symlink/copy
of versioned schema)
- `schemas/1.0.0/delphi-compiler-versions.schema.json` - versioned, immutable
schema at v1.0.0

### Generated artifacts

- `generated/CD_DELPHI_VERSIONS.inc` - compiler detection include file for
use in Delphi projects
- `generated/DelphiCompilerVersions.pas` - runtime lookup unit for Delphi
compiler information

### Tools

- `tools/generate-cd-delphi-versions-inc.ps1` - generates `CD_DELPHI_VERSIONS.inc`
from the canonical dataset
- `tools/generate-cd-delphi-compiler-versions-pas.ps1` - generates
`DelphiCompilerVersions.pas` from the canonical dataset
- `tools/tag-release.ps1` - validates preconditions and creates an annotated
release tag

### Tests

- `tests/run-tests.ps1` - runs the full Pester test suite (60 tests)

### Documentation

- `docs/tag-release-usage.md` - usage reference for `tag-release.ps1`

### CI/CD

- `.github/workflows/release.yml` - runs tests, regenerates artifacts, and
publishes a GitHub release on push of a `v*` tag
- `.github/RELEASE_TEMPLATE.md` - release notes template populated by the
release workflow
