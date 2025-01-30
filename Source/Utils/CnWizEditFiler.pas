{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.2                             }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizEditFiler;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��༭���ļ���ȡ�൥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�� GExperts 1.2 Src �� GX_EditReader ��ֲ����
*           ��ԭʼ������ GExperts License �ı���
*
*           EditFilerLoadFileFromStream �� Stream �ı���Ҫ��
*                        D567            D2005~2007               D2009 ������
*           �����ļ�     Ansi            Utf8����ָ���� Ansi��    Utf16
*           IDE �ڴ�     Ansi            Utf8����ָ���� Ansi��    Utf16
*
*           EditFilerSaveFileToStream �õ��� Stream �ı�����Ϊ��
*                        D567            D2005~2007               D2009 ������
*           �����ļ�     Ansi            Utf8���ɽ���� Ansi��    Utf16
*           IDE �ڴ�     Ansi            Utf8���ɽ���� Ansi��    Utf16
*
*           ע����� Utf8 ָ�������� Ansi ʱ���轫 CheckUtf8 ����Ϊ True
*
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.01.29 V1.3
*               �޸� EditFilerLoadFileFromStream ����Ϊ��ʹ��� Save �汾����һ�µ�
*               Ansi��Ansi/Utf8��Utf16�����ļ�����δ����Ӧ��Save �汾����
*           2017.04.29 V1.2
*               ���� Unicode �����¶��ļ�ʱδת��Ϊ Utf16 ������
*           2003.06.17 V1.1
*               �޸��ļ���������д���ܣ�LiuXiao��
*           2003.03.02 V1.0
*               ������Ԫ����ֲ������By �ܾ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Math, ToolsAPI, CnWizConsts
  {$IFDEF BDS}, CnWideStrings {$ENDIF};

type
  TModuleMode = (mmModule, mmFile);

  TCnEditFiler = class(TObject)
  {* ֻ֧�� Module ����ı༭���ļ�����֧�� dfm ֮���}
  private
    FSourceInterfaceAllocated: Boolean;
    FModuleNotifier: IOTAModuleNotifier;
    FEditIntf: IOTASourceEditor;
    FEditRead: IOTAEditReader;
    FEditWrite: IOTAEditWriter;
    FModIntf: IOTAModule;
    FNotifierIndex: Integer;
    FBuf: Pointer;
    FBufSize: Integer;
    FFileName: string;
    FMode: TModuleMode;
    FStreamFile: TStream;
    procedure AllocateFileData;
    function GetLineCount: Integer;
    procedure SetBufSize(New: Integer);
    procedure InternalGotoLine(Line: Integer; Offset: Boolean);
    function GetFileSize: Integer;
  protected
    procedure SetFileName(const Value: string);
    procedure ReleaseModuleNotifier;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure FreeFileData;
    procedure Reset;
    procedure GotoLine(L: Integer);
    procedure GotoOffsetLine(L: Integer);
    procedure ShowSource;
    procedure ShowForm;
{$IFDEF UNICODE}
    procedure SaveToStreamW(Stream: TStream);
    // ���ļ����ݴ������У������ TMemoryStream�����û BOM �� UTF16 ��ʽ������ Utf8 ��ʽ��β�� #0
{$ENDIF}
    procedure SaveToStream(Stream: TStream; CheckUtf8: Boolean = False);
    // ������Ϊ�� BOM �� Ansi �� Utf8 ��ʽ��β�� #0��
    // BDS ����ļ��� IDE ��򿪡��� CheckUtf8 �� True ������ MemoryStream ʱ��
    // Utf8 ��ת���� Ansi�����򱣳� Utf8��D5/6/7 ��ֻ֧�� Ansi
    procedure SaveToStreamFromPos(Stream: TStream);
    procedure SaveToStreamToPos(Stream: TStream);

