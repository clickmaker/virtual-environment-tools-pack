[Code]
var
    SoftNames: Array of String;

{ define software names }
procedure DefineSoftNames;
begin
    SetArrayLength(SoftNames, 4);
    SoftNames[0] := 'VirtualBox';
    SoftNames[1] := 'Vagrant';
    SoftNames[2] := 'ChefDK';
    SoftNames[3] := 'Cygwin';
end;

procedure DebugBox(Message: String);
begin
    MsgBox(Message, mbInformation, MB_OK);
end;

function BoolToStr(Value: Boolean): String;
begin
    if Value then
    begin
        Result := 'True'
    end else begin
        Result := 'False';
    end;
end;

{ duplicate idp.iss }
// function StrToBool(Value: String): Boolean;

function RegexMatch(Target: String; Pattern: String; IgnoreCase: Boolean): Boolean;
var
    Regex: Variant;
begin
    Regex := CreateOleObject('VBScript.RegExp');
    IDispatchInvoke(Regex, True, 'Pattern', [Pattern]);
    IDispatchInvoke(Regex, True, 'IgnoreCase', [IgnoreCase]);
    Result := IDispatchInvoke(Regex, False, 'Test', [Target]);
end;

function RegexReplace(Target: String; Replace: String; Pattern: String; IgnoreCase: Boolean): String;
var
    Regex: Variant;
begin
    Regex := CreateOleObject('VBScript.RegExp');
    IDispatchInvoke(Regex, True, 'Pattern', [Pattern]);
    IDispatchInvoke(Regex, True, 'IgnoreCase', [IgnoreCase]);
    Result := IDispatchInvoke(Regex, False, 'Replace', [Target, Replace]);
end;

function GetWhichDir(CommandStr: String): String;
var
    TmpCommand: String;
    TmpFile:    String;
    ExecStdout: AnsiString;
    ResultCode: Integer;
begin
    TmpCommand := CommandStr;
    StringChangeEx(TmpCommand, '.', '_', True);

    TmpFile := ExpandConstant('{tmp}\which-') + TmpCommand + '-result.txt';
    SaveStringToFile(TmpFile, '', False);

    Exec('cmd.exe', '/C where ' + CommandStr + ' > "' + TmpFile + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    if LoadStringFromFile(TmpFile, ExecStdout) then
    begin
        Result := ExtractFileDir(ExecStdout);
    end else begin
        Result := '';
    end;

    DeleteFile(TmpFile);
end;

function ExecOtherInstaller(SoftName: String; ExecCommand: String; Params: String): Boolean;
var
    StatusText: String;
    ResultCode: Integer;
begin
    StatusText := WizardForm.StatusLabel.Caption;
    WizardForm.StatusLabel.Caption := 'Executing ' + SoftName + ' Installation.';
    WizardForm.ProgressGauge.Style := npbstMarquee;

    try
        Result := True;
        if not Exec(ExecCommand, Params, '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
        begin
            MsgBox(SoftName + ' installation failed with code: ' + IntToStr(ResultCode), mbError, MB_OK);
            Result := False;
        end;
    finally
        WizardForm.StatusLabel.Caption := StatusText;
        WizardForm.ProgressGauge.Style := npbstNormal;
    end;
end;

function GetSetupIniValue(Section: String; Key: String; Default: String; AppSetupFirstIfExists: Boolean): String;
var
    SetupFilePath: String;
begin
    if (AppSetupFirstIfExists and FileExists(ExpandConstant('{app}/Setup.ini'))) then
    begin
        SetupFilePath := '{app}/Setup.ini';
    end else begin
        SetupFilePath := '{tmp}/Setup.ini';
    end;

    Result := GetIniString(Section, Key, Default, ExpandConstant(SetupFilePath));
end;

function SetSetupIniValue(Section: String; Key: String; Value: String): Boolean;
var
    SetupFilePath: String;
begin
    SetupFilePath := '{tmp}/Setup.ini';

    Result := SetIniString(Section, Key, Value, ExpandConstant(SetupFilePath));
end;
