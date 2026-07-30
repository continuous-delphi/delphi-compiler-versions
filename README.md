# delphi-compiler-versions

![delphi-compiler-versions logo](https://continuous-delphi.github.io/assets/logos/delphi-compiler-versions-480x270.png)

[![Delphi](https://img.shields.io/badge/delphi-red)](https://www.embarcadero.com/products/delphi)
[![CI](https://github.com/continuous-delphi/delphi-compiler-versions/actions/workflows/ci.yml/badge.svg)](https://github.com/continuous-delphi/delphi-compiler-versions/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/continuous-delphi/delphi-compiler-versions?display_name=release)](https://github.com/continuous-delphi/delphi-compiler-versions/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/continuous-delphi/delphi-compiler-versions)
[![Continuous Delphi](https://img.shields.io/badge/org-continuous--delphi-red)](https://github.com/continuous-delphi)

Canonical Delphi compiler version mapping based on official `VER###`
symbols.

This repository defines the authoritative data model used by Continuous
Delphi tooling to resolve, normalize, and compare Delphi compiler
versions.

## TL;DR

### Quick start - download

Most users only need these ready-to-download generated artifacts:

- `DELPHI_COMPILER_VERSIONS.inc`
- `DelphiCompilerVersions.pas`

You can download these manually in [Releases](https://github.com/continuous-delphi/delphi-compiler-versions/releases)

For scripted updates use curl:

```bash
curl -L -O https://github.com/continuous-delphi/delphi-compiler-versions/releases/latest/download/DELPHI_COMPILER_VERSIONS.inc
```

or PowerShell:

```powershell
Invoke-WebRequest -Uri "https://github.com/continuous-delphi/delphi-compiler-versions/releases/latest/download/DELPHI_COMPILER_VERSIONS.inc" -OutFile "DELPHI_COMPILER_VERSIONS.inc"
```

### Quick start - submodule

For projects using Git, submodule integration is the recommended
approach as updates are a single command and the generated files are
always available without downloading manually.

```bash
git submodule add https://github.com/continuous-delphi/delphi-compiler-versions \
  vendor/delphi-compiler-versions
```

Then add the desired files from `vendor/delphi-compiler-versions/generated` to your project.
(Typically the `DELPHI_COMPILER_VERSIONS.inc` file) The tooling and tests found in the
rest of the repository can be ignored.

To update to a new version of the generated files:
```bash
git submodule update --remote vendor/delphi-compiler-versions
```

------------------------------------------------------------------------

## Project Scope

-   Dataset covers Delphi versions 2 and above (starts at `VER90`)
-   Excludes C++Builder and .NET-only entries
-   Includes registry metadata required for toolchain discovery
-   Includes supported **Build Systems** and **Target Platforms** per version

This repository is **data-first**. The JSON file under `data/` is the single
source of truth. All Continuous Delphi generated code and downstream
tooling derive from that dataset.

------------------------------------------------------------------------

## Repository Structure

```text
    data/
      delphi-compiler-versions.json          # current dataset (Delphi 2+)

    generated/                               # Files generated from delphi-compiler-versions.json
      DELPHI_COMPILER_VERSIONS.inc           # for: {$IFDEF CD_DELPHI_FLORENCE_OR_LATER}
      DelphiCompilerVersions.pas             # for: TDelphiPlatform, DelphiVersions array...
      PlatformSupport.md                     # visual platform support matrix

    schemas/
      delphi-compiler-versions.schema.json   # JSON Schema for the dataset

    tools/
      generate-delphi-compiler-versions-inc.ps1
      generate-delphi-compiler-versions-pas.ps1
      generate-platform-support-md.ps1
      tag-release.ps1

    tests/
      pwsh/

    .github/workflows/ci.yml                # test on push + PRs
    .github/workflows/release.yml           # automated releases
    .github/workflows/pages.yml             # publish schemas to GitHub Pages
```

- The generated include file and source file are generated and _never manually edited_.
- Tests enforce deterministic output and drift protection.
- GitHub Action workflow enforces passing tests, regenerates artifacts, and populates
release notes from `CHANGELOG.md`

Canonical schema `$id`:

```text
  https://continuous-delphi.github.io/delphi-compiler-versions/schemas/delphi-compiler-versions.schema.json
```

_GitHub Pages is enabled on the repository to serve the schema file._

### Dataset

The dataset file contains two independent version fields:

- `schemaVersion` -- identifies the schema contract the dataset conforms to.
- `dataVersion` -- tracks the dataset contents under semantic versioning.

## Data Model

Primary file:

```text
data/delphi-compiler-versions.json
```

### Top-level fields

- `schemaVersion` -- schema contract version (e.g. `"1.0.0"`)
- `dataVersion` -- dataset content version (e.g. `"1.0.0"`)
- `meta` -- metadata object; see below
- `versions` -- ordered array of version entries

### `meta` fields

- `generatedUtcDate` -- UTC date the file was last updated (`YYYY-MM-DD`)
- `scope` -- inclusion/exclusion rules (informational)
- `registryResolutionNotes` -- guidance on hive-agnostic registry discovery
- `platformNotes` -- policy notes for `supportedPlatforms` interpretation

### `versionEntry` fields

- `verDefine` -- canonical `VER###` symbol (primary identifier)
- `compilerVersion` -- string preserving the exact `CompilerVersion` value (e.g. `"37.0"`)
- `productName` -- commonly used product name
- `packageVersion` -- package version identifier (nullable)
- `regKeyRelativePath` -- relative registry key path beneath HKCU or HKLM (nullable)
- `supportedBuildSystems` -- build systems supported by this version family; see below
- `supportedPlatforms` -- target platforms supported by this version family; see below
- `aliases` -- additional commonly used identifiers that resolve to this entry
- `notes` -- clarifications, historical remarks, or sub-version platform introductions

Install paths are intentionally excluded from the specification.
Tooling should resolve installation directories via the registry `RootDir` value.

### `supportedBuildSystems`

An array of one or more of the following values:

| Value | Meaning |
|-------|---------|
| `DCC` | Direct command-line compiler invocation via `dcc32.exe` / `dcc64.exe` |
| `MSBuild` | `.dproj`-based builds via MSBuild (introduced in Delphi 2007) |

Entries prior to Delphi 2007 (`VER180` and earlier) support `DCC` only. Delphi 2007
(`VER185`) and later support both.

### `supportedPlatforms`

An array of platform identifiers representing the **union of all platforms supported across
all point releases within the version family**. Where a platform was introduced in a sub-version
point release (rather than the initial release of the version family), this is noted in the
entry's `notes` array.

Valid platform values: `Win32`, `Win64`, `macOS32`, `macOS64`, `macOSARM64`, `Linux64`, `iOS32`,
  `iOS64`, `iOSSimulator32`, `iOSSimulator64`, `Android32`, `Android64`, `WinARM64EC`.

------------------------------------------------------------------------

## Include File

The generated file:

    generated/DELPHI_COMPILER_VERSIONS.inc

provides Delphi projects with standardized compiler version and
capability defines derived directly from the canonical dataset.

It emits:

-   `CD_DELPHI_<MarketingName>` tokens
-   `CD_DELPHI_<Version>_OR_LATER` convenience tokens
-   `CD_DELPHI_COMPILER_VERSION_<major>` tokens
-   `CD_DELPHI_PACKAGE_VERSION_<value>` tokens
-   `CD_DELPHI_SUPPORTS_MSBUILD`
-   `CD_DELPHI_SUPPORTS_PLATFORM_<Platform>` tokens

This include file is:

-   Canonical
-   Data-driven
-   MIT-licensed
-   Deterministically generated
-   Protected by automated tests

------------------------------------------------------------------------

## Pascal Unit

The generated file:

    generated/DelphiCompilerVersions.pas

provides Delphi projects with a strongly-typed Pascal unit derived
directly from the canonical dataset. It is compatible with Delphi 2 and
all later versions.

It provides:

-   `TDelphiPlatform` enumeration with suffix-named members
    (e.g. `Win32Target`, `Win64Target`, `MacOS32Target`)
-   `TDelphiBuildSystem` enumeration with suffix-named members
    (e.g. `DCCSystem`, `MSBuildSystem`)
-   `TDelphiVersion` record with fields for all dataset properties,
    including an `AliasesCsv` field for alias resolution and a `VerEnum`
    field carrying the strongly-typed `TDelphiVerDefine` for the entry
    (enables ordinal version comparisons without resolving the `VerDefine`
    string)
-   `PDelphiVersion` pointer type
-   `DelphiVersions` typed constant array, sorted chronologically
-   `CD_SCHEMA_VERSION` and `CD_DATA_VERSION` string constants
-   `GetLatestDelphiVersion` -- returns the most recent entry in the array
-   `CurrentDelphiCompilerVersion` and `IsCurrentDelphiCompilerVersionKnown` --
    vars populated at unit initialization via `{$IFDEF VERxxx}` chains;
    `IsCurrentDelphiCompilerVersionKnown` is `False` if the compiler is not
    recognized in the dataset
-   `TryGetDelphiVersionByVerDefine`, `TryGetDelphiVersionByProductName`,
    `TryGetDelphiVersionByAlias` -- lookup functions
-   `IsDelphiVersionAtLeast` -- returns `True` when a `TDelphiVersion` is at
    least the given `TDelphiVerDefine` (ordinal comparison on `VerEnum`); a
    `defUnknown` minimum acts as "no lower bound"
-   `GetCurrentBuildPlatform` -- returns the `TDelphiPlatform` the unit is being
    compiled for, resolved at compile time. On Delphi 6+ it inspects the CPU and
    OS conditional symbols; on Delphi 2-5 (Win32-only) it returns `Win32Target`

The generated unit is intentionally written using a conservative subset
of Object Pascal:
- `var` parameters are used instead of `out`
- `Exit` is used without a return value expression
- `uses` items select the namespaced unit name (`System.SysUtils`) only on XE2 and
  later, falling back to the flat name (`SysUtils`) on all earlier compilers; the
  selection uses only `{$IFDEF}` directives so it is safe back to Delphi 2
- functionality is exposed through simple procedures and functions rather than
  static classes.

These choices are deliberate to be able to use this unit from Delphi 2+

This Pascal unit is:

-   Canonical
-   Data-driven
-   MIT-licensed
-   Deterministically generated
-   Protected by automated tests

------------------------------------------------------------------------

## Generators

    tools/generate-delphi-compiler-versions-inc.ps1
    tools/generate-delphi-compiler-versions-pas.ps1

Each generator transforms the canonical dataset into its respective
generated artifact. Both share the same properties:

-   Deterministic output
-   Fully reproducible from JSON
-   Safe to run in CI
-   No manual editing of the generated files required

------------------------------------------------------------------------

## Automated Protection

The test suite ensures:

-   Correct token emission (`.inc`) and correct Pascal output (`.pas`)
-   Historical compatibility is preserved (including `VER180`/`VER185`)
-   Capability ranges are computed correctly
-   CRLF line endings on all generated files
-   ASCII-only content (UTF-8 encoding without BOM)
-   Golden-file tests for both artifacts to prevent drift

------------------------------------------------------------------------

## Purpose

This specification ensures that:

-   Toolchain discovery is deterministic
-   CI build machines can be validated reliably
-   Compiler capabilities can be reasoned about programmatically
-   Alias resolution is centralized
-   Version detection logic is consistent across all tools

------------------------------------------------------------------------


![continuous-delphi logo](https://continuous-delphi.github.io/assets/logos/continuous-delphi-480x270.png)

## Part of Continuous Delphi

This tool is part of the [Continuous-Delphi](https://github.com/continuous-delphi)
ecosystem, focused on improving engineering discipline for long-lived Delphi systems.

## Related Continuous Delphi Tools

This repository provides the canonical Delphi compiler/version dataset. For
toolchain discovery on real machines, see
[delphi-inspect](https://github.com/continuous-delphi/delphi-inspect), which uses
this data to resolve aliases, inspect installed Delphi versions, and select a
ready toolchain for a requested platform and build system.

For MSBuild-based build automation, see
[delphi-msbuild](https://github.com/continuous-delphi/delphi-msbuild). It can be
used standalone with an explicit Delphi `RootDir`, or paired with
`delphi-inspect` so build scripts can discover a suitable Delphi installation and
pipe it directly into an MSBuild invocation.

Together, these projects form a data-driven workflow: this repository defines
the compiler/version facts, `delphi-inspect` discovers the installed toolchain,
and `delphi-msbuild` performs the build.
