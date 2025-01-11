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

unit CnObjInspectorCommentFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����鿴��������ע���嵥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7/10/11 + Delphi / C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.01.08 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,ToolWin, ComCtrls, ActnList, Menus, Buttons, Clipbrd,
  Contnrs, CnWizIdeDock, CnWizShareImages, CnWizOptions, CnWizConsts,
  CnObjectInspectorWrapper, CnHashMap, Grids;

type
  TCnPropertyCommentType = class;

  TCnPropertyCommentItem = class(TPersistent)
  {* ���������¼�}
  private
    FComment: string;
    FPropertyName: string;
    FOwnerType: TCnPropertyCommentType;
    FPropertyComment: string;
  public
    constructor Create(AOwnerType: TCnPropertyCommentType); virtual;
    destructor Destroy; override;

    property OwnerType: TCnPropertyCommentType read FOwnerType;
    {* ��������}
    property PropertyName: string read FPropertyName write FPropertyName;
    {* ���Ի��¼���}
    property PropertyComment: string read FPropertyComment write FPropertyComment;
    {* ���Ի��¼�ע��}
    property Comment: string read FComment write FComment;
    {* ����һ��ע�ͣ��������}
  end;

  TCnPropertyCommentType = class(TObjectList)
  {* һ�����ͳ������������¼���}
  private
    FChanged: Boolean;
    FTypeName: string;
    FComment: string;
    function GetItem(Index: Integer): TCnPropertyCommentItem;
    procedure SetItem(Index: Integer; const Value: TCnPropertyCommentItem);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function Add(const PropertyName: string): TCnPropertyCommentItem;
    {* ���һ�������¼�}
    procedure Remove(const PropertyName: string);
    {* ɾ��һ�������¼�}

    function IndexOfProperty(const PropertyName: string): Integer;
    {* ���������¼������������¼�����}
    function GetProperty(const PropertyName: string): TCnPropertyCommentItem;
    {* ���ٲ���ָ������}

    procedure Load;
    {* ָ�� TypeName ���ר�Ұ��û������м���}
    procedure LoadFromFile(const FileName: string);
    {* �ӵ����ļ��������ض������������}

    procedure Save;
    {* ָ�� TypeName ��洢��ר�Ұ��û�������}
    procedure SaveToFile(const FileName: string);
    {* ���ض�����������ݴ��뵥���ļ�}
    procedure NotifyChanged;
    {* ֪ͨ�ı�}

    property TypeName: string read FTypeName write FTypeName;
    {* ����}
    property Comment: string read FComment write FComment;
    {* �����������ע��}

    property Items[Index: Integer]: TCnPropertyCommentItem read GetItem write SetItem; default;
    {* ��������Ժ��¼���Ŀ}

    property Changed: Boolean read FChanged write FChanged;
    {* �� Item ֪ͨ�ĸı�}
  end;

  TCnPropertyCommentManager = class
  {* �����鿴�����ʹ�õı�ע�����������ж������}
  private
    FList: TObjectList;            // ���в������� TCnPropertyCommentType
    FHashMap: TCnStrToPtrHashMap;  // ���� TypeName ���������� Map��ֻ���ã����������
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function AddType(const TypeName: string): TCnPropertyCommentType;
    {* ���һ��ָ�����ͣ��ڲ�Ҫ����}
    procedure RemoveType(const TypeName: string);
    {* ɾ��ָ������}

    function IndexOfType(const TypeName: string): Integer;
    {* ����ָ��������}
    function GetType(const TypeName: string): TCnPropertyCommentType;
    {* ���ٲ���ָ����}

    procedure LoadFromDirectory(const DirName: string);
    {* ��Ŀ¼����}
    procedure SaveToDirectory(const DirName: string);
    {* ������Ŀ¼}
  end;

  TCnObjInspectorCommentForm = class(TCnIdeDockForm)
    pnlComment: TPanel;
    tlbObjComment: TToolBar;
    btnHelp: TToolButton;
    btn1: TToolButton;
    btnClear: TToolButton;
    btnFont: TToolButton;
    dlgFont: TFontDialog;
    btn2: TToolButton;
    mmoComment: TMemo;
    pnlType: TPanel;
    edtType: TEdit;
    edtTypeComment: TEdit;
    pnlProp: TPanel;
    edtProp: TEdit;
    edtPropComment: TEdit;
    actlstComment: TActionList;
    actClear: TAction;
    actFont: TAction;
    actHelp: TAction;
    procedure actHelpExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FManager: TCnPropertyCommentManager;
    FCurrentType: TCnPropertyCommentType;
    FCurrentProp: TCnPropertyCommentItem;
    procedure UpdateCaption;
    procedure InspectorSelectionChange(Sender: TObject);
    function MemToUIStr(const Str: string): string;
    function UIToMemStr(const Str: string): string;
  protected
    function GetHelpTopic: string; override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    procedure ShowCurrent;
    procedure SaveCurrentPropToManager;
  end;

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csCommentDir = 'OIComment';
  csRepCRLF = '\n';
  csCRLF = #13#10;

procedure TCnObjInspectorCommentForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnObjInspectorCommentForm.GetHelpTopic: string;
begin
  Result := 'CnObjInspectorEnhanceWizard';
end;

procedure TCnObjInspectorCommentForm.UpdateCaption;
const
  SEP = ' - ';
var
  S: string;
  I: Integer;
begin

end;

procedure TCnObjInspectorCommentForm.DoLanguageChanged(Sender: TObject);
begin
  UpdateCaption;
end;

procedure TCnObjInspectorCommentForm.actFontExecute(Sender: TObject);
begin
  if dlgFont.Execute then
  begin
    mmoComment.Font := dlgFont.Font;
    edtType.Font := dlgFont.Font;
    edtTypeComment.Font := dlgFont.Font;
    edtProp.Font := dlgFont.Font;
    edtPropComment.Font := dlgFont.Font;
  end;
end;

procedure TCnObjInspectorCommentForm.FormCreate(Sender: TObject);
begin
  FManager := TCnPropertyCommentManager.Create;
  ObjectInspectorWrapper.AddSelectionChangeNotifier(InspectorSelectionChange);
end;

procedure TCnObjInspectorCommentForm.FormDestroy(Sender: TObject);
begin
  FManager.Free;
  ObjectInspectorWrapper.RemoveSelectionChangeNotifier(InspectorSelectionChange);
end;

procedure TCnObjInspectorCommentForm.InspectorSelectionChange(Sender: TObject);
var
  AName: string;
begin
  // �õ���ǰ���͵�ǰ���Ի��¼�
  AName := ObjectInspectorWrapper.ActiveComponentType;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('InspectorSelectionChange: ActiveComponentType %s', [AName]);
{$ENDIF}
  if (FCurrentType = nil) or (FCurrentType.TypeName <> AName) then
  begin
    // ��ǰ���࣬����ѡ�еĲ��ǵ�ǰ��
    if FCurrentType <> nil then // ��ǰ�������ȱ������
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('InspectorSelectionChange: Old Type %s', [FCurrentType.TypeName]);
{$ENDIF}
      if FCurrentProp <> nil then
      begin
        // ��ǰ�������¼����ѽ�������д�� FCurrentProp ��
{$IFDEF DEBUG}
        CnDebugger.LogFmt('InspectorSelectionChange: Old Prop %s', [FCurrentProp.PropertyName]);
{$ENDIF}
        SaveCurrentPropToManager;
      end;
      FCurrentType.Save;
    end;
    FCurrentProp := nil;

    // �ڴ����������
    FCurrentType := FManager.GetType(AName);
    if FCurrentType = nil then
    begin
      // �ڴ� HashMap ��û�ҵ��������ڴ��ﴴ��һ��
      FCurrentType := FManager.AddType(AName);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('InspectorSelectionChange: Create New Type %s', [AName]);
{$ENDIF}
      // �����Լ��ؿ����е����ݣ���ΧΪ��ǰ������������¼�
      FCurrentType.Load;
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('InspectorSelectionChange: Exist New Type %s', [AName]);
{$ENDIF}
    end;

    // �ڴ����õ������ˣ���������Ϣ������
    ShowCurrent;
  end;

  // ��ǰ��û�䣬��������õ������ˣ����� PropertyName �����������¼���Ϣ������
  AName := ObjectInspectorWrapper.ActivePropName;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('InspectorSelectionChange: ActivePropName %s', [AName]);
{$ENDIF}
  if (FCurrentProp = nil) or (FCurrentProp.PropertyName <> AName) then
  begin
    // ��ǰ�����ԣ�����ѡ�еĲ��ǵ�ǰ����
    if FCurrentProp <> nil then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('InspectorSelectionChange: Old Prop %s', [FCurrentProp.PropertyName]);
{$ENDIF}
      // ��ǰ�������¼����ѽ�������д�� FCurrentProp ��
      SaveCurrentPropToManager;
    end;

    FCurrentProp := FCurrentType.GetProperty(AName);
    if FCurrentProp = nil then
    begin
      FCurrentProp := FCurrentType.Add(AName);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('InspectorSelectionChange: Create New Prop %s', [FCurrentProp.PropertyName]);
{$ENDIF}
      // ע�� Prop ��Ŀ���ᵥ�����ļ��м���
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('InspectorSelectionChange: Exist New Prop %s', [FCurrentProp.PropertyName]);
{$ENDIF}
    end;

    // �ٸ��µ�����
    ShowCurrent;
  end;
