**Tag:** `vX.Y.Z`

Source repo: https://github.com/continuous-delphi/delphi-compiler-versions

**Direct downloads:**
- [CD_DELPHI_VERSIONS.inc](https://github.com/continuous-delphi/delphi-compiler-versions/releases/download/vX.Y.Z/CD_DELPHI_VERSIONS.inc)
- [DelphiCompilerVersions.pas](https://github.com/continuous-delphi/delphi-compiler-versions/releases/download/vX.Y.Z/DelphiCompilerVersions.pas)
- [delphi-compiler-versions.json](https://github.com/continuous-delphi/delphi-compiler-versions/releases/download/vX.Y.Z/delphi-compiler-versions.json)

This release publishes an updated dataset of Delphi compiler versions
and the generated artifacts used by Delphi projects and tooling.

## Versions

- **Release:** vX.Y.Z
- **dataVersion:** DATA_VERSION
- **schemaVersion:** SCHEMA_VERSION

Canonical JSON schema (versioned, immutable):

https://continuous-delphi.github.io/delphi-compiler-versions/schemas/1.0.0/delphi-compiler-versions.schema.json


---

# Artifacts

The following files are attached to this release.

| File | Purpose |
|------|---------|
| `CD_DELPHI_VERSIONS.inc` | Conditional defines for Delphi compiler detection |
| `DelphiCompilerVersions.pas` | Runtime lookup unit for Delphi compiler information |
| `delphi-compiler-versions.json` | Canonical dataset used by generators and tools |

---

# Quick Usage

## Delphi include file

```pascal
{$I CD_DELPHI_VERSIONS.inc}

{$IFDEF VER360}
  // Delphi 12 Athens
{$ENDIF}
```

---

## Delphi runtime unit

```pascal
uses DelphiCompilerVersions;

var
  V: TDelphiVersion;
begin
  if IsCurrentDelphiCompilerVersionKnown then
  begin
    V := CurrentDelphiCompilerVersion;
    ShowMessage(V.ProductName);
  end;
end;
```

---

## JSON dataset

Tools and build systems can consume the dataset directly.

Example (selected fields shown):

```json
{
  "verDefine": "VER360",
  "productName": "Delphi 12 Athens",
  "compilerVersion": "36.0"
}
```

---

# Notes

- The JSON schema is published via **GitHub Pages** and is not duplicated as a release asset.
- Source files, tests, and generators are included in the repository source archive.

---

# Continuous Delphi

Part of the **Continuous Delphi** initiative:

https://github.com/continuous-delphi
