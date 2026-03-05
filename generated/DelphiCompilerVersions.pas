unit DelphiCompilerVersions;

interface

type
  TCDDelphiPlatform = (
    dpAndroid32,
    dpAndroid64,
    dpIOS,
    dpIOSSimulator,
    dpLinux64,
    dpMacOS32,
    dpMacOS64,
    dpMacOSARM64,
    dpWin32,
    dpWin64
  );

  TCDDelphiPlatforms = set of TCDDelphiPlatform;

  TCDDelphiBuildSystem = (
    dbDCC,
    dbMSBuild
  );

  TCDDelphiBuildSystems = set of TCDDelphiBuildSystem;

  TCDDelphiVersion = record
    VerDefine: string;
    CompilerVersion: string;
    ProductName: string;
    PackageVersion: string;
    RegKeyRelativePath: string;
    SupportedPlatforms: TCDDelphiPlatforms;
    SupportedBuildSystems: TCDDelphiBuildSystems;
    AliasesCsv: string;
  end;

  PCDDelphiVersion = ^TCDDelphiVersion;

const
  CD_SCHEMA_VERSION = '1.0.0';
  CD_DATA_VERSION   = '0.5.0';

  CDDelphiVersions: array[0..26] of TCDDelphiVersion =
  (
    (
      VerDefine: 'VER90';
      CompilerVersion: '9.0';
      ProductName: 'Delphi 2';
      PackageVersion: '20';
      RegKeyRelativePath: '\Software\Borland\Delphi\2.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC];
      AliasesCsv: 'Delphi2;D2';
    ),
    (
      VerDefine: 'VER100';
      CompilerVersion: '10.0';
      ProductName: 'Delphi 3';
      PackageVersion: '30';
      RegKeyRelativePath: '\Software\Borland\Delphi\3.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC];
      AliasesCsv: 'Delphi3;D3';
    ),
    (
      VerDefine: 'VER120';
      CompilerVersion: '12.0';
      ProductName: 'Delphi 4';
      PackageVersion: '40';
      RegKeyRelativePath: '\Software\Borland\Delphi\4.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC];
      AliasesCsv: 'Delphi4;D4';
    ),
    (
      VerDefine: 'VER130';
      CompilerVersion: '13.0';
      ProductName: 'Delphi 5';
      PackageVersion: '50';
      RegKeyRelativePath: '\Software\Borland\Delphi\5.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC];
      AliasesCsv: 'Delphi5;D5';
    ),
    (
      VerDefine: 'VER140';
      CompilerVersion: '14.0';
      ProductName: 'Delphi 6';
      PackageVersion: '60';
      RegKeyRelativePath: '\Software\Borland\Delphi\6.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC];
      AliasesCsv: 'Delphi6;D6';
    ),
    (
      VerDefine: 'VER150';
      CompilerVersion: '15.0';
      ProductName: 'Delphi 7';
      PackageVersion: '70';
      RegKeyRelativePath: '\Software\Borland\Delphi\7.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC];
      AliasesCsv: 'Delphi7;D7';
    ),
    (
      VerDefine: 'VER170';
      CompilerVersion: '17.0';
      ProductName: 'Delphi 2005';
      PackageVersion: '90';
      RegKeyRelativePath: '\Software\Borland\BDS\3.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC];
      AliasesCsv: 'Delphi2005;D2005';
    ),
    (
      VerDefine: 'VER180';
      CompilerVersion: '18.0';
      ProductName: 'Delphi 2006';
      PackageVersion: '100';
      RegKeyRelativePath: '\Software\Borland\BDS\4.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC];
      AliasesCsv: 'Delphi2006;D2006';
    ),
    (
      VerDefine: 'VER185';
      CompilerVersion: '18.5';
      ProductName: 'Delphi 2007';
      PackageVersion: '110';
      RegKeyRelativePath: '\Software\Borland\BDS\5.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi2007;D2007';
    ),
    (
      VerDefine: 'VER200';
      CompilerVersion: '20.0';
      ProductName: 'Delphi 2009';
      PackageVersion: '120';
      RegKeyRelativePath: '\Software\CodeGear\BDS\6.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi2009;D2009';
    ),
    (
      VerDefine: 'VER210';
      CompilerVersion: '21.0';
      ProductName: 'Delphi 2010';
      PackageVersion: '140';
      RegKeyRelativePath: '\Software\CodeGear\BDS\7.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi2010;D2010';
    ),
    (
      VerDefine: 'VER220';
      CompilerVersion: '22.0';
      ProductName: 'Delphi XE';
      PackageVersion: '150';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\8.0';
      SupportedPlatforms: [dpWin32];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'DelphiXE;XE';
    ),
    (
      VerDefine: 'VER230';
      CompilerVersion: '23.0';
      ProductName: 'Delphi XE2';
      PackageVersion: '160';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\9.0';
      SupportedPlatforms: [dpMacOS32, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'DelphiXE2;XE2';
    ),
    (
      VerDefine: 'VER240';
      CompilerVersion: '24.0';
      ProductName: 'Delphi XE3';
      PackageVersion: '170';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\10.0';
      SupportedPlatforms: [dpMacOS32, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'DelphiXE3;XE3';
    ),
    (
      VerDefine: 'VER250';
      CompilerVersion: '25.0';
      ProductName: 'Delphi XE4';
      PackageVersion: '180';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\11.0';
      SupportedPlatforms: [dpIOS, dpMacOS32, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'DelphiXE4;XE4';
    ),
    (
      VerDefine: 'VER260';
      CompilerVersion: '26.0';
      ProductName: 'Delphi XE5';
      PackageVersion: '190';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\12.0';
      SupportedPlatforms: [dpAndroid32, dpIOS, dpMacOS32, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'DelphiXE5;XE5';
    ),
    (
      VerDefine: 'VER270';
      CompilerVersion: '27.0';
      ProductName: 'Delphi XE6';
      PackageVersion: '200';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\14.0';
      SupportedPlatforms: [dpAndroid32, dpIOS, dpMacOS32, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'DelphiXE6;XE6';
    ),
    (
      VerDefine: 'VER280';
      CompilerVersion: '28.0';
      ProductName: 'Delphi XE7';
      PackageVersion: '210';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\15.0';
      SupportedPlatforms: [dpAndroid32, dpIOS, dpMacOS32, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'DelphiXE7;XE7';
    ),
    (
      VerDefine: 'VER290';
      CompilerVersion: '29.0';
      ProductName: 'Delphi XE8';
      PackageVersion: '220';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\16.0';
      SupportedPlatforms: [dpAndroid32, dpIOS, dpMacOS32, dpMacOS64, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'DelphiXE8;XE8';
    ),
    (
      VerDefine: 'VER300';
      CompilerVersion: '30.0';
      ProductName: 'Delphi 10 Seattle';
      PackageVersion: '230';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\17.0';
      SupportedPlatforms: [dpAndroid32, dpIOS, dpMacOS32, dpMacOS64, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi 10;Seattle;10 Seattle';
    ),
    (
      VerDefine: 'VER310';
      CompilerVersion: '31.0';
      ProductName: 'Delphi 10.1 Berlin';
      PackageVersion: '240';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\18.0';
      SupportedPlatforms: [dpAndroid32, dpIOS, dpMacOS32, dpMacOS64, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi 10.1;Berlin;10.1 Berlin';
    ),
    (
      VerDefine: 'VER320';
      CompilerVersion: '32.0';
      ProductName: 'Delphi 10.2 Tokyo';
      PackageVersion: '250';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\19.0';
      SupportedPlatforms: [dpAndroid32, dpIOS, dpLinux64, dpMacOS32, dpMacOS64, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi 10.2;Tokyo;10.2 Tokyo';
    ),
    (
      VerDefine: 'VER330';
      CompilerVersion: '33.0';
      ProductName: 'Delphi 10.3 Rio';
      PackageVersion: '260';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\20.0';
      SupportedPlatforms: [dpAndroid32, dpAndroid64, dpIOS, dpIOSSimulator, dpLinux64, dpMacOS64, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi 10.3;Rio;10.3 Rio';
    ),
    (
      VerDefine: 'VER340';
      CompilerVersion: '34.0';
      ProductName: 'Delphi 10.4 Sydney';
      PackageVersion: '270';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\21.0';
      SupportedPlatforms: [dpAndroid32, dpAndroid64, dpIOS, dpIOSSimulator, dpLinux64, dpMacOS64, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi 10.4;Sydney;10.4 Sydney';
    ),
    (
      VerDefine: 'VER350';
      CompilerVersion: '35.0';
      ProductName: 'Delphi 11 Alexandria';
      PackageVersion: '280';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\22.0';
      SupportedPlatforms: [dpAndroid32, dpAndroid64, dpIOS, dpIOSSimulator, dpLinux64, dpMacOS64, dpMacOSARM64, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi 11;Alexandria;11 Alexandria';
    ),
    (
      VerDefine: 'VER360';
      CompilerVersion: '36.0';
      ProductName: 'Delphi 12 Athens';
      PackageVersion: '290';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\23.0';
      SupportedPlatforms: [dpAndroid32, dpAndroid64, dpIOS, dpIOSSimulator, dpLinux64, dpMacOS64, dpMacOSARM64, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi 12;Athens;12 Athens';
    ),
    (
      VerDefine: 'VER370';
      CompilerVersion: '37.0';
      ProductName: 'Delphi 13 Florence';
      PackageVersion: '370';
      RegKeyRelativePath: '\Software\Embarcadero\BDS\37.0';
      SupportedPlatforms: [dpAndroid32, dpAndroid64, dpIOS, dpIOSSimulator, dpLinux64, dpMacOS64, dpMacOSARM64, dpWin32, dpWin64];
      SupportedBuildSystems: [dbDCC, dbMSBuild];
      AliasesCsv: 'Delphi 13;Florence;13 Florence';
    )
  );

function CDTryGetVersionByVerDefine(const AVerDefine: string; var AVersion: TCDDelphiVersion): Boolean;
function CDTryGetVersionByProductName(const AProductName: string; var AVersion: TCDDelphiVersion): Boolean;
function CDTryGetVersionByAlias(const AAlias: string; var AVersion: TCDDelphiVersion): Boolean;
function CDGetLatestVersion: TCDDelphiVersion;

var
  CDCurrentCompilerVersion: TCDDelphiVersion;
  CDCurrentCompilerVersionKnown: Boolean;

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

function CDTryGetVersionByVerDefine(const AVerDefine: string; var AVersion: TCDDelphiVersion): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(CDDelphiVersions) to High(CDDelphiVersions) do
  begin
    if TextEqualsIgnoreCase(CDDelphiVersions[I].VerDefine, AVerDefine) then
    begin
      AVersion := CDDelphiVersions[I];
      Result := True;
      Exit;
    end;
  end;
end;

function CDTryGetVersionByProductName(const AProductName: string; var AVersion: TCDDelphiVersion): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(CDDelphiVersions) to High(CDDelphiVersions) do
  begin
    if TextEqualsIgnoreCase(CDDelphiVersions[I].ProductName, AProductName) then
    begin
      AVersion := CDDelphiVersions[I];
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
    Result := False;
    Exit;

  StartPos := 1;
  for I := 1 to Length(ACsv) + 1 do
  begin
    if (I > Length(ACsv)) or (ACsv[I] = ';') then
    begin
      Part := Trim(Copy(ACsv, StartPos, I - StartPos));
      if (Part <> '') and TextEqualsIgnoreCase(Part, AToken) then
        Result := True;
        Exit;
      StartPos := I + 1;
    end;
  end;
end;

function CDTryGetVersionByAlias(const AAlias: string; var AVersion: TCDDelphiVersion): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(CDDelphiVersions) to High(CDDelphiVersions) do
  begin
    if CsvContainsToken(CDDelphiVersions[I].AliasesCsv, AAlias) then
    begin
      AVersion := CDDelphiVersions[I];
      Result := True;
      Exit;
    end;
  end;
end;

function CDGetLatestVersion: TCDDelphiVersion;
begin
  Result := CDDelphiVersions[High(CDDelphiVersions)];
end;

initialization

  {$IFDEF VER90}
    CDCurrentCompilerVersion := CDDelphiVersions[0];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER100}
    CDCurrentCompilerVersion := CDDelphiVersions[1];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER120}
    CDCurrentCompilerVersion := CDDelphiVersions[2];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER130}
    CDCurrentCompilerVersion := CDDelphiVersions[3];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER140}
    CDCurrentCompilerVersion := CDDelphiVersions[4];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER150}
    CDCurrentCompilerVersion := CDDelphiVersions[5];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER170}
    CDCurrentCompilerVersion := CDDelphiVersions[6];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER180}{$IFNDEF VER185}
    CDCurrentCompilerVersion := CDDelphiVersions[7];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}{$ENDIF}

  {$IFDEF VER185}
    CDCurrentCompilerVersion := CDDelphiVersions[8];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER200}
    CDCurrentCompilerVersion := CDDelphiVersions[9];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER210}
    CDCurrentCompilerVersion := CDDelphiVersions[10];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER220}
    CDCurrentCompilerVersion := CDDelphiVersions[11];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER230}
    CDCurrentCompilerVersion := CDDelphiVersions[12];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER240}
    CDCurrentCompilerVersion := CDDelphiVersions[13];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER250}
    CDCurrentCompilerVersion := CDDelphiVersions[14];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER260}
    CDCurrentCompilerVersion := CDDelphiVersions[15];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER270}
    CDCurrentCompilerVersion := CDDelphiVersions[16];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER280}
    CDCurrentCompilerVersion := CDDelphiVersions[17];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER290}
    CDCurrentCompilerVersion := CDDelphiVersions[18];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER300}
    CDCurrentCompilerVersion := CDDelphiVersions[19];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER310}
    CDCurrentCompilerVersion := CDDelphiVersions[20];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER320}
    CDCurrentCompilerVersion := CDDelphiVersions[21];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER330}
    CDCurrentCompilerVersion := CDDelphiVersions[22];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER340}
    CDCurrentCompilerVersion := CDDelphiVersions[23];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER350}
    CDCurrentCompilerVersion := CDDelphiVersions[24];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER360}
    CDCurrentCompilerVersion := CDDelphiVersions[25];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

  {$IFDEF VER370}
    CDCurrentCompilerVersion := CDDelphiVersions[26];
    CDCurrentCompilerVersionKnown := True;
  {$ENDIF}

end.
