![delphi-compiler-versions logo](https://continuous-delphi.github.io/assets/logos/delphi-compiler-versions-480x270.png)

https://github.com/continuous-delphi/delphi-compiler-versions

**Tag:** `vX.Y.Z`

**Direct downloads:**
- [DELPHI_COMPILER_VERSIONS.inc](https://github.com/continuous-delphi/delphi-compiler-versions/releases/download/vX.Y.Z/DELPHI_COMPILER_VERSIONS.inc)
- [DelphiCompilerVersions.pas](https://github.com/continuous-delphi/delphi-compiler-versions/releases/download/vX.Y.Z/DelphiCompilerVersions.pas)
- [PlatformSupport.md](https://github.com/continuous-delphi/delphi-compiler-versions/releases/download/vX.Y.Z/PlatformSupport.md)
- [delphi-compiler-versions.json](https://github.com/continuous-delphi/delphi-compiler-versions/releases/download/vX.Y.Z/delphi-compiler-versions.json)

This release publishes an updated dataset of Delphi compiler versions
and the generated artifacts used by Delphi projects and tooling.

## Versions

- **Release:** vX.Y.Z
- **dataVersion:** DATA_VERSION
- **schemaVersion:** SCHEMA_VERSION

---

# Artifacts

The following files are attached to this release.

| File | Purpose |
|------|---------|
| `DELPHI_COMPILER_VERSIONS.inc` | Conditional defines for Delphi compiler detection |
| `DelphiCompilerVersions.pas` | Runtime lookup unit for Delphi compiler information |
| `PlatformSupport.md` | Visual cross reference of platforms supported by Delphi version |
| `delphi-compiler-versions.json` | Canonical dataset used by generators and tools |

---

# Quick Usage

## Delphi include file

```pascal
{$I DELPHI_COMPILER_VERSIONS.inc}

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
