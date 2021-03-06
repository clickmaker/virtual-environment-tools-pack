; Virtual Environment Tools Pack
;
; this install virtual environment tools (virtualbox, vagrant, chefdk, cygwin) all at once,
; for development in Windows.
;
; Install
;   - VirtualBox
;   - Vagrant
;   - ChefDK
;   - Cygwin
; Set Registory
;   - Proxy Setting
;   - Envrionment Path
;

; define constants
#define MyPublisher  "ClickMaker"
#define MyAppName    "VETs (Virtual Environment Tools) Pack"
#define MyAppAlias   "VETs Pack"
#define MyAppVersion "0.1.22"
#define MyOutputFile StringChange(MyAppAlias, " ", "_") + "-" + MyAppVersion

; include InnoSetup download plugin
#include <idp.iss>

; inclue sources
#include "Src\Common.iss"
#include "Src\Registry.iss"
#include "Src\ProxyPage.iss"
#include "Src\CustomizePage.iss"
#include "Src\Virtualbox.iss"
#include "Src\Vagrant.iss"
#include "Src\ChefDK.iss"
#include "Src\Cygwin.iss"

[Setup]
; setup basic info
AppName            = {#MyAppName}
AppVerName         = {#MyAppName} {#MyAppVersion}
AppPublisher       = {#MyPublisher}
VersionInfoVersion = {#MyAppVersion}
OutputBaseFilename = {#MyOutputFile}

; enable logging
SetupLogging       = yes

; require admin execution
PrivilegesRequired = admin

; default pages setting
ShowLanguageDialog   = yes
DisableWelcomePage   = yes
LicenseFile          = ""
Password             = ""
InfoBeforeFile       = ""
UserInfoPage         = no
DisableDirPage       = yes
DefaultDirName       = {pf}\{#MyPublisher}\{#emit StringChange(MyAppAlias, " ", "")}
UsePreviousAppDir    = yes
AppendDefaultDirName = no
DisableReadyPage     = no


[Languages]
Name: japanese; \
    MessagesFile: "compiler:\Languages\Japanese.isl,{__FILE__}\..\Messages\Japanese.isl"; \
    InfoBeforeFile: "Readme_JP.md"

Name: english; \
    MessagesFile: "compiler:Default.isl,{__FILE__}\..\Messages\English.isl"; \
    InfoBeforeFile: "Readme.md"

[Files]
Source: "Files\Setup.ini"; DestDir: "{tmp}"; Flags: dontcopy
Source: "Readme.md";       DestDir: "{app}";
Source: "Readme_JP.md";    DestDir: "{app}";

[Types]
Name: "custom"; Description: {cm:NormalInstallation}; Flags: iscustom

[Components]
Name: "VirtualBox"; Description: "VirtualBox";           Types: custom; Flags: disablenouninstallwarning;
Name: "Vagrant";    Description: "Vagrant";              Types: custom; Flags: disablenouninstallwarning;
Name: "ChefDK";     Description: "Chef Development Kit"; Types: custom; Flags: disablenouninstallwarning;
Name: "Cygwin";     Description: "cygwin";               Types: custom; Flags: disablenouninstallwarning;

[Code]
procedure ListUpSoftware;  forward;
procedure InstallSoftware; forward;
function  GetDownloadUrl  (SoftName: String): String; forward;
function  GetInstallerPath(SoftName: String): String; forward;

procedure InitializeWizard;
var
    RegPath:      String;
begin
    { define software names }
    DefineSoftNames;

    { extract setup.ini }
    ExtractTemporaryFile('Setup.ini');

{ create the custom pages }
    CreateProxyPage(wpInfoBefore);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
    if CurPageID = wpSelectComponents then
    begin
        { create custom pages after selectdir. ( after app constant has defined ) }
        CreateCustomizePage(wpSelectComponents);
    end;

    if CurPageID = wpReady then
    begin
        { list up software to download }
        ListUpSoftware;
    end;

    if CurPageID = wpPreparing then
    begin
        { set proxy to registry }
        SetProxyToRegistry;

        { download starts set }
    //    idpDownloadAfter(wpPreparing);
    end;

    if CurPageID = wpInstalling then
    begin
        { install software }
    //    InstallSoftware;
    end;

    if CurPageID = wpFinished then
    begin
        SaveProxyPage;
        SaveCustomizePage;
        FileCopy(ExpandConstant('{tmp}\Setup.ini'), ExpandConstant('{app}\Setup.ini'), False);
    end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
    case CurStep of
        ssPostInstall:
        begin
            //DelTree(ExpandConstant('{tmp}') + '\*', False, True, True);
        end;
    end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
    case CurPageID of
        ProxyPage.ID:
        begin
        end;
    end;
    Result := True;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
    Result := False;
end;

procedure ListUpSoftware;
var
    SoftName:      String;
    DownloadUrl:   String;
    InstallerPath: String;
    i: Integer;
begin
    { reset file list }
    idpClearFiles;

    { add download file list }
    for i := 0 to (GetArrayLength(SoftNames) - 1) do
    begin
        SoftName := SoftNames[i];
        if IsComponentSelected(SoftName) then
        begin
            DownloadUrl   := GetDownloadUrl(SoftName);
            InstallerPath := GetInstallerPath(SoftName);
            if not FileExists(InstallerPath) then
            begin
                idpAddFile(DownloadUrl, InstallerPath);
            end;
        end;
    end;
end;


(**
 * InstallSoftware
 *   execute installers.
 *)
procedure InstallSoftware;
var
    SoftName:     String;
begin
    // install VirtualBox
    SoftName := 'VirtualBox';
    if IsComponentSelected(SoftName) then
    begin
        Virtualbox_Install(GetInstallerPath(SoftName));
    end;

    // install Vagrant
    SoftName := 'Vagrant';
    if IsComponentSelected(SoftName) then
    begin
        Vagrant_Install(GetInstallerPath(SoftName));
    end;

    // install ChefDK
    SoftName := 'ChefDK';
    if IsComponentSelected(SoftName) then
    begin
        ChefDK_Install(GetInstallerPath(SoftName));
    end;

    // install Cygwin
    SoftName := 'Cygwin';
    if IsComponentSelected(SoftName) then
    begin
        Cygwin_Install(GetInstallerPath(SoftName));
        if Cygwin_Exists then
        begin
            Cygwin_PathSet;
        end;
    end;
end;

(**
 * GetDownloadUrl
 *   get download url from setup.ini
 *)
function GetDownloadUrl (SoftName: String): String;
var
    Bit: String;
begin
    Bit := '';
    if SoftName = 'Cygwin' then
    begin
        if IsWin64 then
        begin
            Bit := '64';
        end else begin
            Bit := '32';
        end;
    end;
    Result := GetIniString(SoftName, SoftName + Bit + 'DownloadUrl',  '', ExpandConstant('{tmp}\Setup.ini'));
end;

(**
 * GetInstallerPath
 *   get the path of downloaded installer.
 *)
function GetInstallerPath(SoftName: String): String;
var
    DownloadDir: String;
    SaveFileName: String;
begin
    if CustomizeForms.RemainInstallerCheckBox.Checked then
    begin
        DownloadDir := CustomizeForms.RemainInstallerTextBox.Text;
    end else begin
        DownloadDir := '{tmp}';
    end;

    SaveFileName := RegexReplace(GetDownloadUrl(SoftName), '$1', '.*/([\w._-]+)$', True);

    Result := ExpandConstant(DownloadDir + '\' + SaveFileName);
end;