end;

procedure TCnObjInspectorCommentForm.SaveCurrentPropToManager;
begin
  if FCurrentType <> nil then
    FCurrentType.Comment := UIToMemStr(edtTypeComment.Text);

  if FCurrentProp <> nil then
  begin
    FCurrentProp.PropertyComment := UIToMemStr(edtPropComment.Text);
    FCurrentProp.Comment := UIToMemStr(mmoComment.Lines.Text);
  end;
end;

procedure TCnObjInspectorCommentForm.ShowCurrent;
begin
  if FCurrentType <> nil then
  begin
    edtType.Text := FCurrentType.TypeName;
    edtTypeComment.Text := FCurrentType.Comment;
  end
  else
  begin
    edtType.Text := '';
    edtTypeComment.Text := '';
  end;

  if FCurrentProp <> nil then
  begin
    edtProp.Text := FCurrentProp.PropertyName;
    edtPropComment.Text := FCurrentProp.PropertyComment;
    mmoComment.Lines.Text := MemToUIStr(FCurrentProp.Comment);
    mmoComment.ReadOnly := False;
  end
  else
  begin
    edtProp.Text := '';
    edtPropComment.Text := '';
    mmoComment.Lines.Clear;
    mmoComment.ReadOnly := True;
  end;
end;

procedure TCnObjInspectorCommentForm.FormResize(Sender: TObject);
begin
  edtTypeComment.Width := pnlType.Width - edtType.Width - 6;
  edtPropComment.Width := pnlProp.Width - edtProp.Width - 6;
end;

procedure TCnObjInspectorCommentForm.FormShow(Sender: TObject);
begin
  FormResize(Sender);
end;

function TCnObjInspectorCommentForm.MemToUIStr(const Str: string): string;
begin
  Result := StringReplace(Str, csRepCRLF, csCRLF, [rfReplaceAll]);
end;

function TCnObjInspectorCommentForm.UIToMemStr(const Str: string): string;
begin
  Result := StringReplace(Str, csCRLF, csRepCRLF, [rfReplaceAll]);
end;

{ TCnPropertyCommentType }

function TCnPropertyCommentType.Add(const PropertyName: string): TCnPropertyCommentItem;
begin
  Result := nil;
  if (PropertyName = '') or (IndexOfProperty(PropertyName) >= 0) then
    Exit;

  Result := TCnPropertyCommentItem.Create(Self);
  Result.PropertyName := PropertyName;
  inherited Add(Result);
end;

constructor TCnPropertyCommentType.Create;
begin
  inherited Create(True);
end;

destructor TCnPropertyCommentType.Destroy;
begin

  inherited;
end;

function TCnPropertyCommentType.GetItem(Index: Integer): TCnPropertyCommentItem;
begin
  Result := TCnPropertyCommentItem(inherited GetItem(Index));
end;

function TCnPropertyCommentType.GetProperty(
  const PropertyName: string): TCnPropertyCommentItem;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].PropertyName = PropertyName then
    begin
      Result := Items[I];
      Exit;
    end;
  end;
  Result := nil;
end;

