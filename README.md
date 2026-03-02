# delphi-compiler-versions

![Status](https://img.shields.io/badge/status-incubator-orange)
![License](https://img.shields.io/github/license/continuous-delphi/delphi-compiler-versions)
![Pages](https://img.shields.io/website?url=https%3A%2F%2Fcontinuous-delphi.github.io%2Fdelphi-compiler-versions%2F&label=github%20pages)
![Schema](https://img.shields.io/badge/schema-1.0.0-blue)
![Data](https://img.shields.io/badge/data-0.3.0-blue) ![Continuous
Delphi](https://img.shields.io/badge/org-continuous--delphi-red)

Canonical Delphi compiler version mapping based on official `VER###`
symbols.

This repository defines the authoritative data model used by Continuous
Delphi tooling to resolve, normalize, and compare Delphi compiler
versions. The canonical identifier is the `VER###` symbol (for example:
`VER180`, `VER230`, `VER360`, `VER370`).

In addition to the canonical JSON specification, this repository
publishes a generated Delphi include file:

    include/CD_DELPHI_VERSIONS.inc

This include file is:

-   Canonical
-   Data-driven
-   MIT-licensed
-   Deterministically generated
-   Protected by automated tests

The JSON dataset is the single source of truth. The include file is a
derived artifact.

------------------------------------------------------------------------

## Scope

-   For Delphi versions 2 and above (starts at `VER90`)
-   Excludes C++Builder and .NET-only entries
-   Includes registry metadata required for toolchain discovery
-   Includes supported build systems and target platforms per version
    family

This repository is **data-first**. The JSON file under `data/` is the single
source of truth. All Continuous Delphi generated code and downstream
tooling derive from that dataset.

------------------------------------------------------------------------

## Repository Structure

```text
    schemas/
      1.0.0/
        delphi-compiler-versions.schema.json    # immutable versioned schema
      delphi-compiler-versions.schema.json      # latest version / stable alias
    data/
      delphi-compiler-versions.json             # current dataset

    tools/
      generate-cd-delphi-versions-inc.ps1

    include/
      CD_DELPHI_VERSIONS.inc

    tests/
      pwsh/
```

-   The schema is versioned and immutable once published.
-   The dataset is versioned independently via `dataVersion`.
-   The include file is generated and never manually edited.
-   Tests enforce deterministic output and drift protection.

Canonical schema `$id`:

```text
    https://continuous-delphi.github.io/delphi-compiler-versions/schemas/1.0.0/delphi-compiler-versions.schema.json
```

GitHub Pages must remain active for these URIs to resolve.

## Entity and Property Naming

This repository follows the Continuous Delphi org-wide naming standard:

-   All JSON keys use lowerCamelCase
-   Acronyms are treated as words (e.g. `utcDate`, `regKeyRelativePath`)
-   Arrays are used for collections (`aliases: []`, `notes: []`)

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
- `dataVersion` -- dataset content version (e.g. `"0.3.0"`)
- `meta` -- optional metadata object; see below
- `versions` -- ordered array of version entries

### `meta` fields

- `generatedUtcDate` -- UTC date the file was last updated (`YYYY-MM-DD`)
- `scope` -- inclusion/exclusion rules (informational)
- `registryResolutionNotes` -- guidance on hive-agnostic registry discovery
- `platformNotes` -- policy notes for `supportedPlatforms` interpretation

### `versionEntry` fields

- `verDefine` -- canonical `VER###` symbol (primary identifier)
- `compilerVersion` -- string preserving the exact `CompilerVersion` value (e.g. `"37.0"`)
- `productName` -- official product name
- `packageVersion` -- package version identifier (nullable)
- `regKeyRelativePath` -- relative registry key path beneath HKCU or HKLM (nullable)
- `supportedBuildSystems` -- build systems supported by this version family; see below
- `supportedPlatforms` -- target platforms supported by this version family; see below
- `aliases` -- additional identifiers that resolve to this entry
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

Valid platform values: `Win32`, `Win64`, `Win64ARMEC`, `macOS32`, `macOS64`, `macOSARM64`,
`Linux64`, `iOS`, `iOSSimulator`, `Android32`, `Android64`.

Only shipping, fully supported targets are included. Experimental or preview support
(as defined by Embarcadero's own release framing) is excluded.


------------------------------------------------------------------------

## Generated Include Artifact

The file:

    include/CD_DELPHI_VERSIONS.inc

provides Delphi projects with standardized compiler version and
capability defines derived directly from the canonical dataset.

It emits:

-   `CD_DELPHI_VER###` tokens
-   `CD_DELPHI_<MarketingName>` tokens
-   `CD_DELPHI_<Version>_OR_LATER` convenience tokens
-   `CD_DELPHI_COMPILER_VERSION_<major>` tokens
-   `CD_DELPHI_PACKAGE_VERSION_<value>` tokens
-   `CD_DELPHI_SUPPORTS_MSBUILD`
-   `CD_DELPHI_SUPPORTS_PLATFORM_<Platform>` tokens


Capability support is computed using version ranges. Historical edge
cases (e.g. `VER180` / `VER185` compatibility) are handled explicitly.

Output is:

-   Deterministic and reproducible
-   UTF-8 encoding without BOM
-   CRLF line endings

------------------------------------------------------------------------

## Generator

    tools/generate-cd-delphi-versions-inc.ps1

The generator transforms the canonical dataset into the include
artifact.

Properties:

-   Deterministic output
-   Fully reproducible from JSON
-   Safe to run in CI
-   No manual editing of the include file required

If the dataset or generator changes, the include file must be
regenerated.

------------------------------------------------------------------------

## Automated Protection

The test suite ensures:

-   Correct token emission
-   Historical compatibility is preserved
-   Capability ranges are computed correctly
-   CRLF line endings
-   UTF-8 encoding without BOM
-   No drift between JSON + generator and committed include file
    (golden-file test)

If the include file becomes stale, tests fail and instruct the developer
to regenerate it.

This guarantees that the published include artifact always reflects the
canonical dataset.

------------------------------------------------------------------------

## Purpose

This specification ensures that:

-   Toolchain discovery is deterministic
-   CI build machines can be validated reliably
-   Compiler capabilities can be reasoned about programmatically
-   Alias resolution is centralized
-   Version detection logic is consistent across all tools

------------------------------------------------------------------------

## Maturity

This repository is currently `incubator`. It will graduate to `stable`
once:

-   The schema is considered frozen at `1.x`
-   CI validation is in place
-   At least one downstream tool consumes the dataset
-   No breaking schema changes are anticipated

Until graduation, breaking changes may occur.

------------------------------------------------------------------------

## Part of Continuous Delphi

This repository follows the Continuous Delphi organization taxonomy. See
[cd-meta-org](https://github.com/continuous-delphi/cd-meta-org) for navigation and governance.

- `docs/org-taxonomy.md` -- naming and tagging conventions
- `docs/versioning-policy.md` -- release and versioning rules
- `docs/repo-lifecycle.md` -- lifecycle states and graduation criteria
