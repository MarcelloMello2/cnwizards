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

unit CnObjInspectorEnhancements;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����鿴����չ��Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2004.5.15 chinbo(shenloqi)
*               ֧�� setelement �Ĵ�����ʾ
*           2003.10.31
*               ע������Ч��ö��Ԫ�صļӴ�
*           2003.10.27
*               ����ʵ���� D5 �µļӴֹ��ܣ�D6, D7 ��Ҫ���������ķ�����
*           2003.10.27
*               ʵ�����Ա༭�������ҽӺ��ļ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

uses
  Windows, SysUtils, Classes, Graphics, IniFiles, TypInfo, Controls, StdCtrls,
  Menus, Forms,
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, VCLEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  CnConsts, CnWizClasses, CnWizConsts, CnWizMultiLang, CnWizMethodHook, CnIni,
  CnObjInspectorCommentFrm, CnMenuHook;

type
  TCnObjInspectorEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
    FEnhancePaint: Boolean;
    FShowCommentMenu: Boolean;
    FInspectorComment: Boolean;
    FMenuHook: TCnMenuHook;
    FCommentWindowMenu: TCnMenuItemDef;
    FCommentForm: TCnObjInspectorCommentForm;
    procedure HookPropEditor;
    procedure UnhookPropEditor;
    procedure SetEnhancePaint(const Value: Boolean);
    procedure SetInspectorComment(const Value: Boolean);
    function GetShowGridLine: Boolean;
    procedure SetShowGridLine(const Value: Boolean);
    procedure SetShowCommentMenu(const Value: Boolean);
    function GetShowGridLineBDS: Boolean;
    procedure SetShowGridLineBDS(const Value: Boolean);
  protected
    procedure HookObjectInspectorMenu;
    procedure ActiveFormChanged(Sender: TObject);
    procedure OnCommentWindowClick(Sender: TObject);
    procedure OnMenuAfterPopup(Sender: TObject; Menu: TPopupMenu);
    function GetHasConfig: Boolean; override;
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;

    property EnhancePaint: Boolean read FEnhancePaint write SetEnhancePaint;
    {* �Ƿ���ǿ�������Ա༭������ Delphi 5 ����Ч}
    property ShowGridLine: Boolean read GetShowGridLine write SetShowGridLine;
    {* �Ƿ���ʾ����鿴���������ߣ���� D6/7 ��Ч}
    property ShowGridLineBDS: Boolean read GetShowGridLineBDS write SetShowGridLineBDS;
    {* �Ƿ���ʾ����鿴���������ߣ���� D2005 �����ϰ汾��Ч}
    property ShowCommentMenu: Boolean read FShowCommentMenu write SetShowCommentMenu;
    {* �Ƿ��ڶ���鿴�����Ҽ��˵��������ʾ��ע����Ĳ˵���}

    property InspectorComment: Boolean read FInspectorComment write SetInspectorComment;
    {* �Ƿ���ʾ����鿴����ע����}
  end;

  TCnObjInspectorConfigForm = class(TCnTranslateForm)
    grpSettings: TGroupBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    chkEnhancePaint: TCheckBox;
    chkCommentWindow: TCheckBox;
    chkShowGridLine: TCheckBox;
    chkShowGridLineBDS: TCheckBox;
    procedure btnHelpClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

{$R *.DFM}

uses
  CnCommon, CnObjectInspectorWrapper, CnWizNotifier;

const
  csEnhancePaint = 'EnhancePaint';
  csShowGridLine = 'ShowGridLine';
  csShowGridLineBDS = 'ShowGridLineBDS';
  csShowCommentMenu = 'ShowCommentMenu';

{$IFDEF COMPILER5}

type
  // ԭ���Ա༭�����Ʒ�������Ϊԭ����Ϊ���󷽷���ר����ʹ����ͨ�������ҽӣ�
  // �ʶ���һ�� ASelf: TPropertyEditor �����ض���ʵ��
  TPropDrawProc = procedure (ASelf: TPropertyEditor; ACanvas: TCanvas;
    const ARect: TRect; ASelected: Boolean);

  THackPropertyEditor = class(TPropertyEditor);

{$ENDIF}

