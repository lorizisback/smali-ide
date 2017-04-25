unit CommandUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Dialogs;

type
  TCommandType = (ctDecompile, ctCompile, ctInstallFramework, ctVersion, ctJadx, ctJadxDecompile, ctSsmaliDecompile, ctCommand);

  TOnCommandOutput = procedure(Sender: TObject; ACmdType: TCommandType; AOutput: string) of object;
  TOnCommandComplete = procedure (Sender: TObject; ACmdType: TCommandType; AParam: array of string) of object;

  { TCommandThread }

  TCommandThread = class(TThread)
  private
    FCmdType: TCommandType;
    FParam: array of string;
    FOnCommandComplete: TOnCommandComplete;
    FOnCommandOutput: TOnCommandOutput;
    // tmp
    FTmpOutput: string;
    FTmpProjectPath: string;
    FTmpDistPath: string;
    FTmpVersion: string;
    FTmpJadxVersion: string;
    procedure commandComplete(Sender: TObject);
  protected
    procedure SendSync();
    procedure Execute; override;
  public
    constructor Create(ACmdType: TCommandType; AParam: array of string);
  published
    property OnCommandOutput: TOnCommandOutput read FOnCommandOutput write FOnCommandOutput;
    property OnCommandComplete: TOnCommandComplete read FOnCommandComplete write FOnCommandComplete;
  end;

implementation

uses
  config, baseData;

{ TCommandThread }

function ExtractPureFileName(path: string): string;
var
  r: string;
begin
  r := ExtractFileName(path);
  r := r.Replace('.apk', '', [rfIgnoreCase, rfReplaceAll]);
  Result := r;
end;

procedure TCommandThread.commandComplete(Sender: TObject);
begin
  if Assigned(FOnCommandComplete) then begin
    case FCmdType of
    ctDecompile: FOnCommandComplete(Self, FCmdType, [FTmpProjectPath]);
    ctCompile: FOnCommandComplete(Self, FCmdType, [FTmpDistPath]);
    ctInstallFramework: FOnCommandComplete(Self, FCmdType, []);
    ctVersion: FOnCommandComplete(Self, FCmdType, [FTmpVersion]);
    ctJadx: FOnCommandComplete(Self, FCmdType, [FTmpJadxVersion]);
    ctJadxDecompile: FOnCommandComplete(Self, FCmdType, []);
    ctCommand: FOnCommandComplete(Self, FCmdType, []);
    end;
  end;
end;

procedure TCommandThread.SendSync;
begin
  FOnCommandOutput(Self, FCmdType, FTmpOutput);
end;

procedure TCommandThread.Execute;
const
  BUF_SIZE = 2048;
var
  AProcess: TProcess;
  bytesRead: Integer;
  buffer: array[0..BUF_SIZE - 1] of byte;
  i: Integer;
  outputPath: string;
  lineCount: Integer = 0;
