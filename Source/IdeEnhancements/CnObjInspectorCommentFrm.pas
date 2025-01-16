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
  Contnrs, ToolsAPI, CnWizNotifier, CnWizIdeDock, CnWizShareImages, CnWizOptions,
  CnWizConsts, CnObjectInspectorWrapper, CnHashMap, CnCommon, CnWizClasses;

type
  TCnPropertyCommentType = class;

  TCnPropertyCommentItem = class(TPersistent)
  {* ���������¼�}
  private
    FComment: string;
    FPropertyName: string;
    FOwnerType: TCnPropertyCommentType;
    FPropertyComment: string;
    function GetEmpty: Boolean;
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

    property Empty: Boolean read GetEmpty;
    {* �Ƿ�Ϊ��}
  end;

  TCnPropertyCommentManager = class;

  TCnPropertyCommentType = class(TObjectList)
  {* һ�����ͳ������������¼���}
  private
    FChanged: Boolean;
    FTypeName: string;
    FComment: string;
    FManager: TCnPropertyCommentManager;
    function GetItem(Index: Integer): TCnPropertyCommentItem;
    procedure SetItem(Index: Integer; const Value: TCnPropertyCommentItem);
    function GetEmpty: Boolean;
  public
    constructor Create(AManager: TCnPropertyCommentManager); virtual;
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

    property Empty: Boolean read GetEmpty;
    {* �Ƿ�Ϊ�ա���������Ŀ������Ŀ��ע���������}

    property Items[Index: Integer]: TCnPropertyCommentItem read GetItem write SetItem; default;
    {* ��������Ժ��¼���Ŀ}

    property Changed: Boolean read FChanged write FChanged;
    {* �� Item ֪ͨ�ĸı䣬����ɹ������ False}
    property Manager: TCnPropertyCommentManager read FManager write FManager;
    {* �����Ĺ�����}
  end;

  TCnPropertyCommentManager = class
  {* �����鿴�����ʹ�õı�ע�����������ж������}
  private
    FList: TObjectList;            // ���в������� TCnPropertyCommentType
    FHashMap: TCnStrToPtrHashMap;  // ���� TypeName ���������� Map��ֻ���ã����������
    FDataDir: string;
    FUserDir: string;
    function GetCount: Integer;
    function GetItem(Index: Integer): TCnPropertyCommentType;
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

    property Count: Integer read GetCount;
    {* ��������}
    property Items[Index: Integer]: TCnPropertyCommentType read GetItem; default;
    {* �����͵���Ŀ}

    property DataDir: string read FDataDir write FDataDir;
    {* ԭʼ���ݴ���Ŀ¼��β���� \}
    property UserDir: string read FUserDir write FUserDir;
    {* �û����ݴ���Ŀ¼��β���� \}
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
    actlstComment: TActionList;
    actClear: TAction;
    actFont: TAction;
    actHelp: TAction;
    statHie: TStatusBar;
    pnlContainer: TPanel;
    pnlRight: TPanel;
    spl1: TSplitter;
    pnlLeft: TPanel;
    pnlType: TPanel;
    edtType: TEdit;
    pnlProp: TPanel;
    edtProp: TEdit;
    pnlEdtType: TPanel;
    edtTypeComment: TEdit;
    pnlEdtProp: TPanel;
    edtPropComment: TEdit;
    procedure actHelpExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FWizard: TCnBaseWizard;
    FManager: TCnPropertyCommentManager;
    FCurrentType: TCnPropertyCommentType;
    FCurrentProp: TCnPropertyCommentItem;
    procedure InspectorSelectionChange(Sender: TObject); // ע����Ϊ����ط����õ��ã�Sender ���ɿ�
    procedure FormEditorChange(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
      Component: TComponent; const OldName, NewName: string);
    function MemToUIStr(const Str: string): string;
    function UIToMemStr(const Str: string): string;
  protected
    function GetHelpTopic: string; override;
    procedure AdjustHeight(Sender: TObject);
  public
    procedure SetCommentFont(AFont: TFont);
    procedure ShowCurrent;
    procedure SaveCurrentPropToManager;

    property Wizard: TCnBaseWizard read FWizard write FWizard;
    property Manager: TCnPropertyCommentManager read FManager;
  end;

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

{$R *.DFM}