var
{$IFDEF COMPILER5}
  OldPropDrawName: TPropDrawProc;
  OldPropDrawValue: TPropDrawProc;
  PropDrawNameHook: TCnMethodHook;
  PropDrawValueHook: TCnMethodHook;
{$ENDIF}
  AllowHook: Boolean = False;

{$IFDEF COMPILER5}

// �ҽ� TPropertyEditor.PropDrawName �ķ���
procedure PropDrawName(ASelf: TPropertyEditor; ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
begin
  if AllowHook and (ASelf.PropCount > 0) then
  begin
    // ������ PropCount = 0 ʱ���� GetPropType ����
    if (THackPropertyEditor(ASelf).GetPropType.Kind in [tkClass]) and
      (not (paSubProperties in ASelf.GetAttributes)) and
      (not (paDialog in ASelf.GetAttributes)) and
      (paValueList in ASelf.GetAttributes) then
      ACanvas.Font.Color := clMaroon;
  end;

  // ����ԭ���ķ���
  PropDrawNameHook.UnhookMethod;
  try
    OldPropDrawName(ASelf, ACanvas, ARect, ASelected);
  finally
    PropDrawNameHook.HookMethod;
  end;
end;

// �ҽ� TPropertyEditor.PropDrawValue �ķ���
procedure PropDrawValue(ASelf: TPropertyEditor; ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
const
  tkOrdinal = [tkEnumeration, tkInteger, tkChar, tkWChar];

  function _ObjPropAllEqualDef(AObj: TObject): Boolean;
  var
    PropList: PPropList;
    Count, I: Integer;
  begin
    Result := True;
    try
      Count := GetPropList(AObj.ClassInfo, tkOrdinal, nil);
    except
      Exit;
    end;

    GetMem(PropList, Count * SizeOf(PPropInfo));
    try
      GetPropList(AObj.ClassInfo, tkOrdinal, PropList);
      for I := 0 to Count - 1 do
      begin
        if PropList[I].Default <> GetOrdProp(AObj, PropList[I]) then
        begin
          Result := False;
          Break;
        end;
      end;
    finally
      FreeMem(PropList);
    end;
  end;

var
  EnumInfo: PTypeInfo;
  dwDefault, dwValue: DWORD;
  dwbBit: TDWordBit;
begin
  if AllowHook and (ASelf.PropCount > 0) then
  begin
    // ���� IsStoredProp
    if not ASelected then
    begin
      if ASelf is TSetElementProperty then
      begin
        EnumInfo := GetTypeData(THackPropertyEditor(ASelf).GetPropType).CompType^;
        dwDefault := THackPropertyEditor(ASelf).GetPropInfo.Default;
        dwValue := THackPropertyEditor(ASelf).GetOrdValue;
        dwbBit := GetEnumValue(EnumInfo, TSetElementProperty(ASelf).GetName);
        if GetBit(dwDefault, dwbBit) <> GetBit(dwValue, dwbBit) then
        begin
          ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
        end
        else
          ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
      end
      else
      begin
        // TODO: �ж��¼��ǲ��Ǽ̳е�
        if ((THackPropertyEditor(ASelf).GetPropType.Kind in tkOrdinal) and
            (THackPropertyEditor(ASelf).GetOrdValue <> THackPropertyEditor(ASelf).GetPropInfo.default)) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind in [tkFloat]) and
            (THackPropertyEditor(ASelf).GetFloatValue <> 0)) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind in [tkString, tkLString, tkWString{$IFDEF UNICODE}, tkUString{$ENDIF}]) and
            (THackPropertyEditor(ASelf).GetStrValue <> '') and (THackPropertyEditor(ASelf).GetName <> 'Name')) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind in [tkInt64]) and
            (THackPropertyEditor(ASelf).GetInt64Value <> THackPropertyEditor(ASelf).GetPropInfo.default)) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind = tkClass) and
            (Pointer(THackPropertyEditor(ASelf).GetOrdValue) <> nil) and
            (not _ObjPropAllEqualDef(TObject(THackPropertyEditor(ASelf).GetOrdValue)))) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind in [tkMethod]) and
            (THackPropertyEditor(ASelf).GetMethodValue.Code <> nil)) then
            ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
      end;
    end;
  end;

  // ����ԭ���ķ���
  PropDrawValueHook.UnhookMethod;
  try
    OldPropDrawValue(ASelf, ACanvas, ARect, ASelected);
  finally
    PropDrawValueHook.HookMethod;
  end;
