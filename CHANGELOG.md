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

## [1.4.0] - 2026-03-21

- Add support for `WinARM64EC` as Delphi 13.1 just started supporting this new platform
  Schema + Data versions bumped from `1.0.0` to `1.1.0` due to new platform support.
  Latest schema becomes 1.1.0: `https://continuous-delphi.github.io/schemas/delphi-compiler-versions.schema.json`
  Added `schemas/1.0.0` and `schemas/1.1.0` to capture version-specific schemas
  [#22](https://github.com/continuous-delphi/delphi-compiler-versions/issues/22)

## [1.3.0] - 2026-03-15

- Corrected iOS+iOSSimulator platforms, will now have iOS32 + iOS64 and
iOSSimulator32 + iOSSimulator64 platforms

- `ci` workflow to trigger on all branches

## [1.2.0] - 2026-03-07

### .PAS generated file fix

- The .pas file generator `generate-delphi-compiler-versions-pas` was tweaked to
produce Delphi 2 code but that introduced a bug when Exit(true); was split across
two lines. Fixed in #17

- `ci` workflow added for running tests after every commit for #18

## [1.1.0] - 2026-03-06

Platform support matrix doc + Forward Compatibility in INC + filenames standardized

### New tool and generated artifact

- `tools/generate-platform-support-md.ps1` - generates `PlatformSupport.md`
from the canonical dataset for Issue #7
- `generated/PlatformSupport.md` - visual cross reference of platform
support by Delphi version

### DELPHI_COMPILER_VERSIONS.inc forward-compatibility

- Issue #8: If the VERxxx is not found, then we assume a brand new Delphi
version is being used and the flags are set to the latest version in the
dataset to prevent developers from having to edit the .inc file manually.
- The define `CD_DELPHI_VERSION_UNKNOWN` remains set so users can detect this
special condition.

### Remove excess define from generator

- Issue #13 `CD_DELPHI_VER###` would likely never be used in place of `VER###`

### PSScriptAnalyzer support

- Issue #15 added linting of the pwsh scripts with the standard PSScriptAnalyzer
with some minor corrections made.

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

- `generated/DELPHI_COMPILER_VERSIONS.inc` - compiler detection include file for
use in Delphi projects
- `generated/DelphiCompilerVersions.pas` - runtime lookup unit for Delphi
compiler information

### Tools

- `tools/generate-delphi-compiler-versions-inc.ps1` - generates `DELPHI_COMPILER_VERSIONS.inc`
from the canonical dataset
- `tools/generate-delphi-compiler-versions-pas.ps1` - generates
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

## `Delphi-Compiler-Versions` - The authoritative Delphi versions reference from Continuous Delphi

![continuous-delphi logo](https://continuous-delphi.github.io/assets/logos/continuous-delphi-480x270.png)

https://github.com/continuous-delphi
