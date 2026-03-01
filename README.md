# delphi-compiler-versions

![Status](https://img.shields.io/badge/status-incubator-orange)
![License](https://img.shields.io/github/license/continuous-delphi/delphi-compiler-versions)
![Pages](https://img.shields.io/website?url=https%3A%2F%2Fcontinuous-delphi.github.io%2Fdelphi-compiler-versions%2F&label=github%20pages)
![Schema](https://img.shields.io/badge/schema-1.0.0-blue)
![Data](https://img.shields.io/badge/data-0.1.0-blue)
![Continuous Delphi](https://img.shields.io/badge/org-continuous--delphi-red)

Canonical Delphi compiler version mapping based on official `VER###` symbols.

This repository defines the authoritative data model used by Continuous Delphi tooling to
resolve, normalize, and compare Delphi compiler versions. The canonical identifier is the
`VER###` symbol (for example: `VER180`, `VER230`, `VER360`, `VER370`).

------------------------------------------------------------------------

## Scope

-   For Delphi versions 2 and above (starts at `VER90`)
-   Excludes C++Builder and .NET-only entries
-   Includes registry metadata required for toolchain discovery

This repository is **data-first**. The JSON file under `data/` is the single source of truth.
All `Continuous Delphi` generated code and downstream tooling will derive from that dataset.

------------------------------------------------------------------------

## Repository Structure

```text
    schemas/
      1.0.0/
        delphi-compiler-versions.schema.json    # immutable versioned schema
      delphi-compiler-versions.schema.json      # latest version / stable alias
    data/
      delphi-compiler-versions.json             # current dataset
```

-   The schema is versioned and immutable once published. The `$id`
    inside each schema file matches its versioned canonical path.
-   The dataset is versioned independently via `dataVersion`.
-   Schema and data evolve separately under the Continuous Delphi
    versioning policy defined in `docs/versioning-policy.md`.

Canonical schema `$id`:

```text
https://continuous-delphi.github.io/delphi-compiler-versions/schemas/1.0.0/delphi-compiler-versions.schema.json
```

Note: The schema $id URI is currently being served via `GitHub Pages` (which has been enabled on this repository). GitHub Pages must remain active for these URIs to resolve.

## Entity and Property Naming

This repository follows the Continuous Delphi org-wide naming standard:

-   All JSON keys use lowerCamelCase
-   Acronyms are treated as words (utcDate, bdsRegVersion)
-   No snake_case keys
-   Arrays are used for collections (aliases: \[\])

### Dataset

The dataset file contains two independent version fields:

- `schemaVersion` -- identifies the schema contract the dataset conforms to.
- `dataVersion` -- tracks the dataset contents under semantic versioning.

## Data Model

Primary file:

```text
data/delphi-compiler-versions.json
```

Each entry includes:

- `verDefine` -- canonical `VER###` symbol (primary identifier, listed first in `aliases` by convention)
- `compilerVersion` -- string preserving the exact `CompilerVersion` notation (e.g., `"37.0"`)
- `productName` -- official product name
- `packageVersion` -- package version identifier
- `regKeyRelativePath` -- relative registry key path for toolchain discovery
- `aliases` -- List of identifiers that resolve to this entry
- `notes` -- clarifications or historical remarks

Install paths are intentionally excluded from the specification. 
Tooling should resolve installation directories via the registry `RootDir` value.

------------------------------------------------------------------------

## Purpose

This specification exists to ensure that:

- `delphi-toolchain-*` can normalize installed Delphi versions.
- CI build actions can select toolchains deterministically.
- Delphi tooling can reason about compiler capabilities.
- Alias resolution (`Delphi 13`, `BDS 37.0`, `VER370`, etc.) is consistent across all tools.
- Registry-based discovery logic is centralized and reproducible.

## Maturity

This repository is currently `incubator`. It will graduate to `stable` once:

- The schema is considered frozen at `1.x`.
- CI validation is in place.
- At least one downstream tool consumes the dataset.
- No breaking schema changes are anticipated.

Until graduation, breaking changes may occur. No migration guarantees are provided.

## Part of Continuous Delphi

This repository follows the Continuous Delphi organization taxonomy. See
[cd-meta-org](https://github.com/continuous-delphi/cd-meta-org) for navigation and governance.

- `docs/org-taxonomy.md` -- naming and tagging conventions
- `docs/versioning-policy.md` -- release and versioning rules
- `docs/repo-lifecycle.md` -- lifecycle states and graduation criteria