end;

{$ENDIF}

{ TCnObjInspectorEnhanceWizard }

constructor TCnObjInspectorEnhanceWizard.Create;
begin
  inherited;
  HookPropEditor;

  FMenuHook := TCnMenuHook.Create(nil);
  HookObjectInspectorMenu;

  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
end;

destructor TCnObjInspectorEnhanceWizard.Destroy;
begin
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);

  FMenuHook.Free;
  if FCommentForm <> nil then
    FCommentForm.Free;

  UnhookPropEditor;
  inherited;
end;

procedure TCnObjInspectorEnhanceWizard.HookPropEditor;
begin
{$IFDEF COMPILER5}
  // ȡ��ԭ�е����Ա༭�����Ʒ�����ַ
  OldPropDrawName := GetBplMethodAddress(@TPropertyEditor.PropDrawName);
  OldPropDrawValue := GetBplMethodAddress(@TPropertyEditor.PropDrawValue);
  // �ҽ����Ա༭�����Ʒ���
  PropDrawNameHook := TCnMethodHook.Create(@OldPropDrawName, @PropDrawName);
  PropDrawValueHook := TCnMethodHook.Create(@OldPropDrawValue, @PropDrawValue);
{$ENDIF}
end;

procedure TCnObjInspectorEnhanceWizard.UnhookPropEditor;
begin
{$IFDEF COMPILER5}
  OldPropDrawName := nil;
  OldPropDrawValue := nil;
  FreeAndNil(PropDrawNameHook);
  FreeAndNil(PropDrawValueHook);
{$ENDIF}
end;

procedure TCnObjInspectorEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    EnhancePaint := Ini.ReadBool('', csEnhancePaint, True);
{$IFDEF BDS}
    ShowGridLineBDS := Ini.ReadBool('', csShowGridLineBDS, False);  // 2005 �����ϰ汾Ĭ���޻���
{$ELSE}
    ShowGridLine := Ini.ReadBool('', csShowGridLine, True);         // D 6 7 Ĭ���л��ߣ�D5 ��Ч
{$ENDIF}
    ShowCommentMenu := Ini.ReadBool('', csShowCommentMenu, False);
  finally
    Free;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    Ini.WriteBool('', csEnhancePaint, FEnhancePaint);
{$IFDEF BDS}
    Ini.WriteBool('', csShowGridLineBDS, ShowGridLineBDS);
{$ELSE}
    Ini.WriteBool('', csShowGridLine, ShowGridLine);
{$ENDIF}
    Ini.WriteBool('', csShowCommentMenu, FShowCommentMenu);
  finally
    Free;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.SetActive(Value: Boolean);
begin
  inherited;
  AllowHook := Value and FEnhancePaint;
end;

procedure TCnObjInspectorEnhanceWizard.Config;
begin
  with TCnObjInspectorConfigForm.Create(nil) do
  begin
{$IFDEF COMPILER5}
    chkEnhancePaint.Checked := EnhancePaint;
    chkShowGridLine.Enabled := False; // D5 �ĸù���û����
{$ELSE}
    chkEnhancePaint.Enabled := False;
{$ENDIF}

{$IFDEF BDS}
    chkShowGridLineBDS.Checked := ShowGridLineBDS;
    chkShowGridLine.Enabled := False;
{$ELSE}
    chkShowGridLine.Checked := ShowGridLine;
    chkShowGridLineBDS.Enabled := False;
{$ENDIF}

    chkCommentWindow.Checked := ShowCommentMenu;

    if ShowModal = mrOk then
    begin
{$IFDEF COMPILER5}
      EnhancePaint := chkEnhancePaint.Checked;
{$ENDIF}

{$IFDEF BDS}
      ShowGridLineBDS := chkShowGridLineBDS.Checked;
{$ELSE}
      ShowGridLine := chkShowGridLine.Checked;
{$ENDIF}
      ShowCommentMenu := chkCommentWindow.Checked;
    end;
  end;
