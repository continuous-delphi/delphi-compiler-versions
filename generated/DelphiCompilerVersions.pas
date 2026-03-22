unit DelphiCompilerVersions;

interface

type
  TDelphiPlatform = (
    Android32Target,
    Android64Target,
    IOS32Target,
    IOS64Target,
    IOSSimulator32Target,
    IOSSimulator64Target,
    Linux64Target,
    MacOS32Target,
    MacOS64Target,
    MacOSARM64Target,
    Win32Target,
    Win64Target,
    WinARM64ECTarget
  );

  TDelphiPlatforms = set of TDelphiPlatform;

  TDelphiBuildSystem = (
    DCCSystem,
    MSBuildSystem
  );

  TDelphiBuildSystems = set of TDelphiBuildSystem;

  TDelphiVersion = record
    VerDefine: string;
    CompilerVersion: string;
    ProductName: string;
    PackageVersion: string;
    RegKeyRelativePath: string;
    SupportedPlatforms: TDelphiPlatforms;
    SupportedBuildSystems: TDelphiBuildSystems;
    AliasesCsv: string;
  end;

  PDelphiVersion = ^TDelphiVersion;

const
  CD_SCHEMA_VERSION = '1.1.0';
  CD_DATA_VERSION   = '1.1.0';

  DelphiVersions: array[0..26] of TDelphiVersion =
  (
    (
      VerDefine: 'VER90';
      CompilerVersion: '9.0';
      ProductName: 'Delphi 2';
      PackageVersion: '20';
      RegKeyRelativePath: '\Software\Borland\Delphi\2.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem];
      AliasesCsv: 'Delphi2;D2';
    ),
    (
      VerDefine: 'VER100';
      CompilerVersion: '10.0';
      ProductName: 'Delphi 3';
      PackageVersion: '30';
      RegKeyRelativePath: '\Software\Borland\Delphi\3.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem];
      AliasesCsv: 'Delphi3;D3';
    ),
    (
      VerDefine: 'VER120';
      CompilerVersion: '12.0';
      ProductName: 'Delphi 4';
      PackageVersion: '40';
      RegKeyRelativePath: '\Software\Borland\Delphi\4.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem];
      AliasesCsv: 'Delphi4;D4';
    ),
    (
      VerDefine: 'VER130';
      CompilerVersion: '13.0';
      ProductName: 'Delphi 5';
      PackageVersion: '50';
      RegKeyRelativePath: '\Software\Borland\Delphi\5.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem];
      AliasesCsv: 'Delphi5;D5';
    ),
    (
      VerDefine: 'VER140';
      CompilerVersion: '14.0';
      ProductName: 'Delphi 6';
      PackageVersion: '60';
      RegKeyRelativePath: '\Software\Borland\Delphi\6.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem];
      AliasesCsv: 'Delphi6;D6';
    ),
    (
      VerDefine: 'VER150';
      CompilerVersion: '15.0';
      ProductName: 'Delphi 7';
      PackageVersion: '70';
      RegKeyRelativePath: '\Software\Borland\Delphi\7.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem];
      AliasesCsv: 'Delphi7;D7';
    ),
    (
      VerDefine: 'VER170';
      CompilerVersion: '17.0';
      ProductName: 'Delphi 2005';
      PackageVersion: '90';
      RegKeyRelativePath: '\Software\Borland\BDS\3.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem];
      AliasesCsv: 'Delphi2005;D2005';
    ),
    (
      VerDefine: 'VER180';
      CompilerVersion: '18.0';
      ProductName: 'Delphi 2006';
      PackageVersion: '100';
      RegKeyRelativePath: '\Software\Borland\BDS\4.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem];
      AliasesCsv: 'Delphi2006;D2006';
    ),
    (
      VerDefine: 'VER185';
      CompilerVersion: '18.5';
      ProductName: 'Delphi 2007';
      PackageVersion: '110';
      RegKeyRelativePath: '\Software\Borland\BDS\5.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi2007;D2007';
    ),
    (
      VerDefine: 'VER200';
      CompilerVersion: '20.0';
      ProductName: 'Delphi 2009';
      PackageVersion: '120';
      RegKeyRelativePath: '\Software\CodeGear\BDS\6.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi2009;D2009';
    ),
    (
      VerDefine: 'VER210';
      CompilerVersion: '21.0';
      ProductName: 'Delphi 2010';
      PackageVersion: '140';
      RegKeyRelativePath: '\Software\CodeGear\BDS\7.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi2010;D2010';
    ),
    (
      VerDefine: 'VER220';
      CompilerVersion: '22.0';
      ProductName: 'Delphi XE';
      PackageVersion: '150';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\8.0';
      SupportedPlatforms: [Win32Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'DelphiXE;XE';
    ),
    (
      VerDefine: 'VER230';
      CompilerVersion: '23.0';
      ProductName: 'Delphi XE2';
      PackageVersion: '160';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\9.0';
      SupportedPlatforms: [MacOS32Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'DelphiXE2;XE2';
    ),
    (
      VerDefine: 'VER240';
      CompilerVersion: '24.0';
      ProductName: 'Delphi XE3';
      PackageVersion: '170';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\10.0';
      SupportedPlatforms: [MacOS32Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'DelphiXE3;XE3';
    ),
    (
      VerDefine: 'VER250';
      CompilerVersion: '25.0';
      ProductName: 'Delphi XE4';
      PackageVersion: '180';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\11.0';
      SupportedPlatforms: [IOS32Target, IOSSimulator32Target, MacOS32Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'DelphiXE4;XE4';
    ),
    (
      VerDefine: 'VER260';
      CompilerVersion: '26.0';
      ProductName: 'Delphi XE5';
      PackageVersion: '190';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\12.0';
      SupportedPlatforms: [Android32Target, IOS32Target, IOSSimulator32Target, MacOS32Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'DelphiXE5;XE5';
    ),
    (
      VerDefine: 'VER270';
      CompilerVersion: '27.0';
      ProductName: 'Delphi XE6';
      PackageVersion: '200';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\14.0';
      SupportedPlatforms: [Android32Target, IOS32Target, IOSSimulator32Target, MacOS32Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'DelphiXE6;XE6';
    ),
    (
      VerDefine: 'VER280';
      CompilerVersion: '28.0';
      ProductName: 'Delphi XE7';
      PackageVersion: '210';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\15.0';
      SupportedPlatforms: [Android32Target, IOS32Target, IOSSimulator32Target, MacOS32Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'DelphiXE7;XE7';
    ),
    (
      VerDefine: 'VER290';
      CompilerVersion: '29.0';
      ProductName: 'Delphi XE8';
      PackageVersion: '220';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\16.0';
      SupportedPlatforms: [Android32Target, IOS32Target, IOSSimulator32Target, MacOS32Target, MacOS64Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'DelphiXE8;XE8';
    ),
    (
      VerDefine: 'VER300';
      CompilerVersion: '30.0';
      ProductName: 'Delphi 10 Seattle';
      PackageVersion: '230';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\17.0';
      SupportedPlatforms: [Android32Target, IOS32Target, IOS64Target, IOSSimulator32Target, MacOS32Target, MacOS64Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi 10;Seattle;10 Seattle';
    ),
    (
      VerDefine: 'VER310';
      CompilerVersion: '31.0';
      ProductName: 'Delphi 10.1 Berlin';
      PackageVersion: '240';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\18.0';
      SupportedPlatforms: [Android32Target, IOS32Target, IOS64Target, IOSSimulator32Target, MacOS32Target, MacOS64Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi 10.1;Berlin;10.1 Berlin';
    ),
    (
      VerDefine: 'VER320';
      CompilerVersion: '32.0';
      ProductName: 'Delphi 10.2 Tokyo';
      PackageVersion: '250';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\19.0';
      SupportedPlatforms: [Android32Target, IOS32Target, IOS64Target, IOSSimulator32Target, Linux64Target, MacOS32Target, MacOS64Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi 10.2;Tokyo;10.2 Tokyo';
    ),
    (
      VerDefine: 'VER330';
      CompilerVersion: '33.0';
      ProductName: 'Delphi 10.3 Rio';
      PackageVersion: '260';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\20.0';
      SupportedPlatforms: [Android32Target, Android64Target, IOS32Target, IOS64Target, IOSSimulator32Target, Linux64Target, MacOS64Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi 10.3;Rio;10.3 Rio';
    ),
    (
      VerDefine: 'VER340';
      CompilerVersion: '34.0';
      ProductName: 'Delphi 10.4 Sydney';
      PackageVersion: '270';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\21.0';
      SupportedPlatforms: [Android32Target, Android64Target, IOS32Target, IOS64Target, Linux64Target, MacOS64Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi 10.4;Sydney;10.4 Sydney';
    ),
    (
      VerDefine: 'VER350';
      CompilerVersion: '35.0';
      ProductName: 'Delphi 11 Alexandria';
      PackageVersion: '280';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\22.0';
      SupportedPlatforms: [Android32Target, Android64Target, IOS32Target, IOS64Target, IOSSimulator64Target, Linux64Target, MacOS64Target, MacOSARM64Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi 11;Alexandria;11 Alexandria';
    ),
    (
      VerDefine: 'VER360';
      CompilerVersion: '36.0';
      ProductName: 'Delphi 12 Athens';
      PackageVersion: '290';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\23.0';
      SupportedPlatforms: [Android32Target, Android64Target, IOS64Target, IOSSimulator64Target, Linux64Target, MacOS64Target, MacOSARM64Target, Win32Target, Win64Target];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi 12;Athens;12 Athens';
    ),
    (
      VerDefine: 'VER370';
      CompilerVersion: '37.0';
      ProductName: 'Delphi 13 Florence';
      PackageVersion: '370';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\37.0';
      SupportedPlatforms: [Android32Target, Android64Target, IOS64Target, IOSSimulator64Target, Linux64Target, MacOS64Target, MacOSARM64Target, Win32Target, Win64Target, WinARM64ECTarget];
      SupportedBuildSystems: [DCCSystem, MSBuildSystem];
      AliasesCsv: 'Delphi 13;Florence;13 Florence';
    )
  );

function TryGetDelphiVersionByVerDefine(const AVerDefine: string; var AVersion: TDelphiVersion): Boolean;
function TryGetDelphiVersionByProductName(const AProductName: string; var AVersion: TDelphiVersion): Boolean;
function TryGetDelphiVersionByAlias(const AAlias: string; var AVersion: TDelphiVersion): Boolean;
function GetLatestDelphiVersion: TDelphiVersion;

var
  CurrentDelphiCompilerVersion: TDelphiVersion;
  IsCurrentDelphiCompilerVersionKnown: Boolean;

implementation

uses
{$IFDEF UNICODE}
  System.SysUtils
{$ELSE}
  SysUtils
{$ENDIF}
  ;

function TextEqualsIgnoreCase(const A, B: string): Boolean;
begin
  Result := CompareText(A, B) = 0;
end;

function TryGetDelphiVersionByVerDefine(const AVerDefine: string; var AVersion: TDelphiVersion): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(DelphiVersions) to High(DelphiVersions) do
  begin
    if TextEqualsIgnoreCase(DelphiVersions[I].VerDefine, AVerDefine) then
    begin
      AVersion := DelphiVersions[I];
      Result := True;
      Exit;
    end;
  end;
end;

function TryGetDelphiVersionByProductName(const AProductName: string; var AVersion: TDelphiVersion): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(DelphiVersions) to High(DelphiVersions) do
  begin
    if TextEqualsIgnoreCase(DelphiVersions[I].ProductName, AProductName) then
    begin
      AVersion := DelphiVersions[I];
      Result := True;
      Exit;
    end;
  end;
end;

function CsvContainsToken(const ACsv, AToken: string): Boolean;
var
  I, StartPos: Integer;
  Part: string;
begin
  Result := False;
  if (ACsv = '') or (AToken = '') then
  begin
    Exit;
  end;

  StartPos := 1;
  for I := 1 to Length(ACsv) + 1 do
  begin
    if (I > Length(ACsv)) or (ACsv[I] = ';') then
    begin
      Part := Trim(Copy(ACsv, StartPos, I - StartPos));
      if (Part <> '') and TextEqualsIgnoreCase(Part, AToken) then
      begin
        Result := True;
        Exit;
      end;
      StartPos := I + 1;
    end;
  end;
end;

function TryGetDelphiVersionByAlias(const AAlias: string; var AVersion: TDelphiVersion): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(DelphiVersions) to High(DelphiVersions) do
  begin
    if CsvContainsToken(DelphiVersions[I].AliasesCsv, AAlias) then
    begin
      AVersion := DelphiVersions[I];
      Result := True;
      Exit;
    end;
  end;
end;

function GetLatestDelphiVersion: TDelphiVersion;
begin
  Result := DelphiVersions[High(DelphiVersions)];
end;

initialization

  {$IFDEF VER90}
    CurrentDelphiCompilerVersion := DelphiVersions[0];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER100}
    CurrentDelphiCompilerVersion := DelphiVersions[1];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER120}
    CurrentDelphiCompilerVersion := DelphiVersions[2];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER130}
    CurrentDelphiCompilerVersion := DelphiVersions[3];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER140}
    CurrentDelphiCompilerVersion := DelphiVersions[4];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER150}
    CurrentDelphiCompilerVersion := DelphiVersions[5];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER170}
    CurrentDelphiCompilerVersion := DelphiVersions[6];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER180}{$IFNDEF VER185}
    CurrentDelphiCompilerVersion := DelphiVersions[7];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}{$ENDIF}

  {$IFDEF VER185}
    CurrentDelphiCompilerVersion := DelphiVersions[8];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER200}
    CurrentDelphiCompilerVersion := DelphiVersions[9];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER210}
    CurrentDelphiCompilerVersion := DelphiVersions[10];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER220}
    CurrentDelphiCompilerVersion := DelphiVersions[11];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER230}
    CurrentDelphiCompilerVersion := DelphiVersions[12];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER240}
    CurrentDelphiCompilerVersion := DelphiVersions[13];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER250}
    CurrentDelphiCompilerVersion := DelphiVersions[14];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER260}
    CurrentDelphiCompilerVersion := DelphiVersions[15];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER270}
    CurrentDelphiCompilerVersion := DelphiVersions[16];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER280}
    CurrentDelphiCompilerVersion := DelphiVersions[17];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER290}
    CurrentDelphiCompilerVersion := DelphiVersions[18];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER300}
    CurrentDelphiCompilerVersion := DelphiVersions[19];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER310}
    CurrentDelphiCompilerVersion := DelphiVersions[20];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER320}
    CurrentDelphiCompilerVersion := DelphiVersions[21];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER330}
    CurrentDelphiCompilerVersion := DelphiVersions[22];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER340}
    CurrentDelphiCompilerVersion := DelphiVersions[23];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER350}
    CurrentDelphiCompilerVersion := DelphiVersions[24];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER360}
    CurrentDelphiCompilerVersion := DelphiVersions[25];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER370}
    CurrentDelphiCompilerVersion := DelphiVersions[26];
    IsCurrentDelphiCompilerVersionKnown := True;
  {$ENDIF}

end.
