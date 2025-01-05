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

unit CnObjectInspectorWrapper;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����鿴���Ĳ�����װ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Win7 + Delphi 5.01
* ���ݲ��ԣ�Win7 + D5/2007/2009
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.01.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Controls, Forms, TypInfo, CnEventHook;

type
  TCnObjectInspectorWrapper = class
  {* ����鿴���ķ�װ}
  private
    FObjectInspectorForm: TCustomForm;  // ����鿴������
    FPropListBox: TControl;             // ����鿴���ڲ��б�
    FEventHook: TCnEventHook;
    FSelectionChangeNotifiers: TList;
    function GetActiveComponentName: string;
    function GetActiveComponentType: string;
    function GetActivePropName: string;
    function GetActivePropValue: string;
    function GetShowGridLines: Boolean;
    procedure SetShowGridLines(const Value: Boolean);
  protected
    procedure SelectionItem(Sender: TObject);
    procedure CheckObjectInspector;
    procedure InitObjectInspector;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AddSelectionChangeNotifier(Notifier: TNotifyEvent);
    {* ����һ��ѡ�иı��֪ͨ}
    procedure RemoveSelectionChangeNotifier(Notifier: TNotifyEvent);
    {* ɾ��һ��ѡ�иı��֪ͨ}

    property ActiveComponentType: string read GetActiveComponentType;
    {* ����鿴����ǰѡ�е��������}
    property ActiveComponentName: string read GetActiveComponentName;
    {* ����鿴����ǰѡ�е������}
    property ActivePropName: string read GetActivePropName;
    {* ����鿴����ǰѡ�е�������}
    property ActivePropValue: string read GetActivePropValue;
    {* ����鿴����ǰѡ�е�����ֵ}
    property ShowGridLines: Boolean read GetShowGridLines write SetShowGridLines;
    {* ����鿴����ʾ���Ƿ���ʾ����}
  end;

function ObjectInspectorWrapper: TCnObjectInspectorWrapper;
{* ��ȡȫ�ֶ���鿴���ķ�װ����}

implementation

uses
  CnWizIdeUtils, CnWizNotifier, CnWizUtils {$IFDEF DEBUG}, CnDebug {$ENDIF};

type
  TNotifyEventProc = procedure (Self: TObject; Sender: TObject);

var
  FObjectInspectorWrapper: TCnObjectInspectorWrapper = nil;

function ObjectInspectorWrapper: TCnObjectInspectorWrapper;
begin
  if FObjectInspectorWrapper = nil then
    FObjectInspectorWrapper := TCnObjectInspectorWrapper.Create;
  Result := FObjectInspectorWrapper;
end;

{ TCnObjectInspectorWrapper }

procedure TCnObjectInspectorWrapper.AddSelectionChangeNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizAddNotifier(FSelectionChangeNotifiers, TMethod(Notifier));
end;

procedure TCnObjectInspectorWrapper.CheckObjectInspector;
begin
  if (FObjectInspectorForm = nil) or (FPropListBox = nil) then
    InitObjectInspector;
end;

constructor TCnObjectInspectorWrapper.Create;
begin
  inherited;
  FSelectionChangeNotifiers := TList.Create;

  InitObjectInspector;
end;

destructor TCnObjectInspectorWrapper.Destroy;
begin
  FEventHook.Free;
  CnWizClearAndFreeList(FSelectionChangeNotifiers);
  inherited;
end;

function TCnObjectInspectorWrapper.GetActiveComponentName: string;
begin
  CheckObjectInspector;
  if FObjectInspectorForm <> nil then
    Result := GetStrProp(FObjectInspectorForm, 'ActiveComponentName')
  else
    Result := '';
end;

function TCnObjectInspectorWrapper.GetActiveComponentType: string;
begin
  CheckObjectInspector;
  if FObjectInspectorForm <> nil then
    Result := GetStrProp(FObjectInspectorForm, 'ActiveComponentType')
  else
    Result := '';
end;

function TCnObjectInspectorWrapper.GetActivePropName: string;
begin
  CheckObjectInspector;
  if FObjectInspectorForm <> nil then
    Result := GetStrProp(FObjectInspectorForm, 'ActivePropName')
  else
    Result := '';
end;

function TCnObjectInspectorWrapper.GetActivePropValue: string;
begin
  CheckObjectInspector;
  if FObjectInspectorForm <> nil then
    Result := GetStrProp(FObjectInspectorForm, 'ActivePropValue')
  else
    Result := '';