{$IFDEF UNICODE}
    procedure ReadFromStreamW(Stream: TStream);
    // �� Stream ����д���ļ��򻺳��У�����ԭ�����ݡ�Ҫ�������� UTF16���� BOM
    // �ļ��Ǵ�����ʽʱ���ܹ��� UTF16 ����ת��Ϊ�ļ���Ӧ����
{$ENDIF}
    // LiuXiao �������������������
    procedure ReadFromStream(Stream: TStream; CheckUtf8: Boolean = False);
    // �� Stream ����д���ļ��򻺳��У�����ԭ�����ݣ��� Stream �� Position �͹��λ���޹أ�
    // Ҫ�������� Ansi �� Utf8���� BOM����Ҫ�� Stream β #0��׼ȷ���������� #0 �������ֶ����ַ���
    // д�ļ�ʱ Stream ���ݲ�����ת����д����ʱ����� BDS �� Stream �� MemoryStream ʱ��
    // Stream ��������� Ansi���� CheckUtf8 ����Ϊ True �Խ��� Ansi �� Utf8 ��ת�����ʺϱ༭�����塣
    // ע�⣺�ļ��Ǵ�����ʽʱ��Ŀǰֻ��ԭ�ⲻ��д���ļ����޷�ת������

    // TODO: ������������δ�� UTF8 ����
    procedure ReadFromStreamInPos(Stream: TStream);
    procedure ReadFromStreamInsertToPos(Stream: TStream);

    function GetCurrentBufferPos: Integer;
    property BufSize: Integer read FBufSize write SetBufSize;
    property FileName: string read FFileName write SetFileName;
    property LineCount: Integer read GetLineCount;
    property Mode: TModuleMode read FMode;
    property FileSize: Integer read GetFileSize;
  end;

procedure EditFilerLoadFileFromStream(const FileName: string; Stream: TStream; CheckUtf8: Boolean = False);
{* ��װ������д�� Filer ���ļ����ݣ�Ҫ�������� BOM��β������ #0��
  �ڲ�д�ļ�ʱ������ת����д����ʱ����� BDS 2005 �� 2007 ���� Stream �� MemoryStream��
  ����� CheckUtf8 ��Ϊ True ������ Ansi �� Utf8 ��ת�����ʺϱ༭�����壬D5/6/7 �в���ת����
  Unicode �����»���� CheckUtf8��Stream �б���̶�Ϊ Utf16��Ҳ���� Ansi��Ansi/Utf8��Utf16}

procedure EditFilerSaveFileToStream(const FileName: string; Stream: TStream; CheckUtf8: Boolean = False);
{* ��װ���� Filer �����ļ��������������о�Ϊ�� BOM ��ԭʼ��ʽ��Ansi��Ansi/Utf8��Utf16����β�� #0��
  ע�⣺BDS 2005 �� 2007 ����ļ��������� IDE �ڴ�ʱ�ڲ�һ���� UTF8 ��ʽ��
  �罫 CheckUtf8 ��Ϊ True ������ MemoryStream ʱ���ú����Ὣ Utf8 ��ת���� Ansi�����򱣳� Utf8
  �� Unicode �������ļ��������Դ���ʱ����� CheckUtf8��Stream �й̶�Ϊ Utf16��
  ���ļ��������Դ��̣��򱣳��ļ����룬��һ���� Ansi ���� Utf8 ���� Utf 16��
  D5/6/7 ��ֻ֧�� Ansi��������ֱ��  PChar(Stream.Memory) ʹ��}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizUtils;

procedure EditFilerLoadFileFromStream(const FileName: string; Stream: TStream; CheckUtf8: Boolean);
begin
  with TCnEditFiler.Create(FileName) do
  try
{$IFDEF UNICODE}
    ReadFromStreamW(Stream);
{$ELSE}
    ReadFromStream(Stream, CheckUtf8);
{$ENDIF}
  finally
    Free;
  end;
end;

procedure EditFilerSaveFileToStream(const FileName: string; Stream: TStream; CheckUtf8: Boolean);
begin
  with TCnEditFiler.Create(FileName) do
  try
{$IFDEF UNICODE}
    SaveToStreamW(Stream);
{$ELSE}
    SaveToStream(Stream, CheckUtf8);
{$ENDIF}
  finally
    Free;
  end;
end;

type
  TModuleFreeNotifier = class(TNotifierObject, IOTAModuleNotifier)
  private
    FOwner: TCnEditFiler;
  public
    constructor Create(Owner: TCnEditFiler);
    destructor Destroy; override;
    procedure ModuleRenamed(const NewName: String);
    function CheckOverwrite: Boolean;
  end;

{ TModuleFreeNotifier }