uses
  CnWizUtils, CnObjInspectorEnhancements {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  csCommentDir = 'OIComm';
  csRepCRLF = '\n';
  csCRLF = #13#10;
  FILE_SEP = #2;

procedure TCnObjInspectorCommentForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnObjInspectorCommentForm.GetHelpTopic: string;
begin
  Result := 'CnObjInspectorEnhanceWizard';
end;

procedure TCnObjInspectorCommentForm.actFontExecute(Sender: TObject);
begin
  dlgFont.Font := mmoComment.Font;
  if dlgFont.Execute then
  begin
    SetCommentFont(dlgFont.Font);
    if FWizard <> nil then
      (FWizard as TCnObjInspectorEnhanceWizard).CommentFont := dlgFont.Font;
  end;
end;

procedure TCnObjInspectorCommentForm.actClearExecute(Sender: TObject);
begin
  edtTypeComment.Text := '';
  edtPropComment.Text := '';
  mmoComment.Lines.Clear;
end;

procedure TCnObjInspectorCommentForm.FormCreate(Sender: TObject);
begin
  FManager := TCnPropertyCommentManager.Create;
  FManager.DataDir := MakePath(MakePath(WizOptions.DataPath) + csCommentDir);
  FManager.UserDir := MakePath(MakePath(WizOptions.UserPath) + csCommentDir);

  WizOptions.ResetToolbarWithLargeIcons(tlbObjComment);

  ObjectInspectorWrapper.AddSelectionChangeNotifier(InspectorSelectionChange);
  CnWizNotifierServices.AddFormEditorNotifier(FormEditorChange);
end;

procedure TCnObjInspectorCommentForm.FormDestroy(Sender: TObject);
begin
  FManager.Free;
  CnWizNotifierServices.RemoveFormEditorNotifier(FormEditorChange);
  ObjectInspectorWrapper.RemoveSelectionChangeNotifier(InspectorSelectionChange);
end;

procedure TCnObjInspectorCommentForm.FormEditorChange(
  FormEditor: IOTAFormEditor; NotifyType: TCnWizFormEditorNotifyType;
  ComponentHandle: TOTAHandle; Component: TComponent; const OldName,
  NewName: string);
begin
  if NotifyType in [fetOpened, fetComponentSelectionChanged,
    fetActivated, fetComponentCreated, fetComponentRenamed] then
    InspectorSelectionChange(Self);
end;

procedure TCnObjInspectorCommentForm.InspectorSelectionChange(Sender: TObject);
var
  AName, Hie: string;
  AClass: TClass;
  Root: TComponent;
begin
  // �õ���ǰ���͵�ǰ���Ի��¼�
  AName := ObjectInspectorWrapper.ActiveComponentType;
  Hie := '';

  AClass := GetClass(AName);
  if AClass = nil then
  begin
    //  �Ҳ�����˵�� AName ��������������Ҫ�� AName �����������࣬�� GetClass���ټ��� AName->
{$IFDEF DEBUG}
    CnDebugger.LogMsg('InspectorSelectionChange: ActiveComponentType Class NOT Found');
{$ENDIF}

    Root := CnOtaGetRootComponentFromEditor(CnOtaGetCurrentFormEditor);
    if (Root <> nil) and (Root is TDataModule) then
    begin
      Hie := AName + '->';
      AName := 'TDataModule';
    end
    else if (Root <> nil) and (Root is TControl) then
    begin
      Hie := AName + '->';
      AName := 'TForm';
    end;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('InspectorSelectionChange: ActiveComponentType Change to ' + AName);
{$ENDIF}
    AClass := GetClass(AName);
  end;

  while AClass <> nil do
  begin
    Hie := Hie + AClass.ClassName;
    AClass := AClass.ClassParent;
    if AClass <> nil then
      Hie := Hie + '->';
  end;
  statHie.SimpleText := Hie;

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

    if AName <> '' then
    begin
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
    end
    else
      FCurrentType := nil; // û�õ�����Ϊ��

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

    if AName <> '' then
    begin
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
    end
    else
      FCurrentProp := nil;

    // �ٸ��µ�����
    ShowCurrent;
  end;
end;

procedure TCnObjInspectorCommentForm.SaveCurrentPropToManager;
begin
  if FCurrentProp <> nil then
  begin
    FCurrentProp.PropertyComment := UIToMemStr(edtPropComment.Text);
    FCurrentProp.Comment := UIToMemStr(mmoComment.Lines.Text);
  end;

  if FCurrentType <> nil then
  begin
    FCurrentType.Comment := UIToMemStr(edtTypeComment.Text);
    FCurrentType.Save;
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

procedure TCnObjInspectorCommentForm.FormShow(Sender: TObject);
begin
  InspectorSelectionChange(Sender);
end;

procedure TCnObjInspectorCommentForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveCurrentPropToManager;
end;

procedure TCnObjInspectorCommentForm.SetCommentFont(AFont: TFont);
begin
  edtType.BorderStyle := bsSingle;
  edtProp.BorderStyle := bsSingle;

  mmoComment.Font := AFont;
  edtType.Font := AFont;
  edtTypeComment.Font := AFont;
  edtProp.Font := AFont;
  edtPropComment.Font := AFont;

  CnWizNotifierServices.ExecuteOnApplicationIdle(AdjustHeight);
end;

procedure TCnObjInspectorCommentForm.AdjustHeight(Sender: TObject);
var
  H: Integer;
begin
  H := edtTypeComment.Height * 2 + 6;
  if H < 48 then
    H := 48;

  pnlContainer.Height := H;
  edtType.BorderStyle := bsNone;
  edtProp.BorderStyle := bsNone;
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

constructor TCnPropertyCommentType.Create(AManager: TCnPropertyCommentManager);
begin
  inherited Create(True);
  FManager := AManager;
end;

destructor TCnPropertyCommentType.Destroy;
begin

  inherited;
end;

function TCnPropertyCommentType.GetEmpty: Boolean;
var
  I: Integer;
begin
  Result := Count <= 0;
  if not Result then
  begin
    // ����� False ��ʾ����Ŀ�������ж���Ŀ
    for I := 0 to Count - 1 do
    begin
      if not Items[I].Empty then // �зǿյģ�ֱ�ӷ��� False �˳�
        Exit;
    end;
    Result := True;
  end;
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
var
  F: string;
begin
  if TypeName = '' then
    Exit;

  F := FManager.UserDir + TypeName + '.txt';
  if not FileExists(F) then
    F := FManager.DataDir + TypeName + '.txt';

  if FileExists(F) then
    LoadFromFile(F);
end;

procedure TCnPropertyCommentType.LoadFromFile(const FileName: string);
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
    if SL.Count >= 1 then
    begin
      S := SL[0];
      Res.Clear;
      ExtractStrings([FILE_SEP], [' '], PChar(S), Res);

      if Res.Count > 0 then 
      begin
        if TypeName = '' then // �����ж������Ƿ�һ��
          TypeName := Res[0]
        else if TypeName <> Res[0] then
          raise Exception.Create('Type Name NOT Matched');

        if Res.Count > 1 then
          Comment := Res[1];
      end;
    end;

    // ������������¼�
    for I := 1 to SL.Count - 1 do
    begin
      S := SL[I];
      Res.Clear;
      ExtractStrings([FILE_SEP], [' '], PChar(S), Res);

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
var
  F: string;
begin
  if TypeName = '' then
    Exit;

  F := FManager.UserDir + TypeName + '.txt';
  ForceDirectories(FManager.UserDir);

  // ���ûĿ���ļ����Լ�û���ݾ������
  if not FileExists(F) and Empty then
    Exit;

  SaveToFile(F);
end;

procedure TCnPropertyCommentType.SaveToFile(const FileName: string);
var
  SL: TStringList;
  S: string;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    // ��һ������������ע��
    S := FTypeName + FILE_SEP + FComment;
    SL.Add(S);

    // �����������¼����������¼�ע�ͣ���ע��
    for I := 0 to Count - 1 do
    begin
      S := Items[I].PropertyName + FILE_SEP + Items[I].PropertyComment + FILE_SEP + Items[I].Comment;
      SL.Add(S);
    end;

    try
      SL.SaveToFile(FileName); // ������쳣����
      Changed := False;
    except
      ;
    end;
  finally
    SL.Free;
  end;
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
    Result := TCnPropertyCommentType.Create(Self);
    Result.TypeName := TypeName;
    FHashMap.Add(TypeName, Result); // �������
    FList.Add(Result);              // ������������
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

function TCnPropertyCommentManager.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnPropertyCommentManager.GetItem(
  Index: Integer): TCnPropertyCommentType;
begin
  Result := TCnPropertyCommentType(FList[Index]);
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

function TCnPropertyCommentItem.GetEmpty: Boolean;
begin
  Result := (FComment= '') and (FPropertyComment = '');
end;

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}
end.
