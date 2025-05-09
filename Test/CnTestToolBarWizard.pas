{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestToolBarWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编辑器工具栏测试专家演示单元
* 单元作者：CnPack 开发组
* 备    注：该单元是编辑器外部工具栏的测试单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2002.11.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, StdCtrls, ComCtrls,
  CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper;

type

//==============================================================================
// 编辑器工具栏测试用菜单专家
//==============================================================================

{ TCnTestToolBarWizard }

  TCnTestToolBarWizard = class(TCnMenuWizard)
  private
    FCombo: TControl;
    FRegistered: Boolean;
  protected
    function GetHasConfig: Boolean; override;
    procedure EditorChanged(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    destructor Destroy; override;

    procedure CreateToolBar(const ToolBarType: string; EditControl: TControl;
      ToolBar: TToolBar);
    procedure InitToolBar(const ToolBarType: string; EditControl: TControl;
      ToolBar: TToolBar);
  end;

implementation

uses
  CnSrcEditorToolBar;

//==============================================================================
// 编辑器工具栏测试用菜单专家
//==============================================================================

{ TCnTestToolBarWizard }

procedure TCnTestToolBarWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : 在此显示配置窗口 }
end;

procedure TCnTestToolBarWizard.CreateToolBar(const ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
begin
  if ToolBar <> nil then
  begin
    FCombo := TComboBox.Create(ToolBar as TComponent);
    FCombo.Parent := ToolBar as TWinControl;

    (ToolBar as TControl).Top := 50;
  end;
end;

destructor TCnTestToolBarWizard.Destroy;
begin
  if FRegistered then
    EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  inherited;
end;

procedure TCnTestToolBarWizard.EditorChanged(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
var
  S: string;
begin
  if ChangeType * [ctView, ctWindow, ctCurrLine, ctCurrCol, ctModified] <> [] then
  begin
    S := CnOtaGetCurrentProcedure;
    if S = '' then
      S := CnOtaGetCurrentOuterBlock;

    if FCombo <> nil then
      (FCombo as TComboBox).Text := S;
  end;
end;

procedure TCnTestToolBarWizard.Execute;
begin
  if CnEditorToolBarService <> nil then
  begin
    CnEditorToolBarService.RegisterToolBarType('TestToolBar',
      CreateToolBar, InitToolBar, nil);
    EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
    FRegistered := True;
  end;
  { TODO -oAnyone : 该专家的主执行过程 }
end;

function TCnTestToolBarWizard.GetCaption: string;
begin
  Result := 'Register a ToolBar Type';
  { TODO -oAnyone : 返回专家菜单的标题，字符串请进行本地化处理 }
end;

function TCnTestToolBarWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : 返回默认的快捷键 }
end;

function TCnTestToolBarWizard.GetHasConfig: Boolean;
begin
  Result := False;
  { TODO -oAnyone : 返回专家是否有配置窗口 }
end;

function TCnTestToolBarWizard.GetHint: string;
begin
  Result := 'Register an Editor ToolBar Type';
  { TODO -oAnyone : 返回专家菜单提示信息，字符串请进行本地化处理 }
end;

function TCnTestToolBarWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : 返回专家菜单状态，可根据指定条件来设定 }
end;

class procedure TCnTestToolBarWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'TestEditorToolBarWizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Editor ToolBar Wizard';
  { TODO -oAnyone : 返回专家的名称、作者、邮箱及备注，字符串请进行本地化处理 }
end;

procedure TCnTestToolBarWizard.InitToolBar(const ToolBarType: string;
  EditControl: TControl; ToolBar: TToolBar);
begin
  (FCombo as TComboBox).Items.Add('Test1');
  (FCombo as TComboBox).Items.Add('Test2');
end;

procedure TCnTestToolBarWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此装载专家内部用到的参数，专家创建时自动被调用 }
end;

procedure TCnTestToolBarWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此保存专家内部用到的参数，专家释放时自动被调用 }
end;

initialization
  RegisterCnWizard(TCnTestToolBarWizard); // 注册专家

end.