function TCnPropertyCommentType.IndexOfProperty(const PropertyName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].PropertyName = PropertyName then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCnPropertyCommentType.Load;
begin

end;

procedure TCnPropertyCommentType.LoadFromFile(const FileName: string);
const
  SEP = #2;
var
  I: Integer;
  S: string;
  SL, Res: TStringList;
  Item: TCnPropertyCommentItem;
begin
  SL := TStringList.Create;
  Res := TStringList.Create;
  try
    SL.LoadFromFile(FileName);
    Clear;

    // ��һ������������ע��
    if Count >= 1 then
    begin
      S := SL[0];
      Res.Clear;
      ExtractStrings([SEP], [' '], PChar(S), Res);

      if Res.Count > 0 then 
      begin
        if TypeName = '' then // �����ж������Ƿ�һ��
          TypeName := Res[0]
        else if TypeName <> Res[0] then
          raise Exception.Create('Type Name NOT Matched');
      end;
      if Res.Count > 1 then
        Comment := Res[1];
    end;

    // ������������¼�
    for I := 1 to SL.Count - 1 do
    begin
      S := SL[I];
      Res.Clear;
      ExtractStrings([SEP], [' '], PChar(S), Res);

      // �õ� SEP �ָ�����ݣ�˳���������¼����������¼�ע�ͣ���ע��
      if Res.Count > 0 then
      begin
        Item := Add(Res[0]);
        if Res.Count > 1 then
          Item.PropertyComment := Res[1];
        if Res.Count > 2 then
          Item.Comment := Res[2];
      end;
    end;
  finally
    Res.Free;
    SL.Free;
  end;
end;

procedure TCnPropertyCommentType.NotifyChanged;
begin
  FChanged := True;
end;

procedure TCnPropertyCommentType.Remove(const PropertyName: string);
var
  Idx: Integer;
begin
  Idx := IndexOfProperty(PropertyName);
  if Idx >= 0 then
    Delete(Idx);
end;

procedure TCnPropertyCommentType.Save;
begin

end;

procedure TCnPropertyCommentType.SaveToFile(const FileName: string);
begin

end;

procedure TCnPropertyCommentType.SetItem(Index: Integer;
  const Value: TCnPropertyCommentItem);
begin
  inherited SetItem(Index, Value);
end;

{ TCnPropertyCommentManager }

function TCnPropertyCommentManager.AddType(
  const TypeName: string): TCnPropertyCommentType;
var
  Obj: Pointer;
begin
  Result := nil;
  if TypeName = '' then
    Exit;

  if not FHashMap.Find(TypeName, Obj) then
  begin
    Result := TCnPropertyCommentType.Create;
    Result.TypeName := TypeName;
    FHashMap.Add(TypeName, Result);
  end;
end;

constructor TCnPropertyCommentManager.Create;
begin
  inherited;
  FHashMap := TCnStrToPtrHashMap.Create;
  FList := TObjectList.Create(True);
end;

destructor TCnPropertyCommentManager.Destroy;
begin
  FList.Free;
  FHashMap.Free;
  inherited;
end;

function TCnPropertyCommentManager.GetType(
  const TypeName: string): TCnPropertyCommentType;
begin
  Result := nil;
  FHashMap.Find(TypeName, Pointer(Result));
end;

function TCnPropertyCommentManager.IndexOfType(const TypeName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
  begin
    if TCnPropertyCommentType(FList[I]).TypeName = TypeName then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCnPropertyCommentManager.LoadFromDirectory(
  const DirName: string);
begin

end;

procedure TCnPropertyCommentManager.RemoveType(const TypeName: string);
var
  Idx: Integer;
begin
  FHashMap.Delete(TypeName);
  Idx := IndexOfType(TypeName);
  if Idx >= 0 then
    FList.Delete(Idx);
end;

procedure TCnPropertyCommentManager.SaveToDirectory(const DirName: string);
begin

end;

{ TCnPropertyCommentItem }

constructor TCnPropertyCommentItem.Create(AOwnerType: TCnPropertyCommentType);
begin
  inherited Create;
  FOwnerType := AOwnerType;
end;

destructor TCnPropertyCommentItem.Destroy;
begin

  inherited;
end;

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}
end.
