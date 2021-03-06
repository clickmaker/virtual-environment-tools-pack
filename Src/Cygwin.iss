[Files]
Source: "Files\chef-alias-set.sh"; DestDir: "{tmp}";

[Code]
(**---------------------------
 * Cygwin functions
 * --------------------------- *)

(**
 * Cygwin_Exists
 *   check if Cygwin has already been installed
 *)
function Cygwin_Exists(): Boolean;
begin
    Result := RegKeyExists(GetHKLM, 'SOFTWARE\Cygwin');
end;

(**
 * Cygwin_Install
 *   execute Cygwin installer
 *)
procedure Cygwin_Install(InstallerPath: String);
var
    SoftName:    String;
    ExecCommand: String;
    Params:      String;
    LocalRoot:   String;
begin
    SoftName  := 'Cygwin';
    LocalRoot := ExpandConstant('{pf}\cygwin');

    CreateDir(LocalRoot);
    ExecCommand := LocalRoot + '\cygwinsetup.exe';
    FileCopy(InstallerPath, ExecCommand, False);

    // quiet mode
    if CustomizeForms.AutoInstallCheckBox.Checked then
    begin
       Params  := Params + ' -q ';
    end;

    // proxy
    if ProxyForms.UseProxyCheckBox.Checked then
    begin
        Params := Params + ' -p ' + ProxyForms.ProxyAddressTextBox.Text + ':' + ProxyForms.ProxyPortTextBox.Text;
    end;

    // packages
    Params := Params + ' -P "rsync,openssh"';

    // repository
    Params := Params + ' -s ' + GetIniString(SoftName, SoftName + 'RepositoryUrl', '', ExpandConstant('{tmp}\Setup.ini'));

    // local pacakge dir
    // Params := Params + ' -l "' +  LocalRoot  + '"';

    // execute
    ExecOtherInstaller(SoftName, ExecCommand, Params);
end;

procedure Cygwin_PathSet;
var
    InstalledDir: String;
    ResultCode:   Integer;
begin
    if RegQueryStringValue(GetHKLM, 'SOFTWARE\Cygwin\setup', 'rootdir', InstalledDir) then
    begin
        // set path to use cygwin command in ms-dos prompt
        RegAddEnvironment('Path', InstalledDir, ';');
        RegAddEnvironment('Path', ExpandConstant(InstalledDir + '\bin'), ';');

        // set cdrive symbolyc link
        // Exec(InstalledDir + '\bin\run.exe', InstalledDir + '\bin\bash -l -c "ln -snf /cygdrive/c /c;"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

        // set alias to use chef commands in cygwin
        if ChefDK_Exists then
        begin
            ExtractTemporaryFile(ExpandConstant('chef-alias-set.sh'));
            FileCopy(ExpandConstant('{tmp}\chef-alias-set.sh'), InstalledDir + '\tmp\chef-alias-set.sh', False);

            Exec(InstalledDir + '\bin\run.exe', InstalledDir + '\bin\bash -l /tmp/chef-alias-set.sh', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
        end;
    end;
end;

