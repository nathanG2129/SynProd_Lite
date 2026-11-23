#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

[Setup]
AppId={{8F3D9A4C-5E2B-4B1A-9C7E-3A1D2E4F5B6C}
AppName=SynProd Lite
AppVersion={#MyAppVersion}
AppVerName=SynProd Lite {#MyAppVersion}
AppPublisher=com.synprod
DefaultDirName={autopf}\SynProd Lite
DefaultGroupName=SynProd Lite
AllowNoIcons=yes
PrivilegesRequired=lowest
OutputDir=..\..\dist\windows
OutputBaseFilename=synprod_lite-{#MyAppVersion}-windows-x64-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\synprod_lite.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
RestartApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\SynProd Lite"; Filename: "{app}\synprod_lite.exe"
Name: "{group}\{cm:UninstallProgram,SynProd Lite}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\SynProd Lite"; Filename: "{app}\synprod_lite.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\synprod_lite.exe"; Description: "{cm:LaunchProgram,SynProd Lite}"; Flags: nowait postinstall