end;

function TCnObjectInspectorWrapper.GetShowGridLines: Boolean;
var
  PropInfo: PPropInfo;
begin
  CheckObjectInspector;
  Result := False;

  if FPropListBox <> nil then
  begin
    PropInfo := GetPropInfo(FPropListBox, 'ShowGridLines');
    if PropInfo <> nil then
      Result := GetOrdProp(FPropListBox, 'ShowGridLines') <> 0;
  end;
end;

procedure TCnObjectInspectorWrapper.InitObjectInspector;
var
  C: TComponent;
{$IFDEF DEBUG}
  PropInfo: PPropInfo;
{$ENDIF}
begin
  // �Ҵ���
  FObjectInspectorForm := GetObjectInspectorForm;
  if FObjectInspectorForm <> nil then
  begin
{$IFDEF DEBUG}
    PropInfo := GetPropInfo(FObjectInspectorForm, 'ActiveComponentType');
    if PropInfo <> nil then
      CnDebugger.LogMsg('TCnObjectInspectorWrapper ActiveComponentType ' + PropInfo^.PropType^.Name);

    PropInfo := GetPropInfo(FObjectInspectorForm, 'ActiveComponentName');
    if PropInfo <> nil then
      CnDebugger.LogMsg('TCnObjectInspectorWrapper ActiveComponentName ' + PropInfo^.PropType^.Name);

    PropInfo := GetPropInfo(FObjectInspectorForm, 'ActivePropName');
    if PropInfo <> nil then
      CnDebugger.LogMsg('TCnObjectInspectorWrapper ActivePropName ' + PropInfo^.PropType^.Name);

    PropInfo := GetPropInfo(FObjectInspectorForm, 'ActivePropValue');
    if PropInfo <> nil then
      CnDebugger.LogMsg('TCnObjectInspectorWrapper ActivePropValue ' + PropInfo^.PropType^.Name);
{$ENDIF}

    C := FObjectInspectorForm.FindComponent(PropertyInspectorListName);
    if C <> nil then
    begin
      if C is TControl then
      begin
        FPropListBox := TControl(C);

{$IFDEF DEBUG}
        PropInfo := GetPropInfo(FPropListBox, 'ShowGridLines');
        if PropInfo <> nil then
          CnDebugger.LogMsg('TCnObjectInspectorWrapper ShowGridLines ' + PropInfo^.PropType^.Name)
        else
          CnDebugger.LogMsg('TCnObjectInspectorWrapper ShowGridLines NOT Exists.');
{$ENDIF}

        // Hook �� Selection Change �¼�
        FEventHook := TCnEventHook.Create(FPropListBox, 'OnSelectItem',
          Self, @TCnObjectInspectorWrapper.SelectionItem);
        // ע��˴�Ӧ�� Self��ȷ�� SelectionItem �����õ� Self ����ȷ��

{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnObjectInspectorWrapper.InitObjectInspector Hooked.');
{$ENDIF}
      end;
    end;
  end;
end;

procedure TCnObjectInspectorWrapper.RemoveSelectionChangeNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizRemoveNotifier(FSelectionChangeNotifiers, TMethod(Notifier));
end;

procedure TCnObjectInspectorWrapper.SelectionItem(Sender: TObject);
var
  I: Integer;
begin
  if FEventHook.Trampoline <> nil then
    TNotifyEventProc(FEventHook.Trampoline)(FEventHook.TrampolineData, Sender);

  // ������ɴ����¼��󣬷���֪ͨ
  if FSelectionChangeNotifiers <> nil then
  begin
    for I := FSelectionChangeNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FSelectionChangeNotifiers[I])^ do
        TNotifyEvent(Notifier)(Sender);
    except
      DoHandleException('TCnObjectInspectorWrapper.SelectionItem[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnObjectInspectorWrapper.SetShowGridLines(const Value: Boolean);
var
  PropInfo: PPropInfo;
begin
  CheckObjectInspector;
  if FPropListBox <> nil then
  begin
    PropInfo := GetPropInfo(FPropListBox, 'ShowGridLines');
    if PropInfo <> nil then
    begin
      SetOrdProp(FPropListBox, 'ShowGridLines', Ord(Value));
      FPropListBox.Repaint;
    end;
  end;
end;

initialization

finalization
  if FObjectInspectorWrapper <> nil then
    FreeAndNil(FObjectInspectorWrapper);

end.