function TModuleFreeNotifier.CheckOverwrite: Boolean;
begin
  Result := True;
end;

constructor TModuleFreeNotifier.Create(Owner: TCnEditFiler);
begin
  inherited Create;

  FOwner := Owner;
end;

destructor TModuleFreeNotifier.Destroy;
begin
  Assert(FOwner <> nil);
  FOwner.FreeFileData;
  FOwner.FModuleNotifier := nil;

  inherited Destroy;
end;

procedure TModuleFreeNotifier.ModuleRenamed(const NewName: String);
begin
  // We might want to handle this and change the stored file name
end;

resourcestring
  SNoEditReader = 'FEditRead: No Editor Reader Interface (You have found a bug!)';
  SNoEditWriter = 'FEditWrite: No Editor Writer Interface (You have found a bug!)';

constructor TCnEditFiler.Create(const FileName: string);
begin
  inherited Create;

  FBufSize := 32760; // Large buffers are faster, but too large causes crashes
  FNotifierIndex := InvalidNotifierIndex;
  FMode := mmModule;
  if FileName <> '' then
    SetFileName(FileName);
end;

// Use the FreeFileData to release the references
// to the internal editor buffer or the external
// file on disk in order not to block the file
// or track the editor (which may disappear) for
// possibly extended periods of time.
//
// Calls to edit reader will always (re-)allocate
// references again by calling the "AllocateFileData"
// method, so calling "FreeFileData" essentially comes
// for free, only reducing the length a reference
// is held to an entity.
procedure TCnEditFiler.FreeFileData;
begin
  FreeAndNil(FStreamFile);
  FEditRead := nil;
  FEditWrite := nil;
  FEditIntf := nil;

  ReleaseModuleNotifier;
  FModIntf := nil;

  FSourceInterfaceAllocated := False;
end;

destructor TCnEditFiler.Destroy;
begin
  FreeFileData;

  if FBuf <> nil then
    FreeMem(FBuf);
  FBuf := nil;
  FEditRead := nil;
  FEditWrite := nil;

  inherited Destroy;
end;

procedure TCnEditFiler.AllocateFileData;

  procedure AllocateFromDisk;
  begin
    if not FileExists(FFileName) then
      raise Exception.CreateFmt(SCnFileDoesNotExist, [FFileName]);

    FMode := mmFile;
    try
      FStreamFile := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
    except
      FStreamFile := TFileStream.Create(FFileName, fmOpenRead);
    end;
  end;

begin
  if FSourceInterfaceAllocated then
    Exit;

  if BorlandIDEServices = nil then
  begin
    AllocateFromDisk;
    Exit;
  end;

  // Get module interface
  Assert(FModIntf = nil);
  FModIntf := CnOtaGetModule(FFileName);
  if FModIntf = nil  then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditReader: Module not open in the IDE - opening from disk');
{$ENDIF}
    AllocateFromDisk;
  end
  else if CnOtaGetSourceEditorFromModule(FModIntf, FileName) = nil then
  begin
    // ������ View as Text ʱ���޷��õ�Դ��� SourceEditor �ӿ�
    AllocateFromDisk;
  end
  else
  begin
    FMode := mmModule;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditReader: Got module for ' + FFileName);
{$ENDIF}

    // Allocate notifier for module
    Assert(FModuleNotifier = nil);
    FModuleNotifier := TModuleFreeNotifier.Create(Self);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditReader: Got FModuleNotifier');
{$ENDIF}
    if FModuleNotifier = nil then
    begin
      FModIntf := nil;

      raise Exception.CreateFmt(SCnNoModuleNotifier, [FFileName]);
    end;
    FNotifierIndex := FModIntf.AddNotifier(FModuleNotifier);

    // Get Editor Interface
    Assert(FEditIntf = nil);

    FEditIntf := CnOtaGetSourceEditorFromModule(FModIntf, FFileName);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditReader: Got FEditIntf for module');
{$ENDIF}
    if FEditIntf = nil then
    begin
      ReleaseModuleNotifier;
      FModIntf := nil;

      // Should we do this instead?
      //FreeFileData;

      // Sometimes causes "Instance of TEditClass has a dangling reference count of 3"
      // Happens in BCB5 when trying to focus a .h when the .dfm is being vewed as text
      // Maybe fixed in 1.0?
      raise Exception.CreateFmt(SCnNoEditorInterface, [FFileName]);
    end;

    // Get Reader interface }
    Assert((FEditRead = nil) and (FEditWrite = nil));
    FEditRead := FEditIntf.CreateReader;
    FEditWrite := FEditIntf.CreateUndoableWriter;
    if (FEditRead = nil) or (FEditWrite = nil) then
    begin
      ReleaseModuleNotifier;
      FModIntf := nil;
      FEditIntf := nil;
      if FEditRead = nil then
        raise Exception.Create(SNoEditReader);
      if FEditWrite = nil then
        raise Exception.Create(SNoEditWriter);
    end;
  end;

  FSourceInterfaceAllocated := True;
