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

library CnWizLoader64;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizard ר�� DLL ������ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ����а汾�� Delphi
* �� �� �����õ�Ԫ���豾�ػ�
* �޸ļ�¼��2025.02.03 V1.1
*               ������Ԫ
================================================================================
|</PRE>}

uses
  SysUtils,
  Classes,
  Windows,
  Forms,
  ToolsAPI,
  CnWizLoadUtils in 'CnWizLoadUtils.pas';

{$R *.RES}

// ������ DLL ��ʼ����ں��������ض�Ӧ�汾��ר�Ұ� DLL
function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
var
  Dll: string;
  Entry: TWizardEntryPoint;
begin
  if FindCmdLineSwitch(SCnNoCnWizardsSwitch, ['/', '-'], True) then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  Dll := GetWizardDll;

  if (Dll <> '') and FileExists(Dll) then
  begin
    OutputDebugString(PChar(Format('Get 64 Bit DLL: %s', [Dll])));

    DllInst := LoadLibraryW(PChar(Dll));
    if DllInst <> 0 then
    begin
      Entry := TWizardEntryPoint(GetProcAddress(DllInst, WizardEntryPoint));
      if Assigned(Entry) then
      begin
        // ���������� DLL ��ʼ������������ж�ع��̵�ָ��
        Result := Entry(BorlandIDEServices, RegisterProc, LoaderTerminateProc);
        // IDE ��ж�ع�����ָ�����ǵ�
        Terminate := LoaderTerminate;
      end
      else
        OutputDebugString(PChar(Format('64 Bit DLL Corrupted! No Entry %s', [WizardEntryPoint])));
    end
    else
      OutputDebugString(PChar(Format('64 Bit DLL Loading Error! %d', [GetLastError])));
  end
  else
    OutputDebugString(PChar(Format('64 Bit DLL %s NOT Found!', [Dll])));
end;

exports
  InitWizard name WizardEntryPoint;

begin
end.