end;

function TCnObjInspectorEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnObjInspectorEnhanceWizard.GetWizardInfo(var Name,
  Author, Email, Comment: string);
begin
  Name := SCnObjInspectorEnhanceWizardName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnObjInspectorEnhanceWizardComment;
end;

procedure TCnObjInspectorEnhanceWizard.SetEnhancePaint(const Value: Boolean);
begin
  FEnhancePaint := Value;
  AllowHook := Active and FEnhancePaint;
  ObjectInspectorWrapper.RepaintPropList;
end;

procedure TCnObjInspectorEnhanceWizard.SetInspectorComment(const Value: Boolean);
begin
  FInspectorComment := Value;

  if FInspectorComment then
  begin
    if FCommentForm = nil then
      FCommentForm := TCnObjInspectorCommentForm.Create(Application);
    FCommentForm.VisibleWithParent := True;
    FCommentForm.BringToFront;
  end
  else
  begin
    if FCommentForm <> nil then
      FCommentForm.Hide;
  end;
end;

function TCnObjInspectorEnhanceWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '����,property,�¼�,event,';
end;

function TCnObjInspectorEnhanceWizard.GetShowGridLine: Boolean;
begin
  Result := ObjectInspectorWrapper.ShowGridLines;
end;

procedure TCnObjInspectorEnhanceWizard.SetShowGridLine(
  const Value: Boolean);
begin
{$IFNDEF BDS}
  if Active then
    ObjectInspectorWrapper.ShowGridLines := Value;
{$ENDIF}
end;

function TCnObjInspectorEnhanceWizard.GetShowGridLineBDS: Boolean;
begin
  Result := ObjectInspectorWrapper.ShowGridLines;
end;

procedure TCnObjInspectorEnhanceWizard.SetShowGridLineBDS(
  const Value: Boolean);
begin
{$IFDEF BDS}
  if Active then
    ObjectInspectorWrapper.ShowGridLines := Value;
{$ENDIF}
end;

procedure TCnObjInspectorEnhanceWizard.SetShowCommentMenu(
  const Value: Boolean);
begin
  if FShowCommentMenu <> Value then
  begin
    FShowCommentMenu := Value;
    FMenuHook.Active := FShowCommentMenu;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.OnCommentWindowClick(
  Sender: TObject);
begin
  InspectorComment := not InspectorComment;
end;

procedure TCnObjInspectorEnhanceWizard.OnMenuAfterPopup(Sender: TObject; Menu: TPopupMenu);
var
  I: Integer;
begin
  for I := 0 to Menu.Items.Count - 1 do
  begin
    if Menu.Items.Items[I].Name = SCnObjInspectorCommentWindowMenuName then
    begin
      Menu.Items.Items[I].Checked := (FCommentForm <> nil) and FCommentForm.VisibleWithParent;
      Exit;
    end;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.HookObjectInspectorMenu;
begin
  if (ObjectInspectorWrapper.PopupMenu <> nil) and not
    FMenuHook.IsHooked(ObjectInspectorWrapper.PopupMenu) then
  begin
    FMenuHook.HookMenu(ObjectInspectorWrapper.PopupMenu);
    FMenuHook.OnAfterPopup := OnMenuAfterPopup;
    FCommentWindowMenu := TCnMenuItemDef.Create(SCnObjInspectorCommentWindowMenuName,
      SCnObjInspectorCommentWindowMenuCaption, OnCommentWindowClick, ipLast);
    FMenuHook.AddMenuItemDef(FCommentWindowMenu);
  end;
end;

procedure TCnObjInspectorEnhanceWizard.ActiveFormChanged(Sender: TObject);
begin
  HookObjectInspectorMenu;
end;

{ TCnObjInspectorConfigForm }

function TCnObjInspectorConfigForm.GetHelpTopic: string;
begin
  Result := 'CnObjInspectorEnhanceWizard';
end;

procedure TCnObjInspectorConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

initialization
  RegisterCnWizard(TCnObjInspectorEnhanceWizard);

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}
end.