end;

procedure TCnEditFiler.SetFileName(const Value: string);
begin
  if SameText(Value, FFileName) then
    Exit;

  FreeFileData;

  // Assigning an empty string clears allocation.
  if Value = '' then
    Exit;

  FFileName := Value;
  Reset;
end;

procedure TCnEditFiler.SetBufSize(New: Integer);
begin
  if (FBuf = nil) and (New <> FBufSize) then
    FBufSize := New;
  // 32K is the max we can read from an edit reader at once
  Assert(FBufSize <= 1024 * 32);
end;

procedure TCnEditFiler.ShowSource;
begin
  AllocateFileData;

  Assert(Assigned(FEditIntf));

  if FMode = mmModule then
    FEditIntf.Show;
end;

procedure TCnEditFiler.ShowForm;
begin
  AllocateFileData;
  Assert(Assigned(FModIntf));

  if FMode = mmModule then
    CnOtaShowFormForModule(FModIntf);
end;

procedure TCnEditFiler.GotoLine(L: Integer);
begin
  InternalGotoLine(L, False);
end;

procedure TCnEditFiler.GotoOffsetLine(L: Integer);
begin
  InternalGotoLine(L, True);
end;

procedure TCnEditFiler.InternalGotoLine(Line: Integer; Offset: Boolean);
var
  EditView: IOTAEditView;
  EditPos: TOTAEditPos;
  S: Integer;
  ViewCount: Integer;
begin
  AllocateFileData;

  //{$IFDEF Debug} CnDebugger.LogMsg('LineCount ' + IntToStr(LineCount)); {$ENDIF}
  if Line > LineCount then Exit;
  if Line < 1 then
    Line := 1;

  Assert(FModIntf <> nil);
  ShowSource;

  Assert(FEditIntf <> nil);
  ViewCount := FEditIntf.EditViewCount;
  if ViewCount < 1 then
    Exit;

  EditView := FEditIntf.EditViews[0];
  if EditView <> nil then
  begin
    EditPos.Col := 1;
    EditPos.Line := Line;
    if Offset then
    begin
      EditView.CursorPos := EditPos;
      S := Line - (EditView.ViewSize.cy div 2);
      if S < 1 then S := 1;
      EditPos.Line := S;
      EditView.TopPos := EditPos;
    end
    else
    begin
      EditView.TopPos := EditPos;
      EditView.CursorPos := EditPos;
      ShowSource;
    end;
    EditView.Paint;
  end;
end;

function TCnEditFiler.GetLineCount: Integer;
begin
  if FMode = mmModule then
  begin
    AllocateFileData;
    Assert(FEditIntf <> nil);

    Result := FEditIntf.GetLinesInBuffer;
  end
  else
    Result := -1;
end;

procedure TCnEditFiler.Reset;
begin
  if FMode = mmFile then
  begin
    // We do not need to allocate file data
    // in order to set the stream position
    if FStreamFile <> nil then
      FStreamFile.Position := 0;
  end;
end;

