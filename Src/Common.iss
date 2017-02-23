[Code]
function StrContain(SearchText: String; TargetText: String; Delimiter: String): Integer;
begin
    Result := Pos(Delimiter + SearchText + Delimiter, Delimiter + TargetText + Delimiter);
end;

function GetInstallerSavedPath(FileName: String): String;
begin
    Result := ExpandConstant('{app}') + '\' + ExpandConstant(FileName);
end;

procedure DownloadFile(Url: String; FileName: String; AfterID: Integer);
var
    SavePath: String;
begin
    SavePath := GetInstallerSavedPath(FileName);
    if not FileExists(SavePath) then
    begin
        idpAddFile(Url, ExpandConstant(SavePath));
        idpDownloadAfter(AfterID);
    end;
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