begin
  AProcess := TProcess.Create(nil);
  case FCmdType of
  ctDecompile:
    begin
      AProcess.Executable:= GlobalConfig.JavaBinaryPath;
      AProcess.Parameters.Add('-jar');
      AProcess.Parameters.Add(ExtractFilePath(ParamStr(0)) + 'bin' + SPLIT + 'apktool.jar');
      AProcess.Parameters.Add('d');
      if (FParam[2] = '1') then AProcess.Parameters.Add('-r');
      if (FParam[3] = '1') then AProcess.Parameters.Add('-s');
      AProcess.Parameters.Add('-o');
      outputPath:= FParam[1];
      if (not outputPath.EndsWith(SPLIT)) then outputPath += SPLIT;
      outputPath += ExtractPureFileName(FParam[0]) + SPLIT;
      FTmpProjectPath := outputPath + 'apktool.yml';
      AProcess.Parameters.Add(outputPath);
      AProcess.Parameters.Add(FParam[0]);
    end;
  ctCompile:
    begin
      // compile
      AProcess.Executable:= GlobalConfig.JavaBinaryPath;
      AProcess.Parameters.Add('-jar');
      AProcess.Parameters.Add(ExtractFilePath(ParamStr(0)) + 'bin' + SPLIT + 'apktool.jar');
      AProcess.Parameters.Add('b');
      AProcess.Parameters.Add(FParam[0]);
      FTmpDistPath:= FParam[0];
      if (not FTmpDistPath.EndsWith(SPLIT)) then FTmpDistPath += SPLIT;
      FTmpDistPath += 'dist' + SPLIT;
    end;
  ctInstallFramework:
    begin
      AProcess.Executable:= GlobalConfig.JavaBinaryPath;
      AProcess.Parameters.Add('-jar');
      AProcess.Parameters.Add(ExtractFilePath(ParamStr(0)) + 'bin' + SPLIT + 'apktool.jar');
      AProcess.Parameters.Add('if');
      AProcess.Parameters.Add(FParam[0]);
    end;
  ctVersion:
    begin
      AProcess.Executable:= GlobalConfig.JavaBinaryPath;
      AProcess.Parameters.Add('-jar');
      AProcess.Parameters.Add(ExtractFilePath(ParamStr(0)) + 'bin' + SPLIT + 'apktool.jar');
      AProcess.Parameters.Add('-version');
    end;
  ctJadx:
    begin
      {$IFNDEF WINDOWS}
      AProcess.Executable:= ExtractFilePath(ParamStr(0)) + 'bin' + SPLIT + 'jadx';
      AProcess.Parameters.Add('-h');
      {$ELSE}
      AProcess.Executable:= 'C:\Windows\System32\cmd.exe';
      AProcess.Parameters.Add('/c "' + ExtractFilePath(ParamStr(0)) + 'bin' + SPLIT + 'jadx.bat -h"');
      {$ENDIF}
    end;
  ctJadxDecompile:
    begin
      {$IFNDEF WINDOWS}
      AProcess.Executable:= ExtractFilePath(ParamStr(0)) + 'bin' + SPLIT + 'jadx';
      // start 8 threads
      AProcess.Parameters.Add('-j');
      AProcess.Parameters.Add('8');
      AProcess.Parameters.Add('--show-bad-code');
      AProcess.Parameters.Add('-r');
      AProcess.Parameters.Add('-d');
      AProcess.Parameters.Add(FParam[1]);
      AProcess.Parameters.Add(FParam[0]);
      {$ELSE}
      // TODO: decompile for windows
      AProcess.Executable:= 'C:\Windows\System32\cmd.exe';
      AProcess.Parameters.Add('/c "' + Format('%sbin%sjadx.bat -j 8 --show-bad-code -r -d %s %s', [ExtractFilePath(ParamStr(0)), SPLIT, FParam[1], FParam[0]]) + '"');
      {$ENDIF}
    end;
  ctSsmaliDecompile:
    begin
      // java -jar ssmali.jar d class.dex -o ./output
      AProcess.Executable:= GlobalConfig.JavaBinaryPath;
      AProcess.Parameters.Add('-jar');
      AProcess.Parameters.Add(ExtractFilePath(ParamStr(0)) + 'bin' + SPLIT + 'ssmali.jar');
      AProcess.Parameters.Add('d');
      AProcess.Parameters.Add(FParam[0]);
      AProcess.Parameters.Add('-o');
      AProcess.Parameters.Add(FParam[1]);
    end;
  ctCommand:
    begin
      // common command
      AProcess.Executable:= FParam[0];
      for i := 1 to Length(FParam) - 1 do AProcess.Parameters.Add(FParam[i]);
    end;
  end;

  AProcess.Options:= [poUsePipes];
  {$IFDEF WINDOWS}
  AProcess.ShowWindow := swoHIDE;
  {$ENDIF}
  AProcess.Execute;

  repeat
    FillChar(buffer, BUF_SIZE, 0);
    try
      bytesRead:= AProcess.Output.Read(buffer, BUF_SIZE);
      FTmpOutput:= string(StringOf(buffer));
    except
      bytesRead:= 0;
    end;
    if (FCmdType = ctVersion) and (lineCount = 0) then FTmpVersion:= FTmpOutput.Trim;
    if (FCmdType = ctJadx) and (FTmpOutput.Contains('version')) then begin
      FTmpJadxVersion:= FTmpOutput.Substring(FTmpOutput.LastIndexOf(' ')).Trim;
    end;
    lineCount += 1;
    if (Assigned(FOnCommandOutput)) then Synchronize(@SendSync);
  until bytesRead = 0;
  AProcess.Free;
end;

constructor TCommandThread.Create(ACmdType: TCommandType; AParam: array of string);
var
  i: Integer;
begin
  inherited Create(True);
  FreeOnTerminate:= True;
  OnTerminate:=@commandComplete;
  FCmdType:= ACmdType;

  // param sequence
  // Decompile:
  //     APKPath, OutputPath, isNoRes, isNoSrc
  //     isNoRes, isNoSrc: 0: decompile all  1: decompile without res/src
  // compile:
  //     ProjectPath
  // installFramework:
  //     <jar> path
  // version
  //     ['']
  // jadx
  //     ['']
  // jadxDecompile
  //     APKPath, OutputPath
  // ssmaliDecompile
  //     APKPath, OutputPath
  // common:
  //     executable, param1, param2, ...

  SetLength(FParam, Length(AParam));
  for i := 0 to Length(AParam) - 1 do FParam[i] := AParam[i];
end;

end.