procedure TCnEditFiler.SaveToStream(Stream: TStream; CheckUtf8: Boolean);
var
  Pos: Integer;
  Size: Integer;
{$IFDEF IDE_WIDECONTROL}
  Text: AnsiString;
{$IFDEF UNICOEE}
  List: TCnWideStringList;
  Utf16Text: string;
{$ELSE}
  List: TStringList;
  Utf16Text: WideString;
{$ENDIF}
{$ENDIF}
const
  TheEnd: AnsiChar = AnsiChar(#0); // Leave typed constant as is - needed for streaming code
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    // ע��˴����ݵı������ļ�����
{$IFDEF IDE_STRING_ANSI_UTF8}
    // D2005~2007 �£��� TCnWideStringList ����ļ����ݱ��벢����Ϊ UTF16
    List := TCnWideStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile);
      Utf16Text := List.Text;

      if CheckUtf8 then
        Text := AnsiString(Utf16Text)                // �ٸ��ݲ����� Utf16 תΪ Utf8
      else
        Text := CnUtf8EncodeWideString(Utf16Text);   // ��ֱ��תΪ AnsiString

      Stream.Write(Text[1], Length(Text) * SizeOf(AnsiChar));
      Stream.Write(TheEnd, 1);
    finally
      List.Free;
    end;
{$ELSE}
  {$IFDEF UNICODE}
    // D2009 �����ϣ���ϵͳ�Դ� TStringList ����ļ����ݱ��벢����Ϊ UTF16
    List := TStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile);
      Utf16Text := List.Text;

      if CheckUtf8 then
        Text := AnsiString(Utf16Text)                // �ٸ��ݲ����� Utf16 תΪ Utf8
      else
        Text := CnUtf8EncodeWideString(Utf16Text);   // ��ֱ��תΪ AnsiString

      Stream.Write(Text[1], Length(Text) * SizeOf(AnsiChar));
      Stream.Write(TheEnd, 1);
    finally
      List.Free;
    end
  {$ELSE}
    // D567��ֻ֧�� Ansi��������⴦��
    FStreamFile.Position := 0;
    Stream.CopyFrom(FStreamFile, FStreamFile.Size);
    Stream.Write(TheEnd, 1);
  {$ENDIF}
{$ENDIF}
  end
  else
  begin
    Pos := 0;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);
    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);
    // Delphi 5+ sometimes returns -1 here, for an unknown reason
    Size := FEditRead.GetText(Pos, FBuf, BufSize);
    if Size = -1 then
    begin
      FreeFileData;
      AllocateFileData;
      Size := FEditRead.GetText(Pos, FBuf, BufSize);
    end;
    if Size > 0 then
    begin
      Pos := Pos + Size;
      while Size = BufSize do
      begin
        Stream.Write(FBuf^, Size);
        Size := FEditRead.GetText(Pos, FBuf, BufSize);
        Pos := Pos + Size;
      end;
      Stream.Write(FBuf^, Size);
    end;
    Stream.Write(TheEnd, 1);

{$IFDEF IDE_WIDECONTROL}
    if CheckUtf8 and (Stream is TMemoryStream) then
    begin
      Text := CnUtf8ToAnsi(PAnsiChar((Stream as TMemoryStream).Memory));
      Stream.Size := Length(Text) + 1;
      Stream.Position := 0;
      Stream.Write(PAnsiChar(Text)^, Length(Text) + 1);
    end;
{$ENDIF}
  end;
end;

{$IFDEF UNICODE}

procedure TCnEditFiler.SaveToStreamW(Stream: TStream);
var
  Pos: Integer;
  Size: Integer;
  Text: string;
  List: TStringList;
const
  TheEnd: AnsiChar = AnsiChar(#0); // Leave typed constant as is - needed for streaming code
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    // Unicode �����£�Ҫ�����ļ��� BOM ת���� UTF16������ֱ�Ӹ����ļ���
    List := TStringList.Create;
    try
      List.LoadFromStream(FStreamFile); // �ڲ�������ļ� BOM ��¼����룬Ȼ��ת���� UTF16
      Text := List.Text;
      Stream.Write(Text[1], Length(Text) * SizeOf(Char));
      Stream.Write(TheEnd, 1);  // Write UTF16 #$0000
      Stream.Write(TheEnd, 1);
    finally
      List.Free;
    end;
  end
  else
  begin
    Pos := 0;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);
    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);

    // Delphi 5+ sometimes returns -1 here, for an unknown reason
    Size := FEditRead.GetText(Pos, FBuf, BufSize);
    if Size = -1 then
    begin
      FreeFileData;
      AllocateFileData;
      Size := FEditRead.GetText(Pos, FBuf, BufSize);
    end;
    if Size > 0 then
    begin
      Pos := Pos + Size;
      while Size = BufSize do
      begin
        Stream.Write(FBuf^, Size);
        Size := FEditRead.GetText(Pos, FBuf, BufSize);
        Pos := Pos + Size;
      end;
      Stream.Write(FBuf^, Size);
    end;
    Stream.Write(TheEnd, 1);  // Write UTF16 #$0000
    Stream.Write(TheEnd, 1);

    if Stream is TMemoryStream then
    begin
      Text := Utf8Decode(PAnsiChar((Stream as TMemoryStream).Memory));
      Stream.Size := (Length(Text) + 1) * SizeOf(Char);
      Stream.Position := 0;
      Stream.Write(PChar(Text)^, (Length(Text) + 1) * SizeOf(Char));
    end;
  end;
end;

{$ENDIF}

function TCnEditFiler.GetCurrentBufferPos: Integer;
var
  EditorPos: TOTAEditPos;
  CharPos: TOTACharPos;
  EditView: IOTAEditView;
begin
  AllocateFileData;

  Assert(FEditIntf <> nil);

  Result := -1;
  Assert(FEditIntf.EditViewCount > 0);

  EditView := FEditIntf.EditViews[0];
  if EditView <> nil then
  begin
    EditorPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditorPos, CharPos);
    Result := EditView.CharPosToPos(CharPos);
  end;
end;

procedure TCnEditFiler.SaveToStreamFromPos(Stream: TStream);
var
  Pos: Integer;
  Size: Integer;
begin
  AllocateFileData;

  Reset;

  if Mode = mmFile then
  begin
    // TODO: �ļ������ UTF8 ����
    Assert(FStreamFile <> nil);
    FStreamFile.Position := 0;
    Stream.CopyFrom(FStreamFile, FStreamFile.Size);
  end
  else
  begin
    Pos := GetCurrentBufferPos;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);
    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);

    Size := FEditRead.GetText(Pos, FBuf, BufSize);
    if Size > 0 then
    begin
      Pos := Pos + Size;
      while Size = BufSize do
      begin
        Stream.Write(FBuf^, Size);
        Size := FEditRead.GetText(Pos, FBuf, BufSize);
        Pos := Pos + Size;
      end;
      Stream.Write(FBuf^, Size);
    end;
  end;
end;

// The character at the current position is not written to the stream
procedure TCnEditFiler.SaveToStreamToPos(Stream: TStream);
var
  Pos, AfterPos: Integer;
  ToReadSize, Size: Integer;
  NullChar: char;
begin
  AllocateFileData;

  Reset;

  if Mode = mmFile then
  begin
    // TODO: �ļ������ UTF8 ����
    Assert(FStreamFile <> nil);
    FStreamFile.Position := 0;
    Stream.CopyFrom(FStreamFile, FStreamFile.Size);
  end
  else
  begin
    AfterPos := GetCurrentBufferPos;
    Pos := 0;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);
    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);

    ToReadSize := Min(BufSize, AfterPos - Pos);
    Size := FEditRead.GetText(Pos, FBuf, ToReadSize);
    if Size > 0 then
    begin
      Pos := Pos + Size;
      while Size = BufSize do
      begin
        Stream.Write(FBuf^, Size);
        ToReadSize := Min(BufSize, AfterPos - Pos);
        Size := FEditRead.GetText(Pos, FBuf, ToReadSize);
        Pos := Pos + Size;
      end;
      Stream.Write(FBuf^, Size);
    end;
  end;
  NullChar := #0;
  Stream.Write(NullChar, SizeOf(NullChar));
end;

procedure TCnEditFiler.ReleaseModuleNotifier;
begin
  if FNotifierIndex <> InvalidNotifierIndex then
    FModIntf.RemoveNotifier(FNotifierIndex);
  FNotifierIndex := InvalidNotifierIndex;
  FModuleNotifier := nil;
end;

{$IFDEF UNICODE}

procedure TCnEditFiler.ReadFromStreamW(Stream: TStream);
var
  Size: Integer;
  Utf8Text: AnsiString;
  List: TStringList;
  Utf16Text: string;
  Utf8Stream: TMemoryStream;
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    if Stream is TMemoryStream then
    begin
      // Unicode �����£�Ҫ�����ļ��� BOM ת�� UTF16 �� Stream ���ݣ�����ֱ�Ӹ����ļ���
      List := TStringList.Create;
      try
        FStreamFile.Position := 0;
        List.LoadFromStream(FStreamFile); // List ������ Utf16������¼���ļ�����

        // �� Stream �� Utf16 �������� Utf16Text �ٸ� List
        SetLength(Utf16Text, Stream.Size div 2);
        Stream.Position := 0;
        Move((Stream as TMemoryStream).Memory^, Utf16Text[1], Length(Utf16Text) * SizeOf(WideChar));
        List.Text := Utf16Text;

        FStreamFile.Size := 0;
        List.SaveToStream(FStreamFile); // List ����ʱ����֮ǰ��¼���ļ�����ת���󱣴�
      finally
        List.Free;
      end;
    end;
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.DeleteTo(MaxInt);

    Utf8Stream := nil;
    try
      if Stream is TMemoryStream then // �ⲿ����� UTF16 ��ʽ����������Ҫת�� Utf8
      begin
        SetLength(Utf16Text, Stream.Size div 2);
        Stream.Position := 0;
        Move((Stream as TMemoryStream).Memory^, Utf16Text[1], Length(Utf16Text) * SizeOf(WideChar));
        Utf8Text := CnUtf8EncodeWideString(Utf16Text);

        Utf8Stream := TMemoryStream.Create;
        Utf8Stream.Size := Length(Utf8Text);
        Utf8Stream.Position := 0;
        Utf8Stream.Write(PAnsiChar(Utf8Text)^, Length(Utf8Text));
      end;

      if FBuf = nil then
        GetMem(FBuf, BufSize + 1);

      if Utf8Stream <> nil then
      begin
        if Utf8Stream.Size > 0 then
        begin
          Utf8Stream.Position := 0;
          repeat
            FillChar(FBuf^, BufSize + 1, 0);
            Size := Utf8Stream.Read(FBuf^, BufSize);
            FEditWrite.Insert(FBuf);
          until Size <> BufSize;
        end
      end
      else // ûת UTF8
      begin
        if Stream.Size > 0 then
        begin
          Stream.Position := 0;
          repeat
            FillChar(FBuf^, BufSize + 1, 0);
            Size := Stream.Read(FBuf^, BufSize);
            FEditWrite.Insert(FBuf);
          until Size <> BufSize;
        end;
      end;
    finally
      Utf8Stream.Free;
    end;
  end;
end;

{$ENDIF}

// �� Stream ����д���ļ��򻺳��У�����ԭ�����ݣ��� Stream �� Position �͹��λ���޹ء�
procedure TCnEditFiler.ReadFromStream(Stream: TStream; CheckUtf8: Boolean);
var
  Size: Integer;
{$IFDEF IDE_WIDECONTROL}
  AnsiText: AnsiString;
  Utf8Text: AnsiString;
  Utf16Text: WideString;
{$IFDEF UNICODE}
  List: TStringList;
{$ELSE}
  List: TCnWideStringList;
{$ENDIF}
{$ENDIF}
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

{$IFDEF IDE_WIDECONTROL}
    if CheckUtf8 and (Stream is TMemoryStream) then
    begin
      SetLength(AnsiText, Stream.Size);
      Move((Stream as TMemoryStream).Memory^, AnsiText[1], Stream.Size);
      Utf8Text := CnAnsiToUtf8(AnsiText);
    end
    else
    begin
      SetLength(Utf8Text, Stream.Size);
      Move((Stream as TMemoryStream).Memory^, Utf8Text[1], Stream.Size);
    end;

    // ��ʱ Utf8Text ���� Utf8 ���ݣ�Ҫת UTF16 �Էŵ� StringList ��
    Utf16Text := CnUtf8DecodeToWideString(Utf8Text);
  {$IFDEF UNICODE}
    // Unicode �����£�Ҫ�� StringList ��ֵ�������ڲ������ļ��� BOM��ת�� UTF16 ������д���ļ�
    List := TStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile); // List ������ Utf16������¼���ļ�����

      List.Text := Utf16Text;

      FStreamFile.Size := 0;
      List.SaveToStream(FStreamFile); // List ����ʱ����֮ǰ��¼���ļ�����ת���󱣴�
    finally
      List.Free;
    end;
  {$ELSE}
    // D2005~2007 �£�Ҫ�� CnWideStringList ��ֵ����������ļ��� BOM��ת�� UTF16 ������д���ļ�
    List := TCnWideStringList.Create;
    try
      FStreamFile.Position := 0;
      List.LoadFromStream(FStreamFile); // List ������ Utf16������¼���ļ�����

      List.Text := Utf16Text;

      FStreamFile.Size := 0;
      List.SaveToStream(FStreamFile, List.LoadFormat); // List ����ʱ����֮ǰ��¼���ļ�����ת���󱣴�
    finally
      List.Free;
    end;
  {$ENDIF}
{$ELSE}
    Stream.Position := 0;
    FStreamFile.Size := 0;
    FStreamFile.CopyFrom(Stream, Stream.Size);
{$ENDIF}
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.DeleteTo(MaxInt);

{$IFDEF IDE_WIDECONTROL}
    if CheckUtf8 and (Stream is TMemoryStream) then // Stream ������ Ansi��BDS ���ϵ�ת Utf8������β�� #0
    begin
      Utf8Text := CnAnsiToUtf8(PAnsiChar((Stream as TMemoryStream).Memory));
      Stream.Size := Length(Utf8Text);
      Stream.Position := 0;
      Stream.Write(PAnsiChar(Utf8Text)^, Length(Utf8Text));
    end;
{$ENDIF}

    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);

    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      repeat
        FillChar(FBuf^, BufSize + 1, 0);
        Size := Stream.Read(FBuf^, BufSize);
        FEditWrite.Insert(FBuf);
      until Size <> BufSize;
    end;
  end;
end;

// �������ݸ��ǵ�ǰλ�õ��ı�
procedure TCnEditFiler.ReadFromStreamInPos(Stream: TStream);
var
  Size: Integer;
  CurrPos: Integer;
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    Stream.Position := 0;
    FStreamFile.Size := 0;
    FStreamFile.CopyFrom(Stream, Stream.Size);
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    CurrPos := CnOtaGetCurrLinearPos;
    FEditWrite.CopyTo(CurrPos);

    FEditWrite.DeleteTo(CurrPos + Stream.Size);
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);

    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      repeat
        FillChar(FBuf^, BufSize + 1, 0);
        Size := Stream.Read(FBuf^, BufSize);
        FEditWrite.Insert(FBuf);
      until Size <> BufSize;
    end;
  end;
end;

// �����ݲ��뵱ǰ�ı��ĵ�ǰλ�á�
procedure TCnEditFiler.ReadFromStreamInsertToPos(Stream: TStream);
var
  Size: Integer;
begin
  Assert(Stream <> nil);

  Reset;

  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);

    Stream.Position := 0;
    FStreamFile.Size := 0;
    FStreamFile.CopyFrom(Stream, Stream.Size);
  end
  else
  begin
    if FEditWrite = nil then
      raise Exception.Create(SNoEditWriter);

    FEditWrite.CopyTo(CnOtaGetCurrLinearPos);
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);

    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      repeat
        FillChar(FBuf^, BufSize + 1, 0);
        Size := Stream.Read(FBuf^, BufSize);
        FEditWrite.Insert(FBuf);
      until Size <> BufSize;
    end;
  end;
end;

function TCnEditFiler.GetFileSize: Integer;
var
  Size: Integer;
begin
  Reset;
  AllocateFileData;

  if Mode = mmFile then
  begin
    Assert(FStreamFile <> nil);
    Result := FStreamFile.Size;
  end
  else
  begin
    Result := 0;
    if FBuf = nil then
      GetMem(FBuf, BufSize + 1);

    if FEditRead = nil then
      raise Exception.Create(SNoEditReader);
    // Delphi 5+ sometimes returns -1 here, for an unknown reason
    Size := FEditRead.GetText(Result, FBuf, BufSize);
    if Size = -1 then
    begin
      FreeFileData;
      AllocateFileData;
      Size := FEditRead.GetText(Result, FBuf, BufSize);
    end;

    if Size > 0 then
    begin
      Inc(Result, Size);
      while Size = BufSize do
      begin
        Size := FEditRead.GetText(Result, FBuf, BufSize);
        Inc(Result, Size);
      end;
    end;
  end;
end;

end.

