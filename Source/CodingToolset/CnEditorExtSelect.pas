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

unit CnEditorExtSelect;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��㼶����ѡ��ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7 SP2 + Delphi 5.01
* ���ݲ��ԣ�PWin7 + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.04.29 V1.1
*               ���Ʋ��� Pascal ����Ĺ���
*           2021.10.06 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IniFiles, Menus, ToolsAPI,
  CnWizUtils, CnConsts, CnCommon, CnWizManager, CnWizEditFiler,
  CnCodingToolsetWizard, CnWizConsts, CnSelectionCodeTool, CnWizIdeUtils,
  CnSourceHighlight, CnPasCodeParser, CnEditControlWrapper, mPasLex,
  CnCppCodeParser, mwBCBTokenList;

type
  TCnEditorExtendingSelect = class(TCnBaseCodingToolset)
  private
    FEditPos: TOTAEditPos;
    FSelectStep: Integer;
    FTimer: TTimer;
    FNeedReparse: Boolean;
    FSelecting: Boolean;
    FStartPos, FEndPos: TOTACharPos;
    procedure FixPair(APair: TCnBlockLinePair);
    procedure CheckModifiedAndReparse;
    procedure EditorChanged(Editor: TCnEditorObject; ChangeType:
      TCnEditorChangeTypes);
    procedure OnSelectTimer(Sender: TObject);
  protected
    function GetDefShortCut: TShortCut; override;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;

    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
  end;

implementation

uses
  CnIDEStrings {$IFDEF DEBUG}, CnDebug {$ENDIF};

{ TCnEditorExtendingSelect }

procedure TCnEditorExtendingSelect.FixPair(APair: TCnBlockLinePair);
begin
  if APair.MiddleCount > 0 then
  begin
    if APair.EndToken.TokenID in [tkElse, tkExcept, tkFinally, tkCase] then
    begin
      APair.EndToken := APair.MiddleToken[APair.MiddleCount - 1];
      APair.DeleteMidToken(APair.MiddleCount - 1);
    end;
  end;
end;

procedure TCnEditorExtendingSelect.CheckModifiedAndReparse;
const
  NO_LAYER = -2;
var
  EditView: IOTAEditView;
  EditControl: TControl;
  CurrIndex, I, J, InnerIdx, PairLevel, Step: Integer;
  PasParser: TCnGeneralPasStructParser;
  CppParser: TCnGeneralCppStructParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  CurrentToken, T1, T2: TCnGeneralPasToken;
  CurrentTokenName: TCnIdeTokenString;
  CurIsPas, CurIsCpp, BeginEndFound, AreaFound, CursorInPair: Boolean;
  CurrentTokenIndex: Integer;
  BlockMatchInfo: TCnBlockMatchInfo;
  MaxInnerLayer, MinOutLayer: Integer;
  Pair, TmpPair, InnerPair: TCnBlockLinePair;
  LastS: string;

  // �ж�һ�� Pair �Ƿ�����˹��λ�ã��ؼ���Ҳ������ȥ�ˣ�������
  function EditPosInPairClose(AEditPos: TOTAEditPos; APairStart, APairEnd: TCnGeneralPasToken): Boolean;
  var
    AfterStart, BeforeEnd: Boolean;
  begin
    AfterStart := (AEditPos.Line > APairStart.EditLine) or
      ((AEditPos.Line = APairStart.EditLine) and (AEditPos.Col >= APairStart.EditCol));
    BeforeEnd := (AEditPos.Line < APairEnd.EditLine) or
      ((AEditPos.Line = APairEnd.EditLine) and (AEditPos.Col <= APairEnd.EditEndCol));

    Result := AfterStart and BeforeEnd;
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('EditPosInPairClose Step %d. Is %d %d in Open %d %d to %d %d? %d',
//      [Step, AEditPos.Line, AEditPos.Col, APairStart.EditLine, APairStart.EditCol,
//      APairEnd.EditLine, APairEnd.EditEndCol, Ord(Result)]);
{$ENDIF}
  end;

  // �ж�һ�� Pair �Ƿ�����˹��λ�ã�������ͷβ�ؼ��֣������䣨ע��ͷ�ؼ��ֺ�β�ؼ���ǰ�����������
  function EditPosInPairOpen(AEditPos: TOTAEditPos; APairStart, APairEnd: TCnGeneralPasToken): Boolean;
  var
    AfterStart, BeforeEnd: Boolean;
  begin
    AfterStart := (AEditPos.Line > APairStart.EditLine) or
      ((AEditPos.Line = APairStart.EditLine) and (AEditPos.Col >= APairStart.EditEndCol));
    BeforeEnd := (AEditPos.Line < APairEnd.EditLine) or
      ((AEditPos.Line = APairEnd.EditLine) and (AEditPos.Col <= APairEnd.EditCol));

    Result := AfterStart and BeforeEnd;
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('EditPosInPairOpen Step %d. Is %d %d in Open %d %d to %d %d? %d',
//      [Step, AEditPos.Line, AEditPos.Col, APairStart.EditLine, APairStart.EditEndCol,
//      APairEnd.EditLine, APairEnd.EditCol, Ord(Result)]);
{$ENDIF}
  end;

  procedure SetStartEndPos(StartToken, EndToken: TCnGeneralPasToken; Open: Boolean);
  begin
    if Open then
    begin
      FStartPos.Line := StartToken.EditLine;
      FStartPos.CharIndex := StartToken.EditEndCol;
      FEndPos.Line := EndToken.EditLine;
      FEndPos.CharIndex := EndToken.EditCol;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Success! Open at Step %d. %s ... %s', [Step, StartToken.Token, EndToken.Token]);
{$ENDIF}
    end
    else
    begin
      FStartPos.Line := StartToken.EditLine;
      FStartPos.CharIndex := StartToken.EditCol;
      FEndPos.Line := EndToken.EditLine;
      FEndPos.CharIndex := EndToken.EditEndCol;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Success! Close at Step %d at %s ... %s', [Step, StartToken.Token, EndToken.Token]);
{$ENDIF}
    end;
    AreaFound := True;
  end;

  // �õ�һ�� Pair �󣬲��� Step �Ը��ֿ��������ѣ�
  // �ڲ�ʹ�� Step ������FLevel �Ƚϡ�AreaFound ����Ƿ��ҵ����ⲿ����
  procedure SearchInAPair(APair: TCnBlockLinePair);
  var
    I: Integer;
  begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Search A Pair with MiddleCount %d. Step Start From %d to Meet Dest Step %d',
//      [APair.MiddleCount, Step, FSelectStep]);
{$ENDIF}
    if APair.MiddleCount = 0 then
    begin
      // ��ͨ Pair����ͷβ�����䣬Step + 1���ж�
      if EditPosInPairOpen(FEditPos, APair.StartToken, APair.EndToken) then
      begin
        Inc(Step);
        if Step = FSelectStep then
        begin
          SetStartEndPos(APair.StartToken, APair.EndToken, True);
          Exit;
        end;
      end;

      // ��ͨ Pair����ͷβ�����䣬Step + 1�� �ж�
      if EditPosInPairClose(FEditPos, APair.StartToken, APair.EndToken) then
      begin
        Inc(Step);
        if Step = FSelectStep then
        begin
          SetStartEndPos(APair.StartToken, APair.EndToken, False);
          Exit;
        end;
      end;
    end
    else
    begin
      // ��ṹ Pair��������ͷβ�Ŀ��������䣬Step + 1���ж�
      for I := 0 to APair.MiddleCount - 1 do
      begin
        if I = 0 then
        begin
          // ��һ���м䣬��ʼ�͵�һ���м�Ŀ������ж�
          if EditPosInPairOpen(FEditPos, APair.StartToken, APair.MiddleToken[I]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.StartToken, APair.MiddleToken[I], True);
              Exit;
            end;
          end;

          // ��һ���м䣬��ʼ�͵�һ���м�ı������ж�
          if EditPosInPairClose(FEditPos, APair.StartToken, APair.MiddleToken[I]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.StartToken, APair.MiddleToken[I], False);
              Exit;
            end;
          end;
        end;

        if I = APair.MiddleCount - 1 then // ע�ⲻ�� else if
        begin
          // ���һ���м䣬���һ���м�ͽ�β�Ŀ������ж�
          if EditPosInPairOpen(FEditPos, APair.MiddleToken[I], APair.EndToken) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.EndToken, True);
              Exit;
            end;
          end;

          // ���һ���м䣬���һ���м�ͽ�β�ı������ж�
          if EditPosInPairClose(FEditPos, APair.MiddleToken[I], APair.EndToken) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.EndToken, False);
              Exit;
            end;
          end;
        end;

        if (APair.MiddleCount > 1) and (I < APair.MiddleCount - 1) then
        begin
          // ĳ�м��Һ������м䣬���м����һ���м�Ŀ������ж�
          if EditPosInPairOpen(FEditPos, APair.MiddleToken[I], APair.MiddleToken[I + 1]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.MiddleToken[I + 1], True);
              Exit;
            end;
          end;

          // ĳ�м��Һ������м䣬���һ���м�ͽ�β�ı������ж�
          if EditPosInPairClose(FEditPos, APair.MiddleToken[I], APair.MiddleToken[I + 1]) then
          begin
            Inc(Step);
            if Step = FSelectStep then
            begin
              SetStartEndPos(APair.MiddleToken[I], APair.MiddleToken[I + 1], False);
              Exit;
            end;
          end;
        end;
      end;

      // ���û�ҵ������Ҷ�ṹ Pair ������ͷβ
      if not AreaFound then
      begin
        // ͷ�ͽ�β�Ŀ����䣬Step + 1���ж�
        if EditPosInPairOpen(FEditPos, APair.StartToken, APair.EndToken) then
        begin
          Inc(Step);
          if Step = FSelectStep then
          begin
            SetStartEndPos(APair.StartToken, APair.EndToken, True);
            Exit;
          end;
        end;

        // ͷ�ͽ�β�ı����䣬Step + 1���ж�
        if EditPosInPairClose(FEditPos, APair.StartToken, APair.EndToken) then
        begin
          Inc(Step);
          if Step = FSelectStep then
          begin
            SetStartEndPos(APair.StartToken, APair.EndToken, False);
            Exit;
          end;
        end;
      end;
    end;
  end;

begin
  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;
  try
    EditView := EditControlWrapper.GetEditView(EditControl);
  except
    Exit;
  end;

  if EditView = nil then
    Exit;

  CurIsPas := IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName);
  CurIsCpp := IsCppSourceModule(EditView.Buffer.FileName);
  if (not CurIsCpp) and (not CurIsPas) then
    Exit;

  // ����
  PasParser := nil;
  CppParser := nil;
  BlockMatchInfo := nil;

  try
    if CurIsPas then
    begin
      PasParser := TCnGeneralPasStructParser.Create;
  {$IFDEF BDS}
      PasParser.UseTabKey := True;
      PasParser.TabWidth := EditControlWrapper.GetTabWidth;
  {$ENDIF}
    end;

    if CurIsCpp then
    begin
      CppParser := TCnGeneralCppStructParser.Create;
  {$IFDEF BDS}
      CppParser.UseTabKey := True;
      CppParser.TabWidth := EditControlWrapper.GetTabWidth;
  {$ENDIF}
    end;

    Stream := TMemoryStream.Create;
    try
      CnGeneralSaveEditorToStream(EditView.Buffer, Stream);

      // ������ǰ��ʾ��Դ�ļ�
      if CurIsPas then
        CnPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName)
          or IsInc(EditView.Buffer.FileName), False);
      if CurIsCpp then
        CnCppParserParseSource(CppParser, Stream, EditView.CursorPos.Line, EditView.CursorPos.Col);
    finally
      Stream.Free;
    end;

    if CurIsPas then
    begin
      // �������ٲ��ҵ�ǰ������ڵĿ飬��ֱ��ʹ�� CursorPos����Ϊ Parser ����ƫ�ƿ��ܲ�ͬ
      CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
      PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
    end;

    BlockMatchInfo := TCnBlockMatchInfo.Create(EditControl);
    BlockMatchInfo.LineInfo := TCnBlockLineInfo.Create(EditControl);

    // �����õ� Token ���� BlockMatchInfo ��
    for I := 0 to PasParser.Count - 1 do
    begin
      if PasParser.Tokens[I].TokenID in csKeyTokens + [tkProcedure, tkFunction, tkOperator, tkSemiColon] then
        BlockMatchInfo.AddToKeyList(PasParser.Tokens[I]);
    end;

    // ת��һ��
    for I := 0 to BlockMatchInfo.KeyCount - 1 do
      ConvertGeneralTokenPos(Pointer(EditView), BlockMatchInfo.KeyTokens[I]);

    // �����ԣ����ɶ�� Pair��ע������� Procedure ��Ϊ Pair
    BlockMatchInfo.IsCppSource := CurIsCpp;
    BlockMatchInfo.CheckLineMatch(EditView, False, False, True);

    // BlockMatchInfo ������� LineInfo �ڵ����ݣ����ɶ�� Pair

    // ȥ��ÿ�� Pair β������������ݱ��� else
    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
      FixPair(BlockMatchInfo.LineInfo.Pairs[I]);
    BlockMatchInfo.LineInfo.SortPairs;

{$IFDEF DEBUG}
//    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
//    begin
//      Pair := BlockMatchInfo.LineInfo.Pairs[I];
//      CnDebugger.LogFmt('Dump Pairs: #%d From %d %d ~ %d %d, ^%d %s ~ %s', [I,
//        Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.EndToken.EditLine,
//        Pair.StartToken.EditCol, Pair.Layer, Pair.StartToken.Token, Pair.EndToken.Token]);
//    end;
{$ENDIF}

    FStartPos.Line := -1;
    FEndPos.Line := -1;
    MaxInnerLayer := NO_LAYER; // -2 ������
    MinOutLayer := MaxInt;

    // ֻ���ڳ�ʼ�����ȼ�ʱ�ż�¼��겢��Ϊ������ʼ��꣬�Լ���չѡ��������ɵĹ���ƶ�����
    if (FSelectStep <= 1) or ((FEditPos.Line = -1) and (FEditPos.Col = -1)) then
      FEditPos := EditView.CursorPos;

    // �õ�������� Pair �������
    InnerPair := nil;
    InnerIdx := -1;
    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
    begin
      // ���ҿ���λ�õ����ڲ�Ҳ���� Layer ���� Pair
      Pair := BlockMatchInfo.LineInfo.Pairs[I];
      if EditPosInPairClose(FEditPos, Pair.StartToken, Pair.EndToken) then
      begin
        if Pair.Layer > MaxInnerLayer then
        begin
          MaxInnerLayer := Pair.Layer;
          InnerPair := Pair;
          InnerIdx := I;
        end;
        if Pair.Layer < MinOutLayer then
          MinOutLayer := Pair.Layer;
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('CheckModifiedAndReparse Get Layer from %d to %d.', [MinOutLayer, MaxInnerLayer]);
{$ENDIF}

    if (MaxInnerLayer = NO_LAYER) or (MinOutLayer = MaxInt) then
      Exit;

    // ����������ε������ʺ� FLevel �ģ��������н���������ÿ�� Layer ֻ���� 1
    Step := 0;

    // TODO: ����С���š�������ѡ�������Ƿ��� InnerPair �ڣ�������� Step ���� FLevel �Ƚ��ж�

    // �� InnerPair �Ĺ�����ڿ����䵽������ڱ����䣬��� InnerPair �Ƕ�ṹ�������һ��������������
    AreaFound := False;
    if InnerPair <> nil then
    begin
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('To Search Current Inner Pair %d %d to %d %d with Level %d',
//        [InnerPair.StartToken.EditLine, InnerPair.StartToken.EditCol,
//        InnerPair.EndToken.EditLine, InnerPair.StartToken.EditCol, InnerPair.Layer]);
{$ENDIF}
      SearchInAPair(InnerPair);

      if not AreaFound then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('InnerPair Search Complete. To Search Other Pairs');
{$ENDIF}
        PairLevel := InnerPair.Layer;
        while PairLevel >= 0 do
        begin
{$IFDEF DEBUG}
//          CnDebugger.LogMsg('In Loop To Find Another Pair with Level ' + IntToStr(PairLevel));
{$ENDIF}
          for I := InnerIdx downto 0 do
          begin
            // ÿ��һ�� Pair���ҿ����䣬Step + 1���жϣ����ұ����䣬Step + 1���ж�
            // ���жϸ� Pair �Ƿ���ͬ���� procedure/function����������� Step + 1���ж�
            // �ٽ���һ���ظ�����ѭ����ע����ʼ����������Ѿ��ѹ��� InnerPair

            Pair := BlockMatchInfo.LineInfo.Pairs[I];
            CursorInPair := False;
{$IFDEF DEBUG}
//            CnDebugger.LogFmt('To Check Pair with Level %d. Is %d %d in From %d %d %s to %d %d %s',
//              [Pair.Layer, FEditPos.Line, FEditPos.Col,
//              Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.StartToken.Token,
//              Pair.EndToken.EditLine, Pair.EndToken.EditEndCol, Pair.EndToken.Token]);
{$ENDIF}
            if (Pair <> InnerPair) and EditPosInPairClose(FEditPos, Pair.StartToken, Pair.EndToken) then
            begin
              // �����Ѿ��ѹ��� InnerPair
              CursorInPair := True;
              if Pair.Layer = PairLevel then
              begin
{$IFDEF DEBUG}
//                CnDebugger.LogFmt('Level Match In Pair %d %d to %d %d. To Search in this Pair with Level %d',
//                  [Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.EndToken.EditLine, Pair.EndToken.EditCol, Pair.Layer]);
{$ENDIF}
                SearchInAPair(Pair);
              end;
            end;
            if Pair = InnerPair then // �Ѿ��ѹ��� InnerPair������Ȼ�ڴ� Pair ��
              CursorInPair := True;

            // �����ǲ����ѹ��� InnerPair��ֻҪ���Ƿ��ϼ���� begin/end���Ұ������λ�ã���Ҫ����ͬ���� if ��
            if not AreaFound and CursorInPair and (Pair.Layer = PairLevel) and (Pair.MiddleCount = 0) and
              (Pair.StartToken.TokenID = tkBegin) and (Pair.EndToken.TokenID = tkEnd) then
            begin
{$IFDEF DEBUG}
              CnDebugger.LogMsg('Not Found in This Pair. Check other Pairs with Same Level ' + IntToStr(Pair.Layer));
{$ENDIF}
              // �����޺� Pair ��� begin end ͬ���� if/then��while/do��procedure/function���м䲻��������ͬ���� begin end
              for J := I - 1 downto 0 do
              begin
                TmpPair := BlockMatchInfo.LineInfo.Pairs[J];
                if TmpPair.Layer = Pair.Layer then
                begin
                  // ����ͬ���� begin end ��ʾ���漴ʹ�� if ʲô��Ҳ������һ���
                  if (TmpPair.StartToken.TokenID = tkBegin) and (TmpPair.EndToken.TokenID = tkEnd) then
                    Break;

                  if ((TmpPair.StartToken.TokenID = tkIf) and (TmpPair.EndToken.TokenID = tkThen))
                    or ((TmpPair.StartToken.TokenID = tkWhile) and (TmpPair.EndToken.TokenID = tkDo))
                    or ((TmpPair.StartToken.TokenID = tkFor) and (TmpPair.EndToken.TokenID = tkDo))
                    or ((TmpPair.StartToken.TokenID = tkWith) and (TmpPair.EndToken.TokenID = tkDo)) then
                  begin
{$IFDEF DEBUG}
                    CnDebugger.LogMsg('Get Same Level ' + IntToStr(Pair.Layer) + ' ' + TmpPair.StartToken.Token);
{$ENDIF}
                    Inc(Step);
                    if Step = FSelectStep then
                    begin
                      SetStartEndPos(TmpPair.StartToken, Pair.EndToken, True);
                      Exit;
                    end;
                    Inc(Step);
                    if Step = FSelectStep then
                    begin
                      SetStartEndPos(TmpPair.StartToken, Pair.EndToken, False);
                      Exit;
                    end;
                    Break; // �Ѿ��ҵ���ͬ�� if ����䣬�������� function/procedure ��
                  end;

                  // ������ͬ���������ڵ� function/procedure
                  if (TmpPair.StartToken.TokenID in [tkProcedure, tkFunction, tkOperator])
                    and (TmpPair.EndToken.TokenID in [tkProcedure, tkFunction, tkOperator]) then
                  begin
                    Inc(Step);
                    if Step = FSelectStep then
                    begin
                      // �������̾ͱ����䣬û�п�����
                      SetStartEndPos(TmpPair.StartToken, Pair.EndToken, False);
                      Exit;
                    end;
                    Break;
                  end;
                end;
              end;
            end;
          end;
          Dec(PairLevel); // �Ƿ��ڱ��㣿
        end;
      end;
    end;

    if not AreaFound then
    begin
      // û�����ڵĲ㣬��ɶ��û�ҵ���ֱ��ȫѡ�����ļ�
      FStartPos.Line := 1;
      FStartPos.CharIndex := 0;
      FEndPos.Line := EditView.Buffer.GetLinesInBuffer;
      LastS := CnOtaGetLineText(FEndPos.Line, EditView.Buffer);
      FEndPos.CharIndex := Length(LastS);
      Exit;
    end;
  finally
    BlockMatchInfo.LineInfo.Free;
    BlockMatchInfo.LineInfo := nil;
    BlockMatchInfo.Free; // LineInfo �� nil ������� Clear ���ܽ���
    PasParser.Free;
    CppParser.Free;
  end;
end;

constructor TCnEditorExtendingSelect.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 500;
  FTimer.OnTimer := OnSelectTimer;
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
end;

destructor TCnEditorExtendingSelect.Destroy;
begin
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  FTimer.Free;
  inherited;
end;

procedure TCnEditorExtendingSelect.EditorChanged(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
begin
  if ChangeType * [ctView, ctModified, ctTopEditorChanged, ctOptionChanged] <> [] then
    FNeedReparse := True;

  if not FSelecting and (ChangeType * [ctBlock] <> []) then
  begin
    FSelectStep := 0;
    FEditPos.Line := -1;
    FEditPos.Col := -1;
  end;
end;

procedure TCnEditorExtendingSelect.Execute;
var
  CurrIndex: Integer;
  EditView: IOTAEditView;
  CurrTokenStr: TCnIdeTokenString;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  // ���������
  // ���û��ѡ��������ѡ��ǰ��ʶ������ Level 1���ޱ�ʶ���Ļ�������ѡ���ڲ㿪���䣬���� Level 2
  // �����ѡ������������������ݵ�ǰ Level ������ 1 ѡ��
  // �㼶����˳����ѡ���� 0������±�ʶ�� 1����һ���У�����ǰ����ڿ����� 2��
  // ��ǰ������䣨Ҳ���������飬�����зֺžͼӸ��ֺţ�3
  // �͵�ǰ��ͬ�������п飨�������������Ļ���4��������ڿ����� 5���Դ�����

  FSelecting := True;
  try
    if (EditView.Block = nil) or not EditView.Block.IsValid then
    begin
      if CnOtaGeneralGetCurrPosToken(CurrTokenStr, CurrIndex) then
      begin
        if CurrTokenStr <> '' then
        begin
          // ������б�ʶ����ѡ��
          CnOtaSelectCurrentToken;
          Exit;
        end;
      end;
    end;

    Inc(FSelectStep);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('EditorExtendingSelect To Select Step %d.', [FSelectStep]);
{$ENDIF}

    CheckModifiedAndReparse;

    // ѡ�� FLevel ��Ӧ����
    if (FStartPos.Line >= 0) and (FEndPos.Line >= 0) then
    begin
      CnOtaMoveAndSelectBlock(FStartPos, FEndPos);
{$IFDEF WIN64}
      EditView.Paint;
{$ENDIF}
    end;
  finally
    FTimer.Enabled := False;
    FTimer.Enabled := True; // �����Ӻ����� FSelecting
  end;
end;

function TCnEditorExtendingSelect.GetCaption: string;
begin
  Result := SCnEditorExtendingSelectMenuCaption;
end;

function TCnEditorExtendingSelect.GetDefShortCut: TShortCut;
begin
  Result := TextToShortCut('Alt+Q');
end;

procedure TCnEditorExtendingSelect.GetToolsetInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorExtendingSelectName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorExtendingSelect.GetHint: string;
begin
  Result := SCnEditorExtendingSelectMenuHint;
end;

procedure TCnEditorExtendingSelect.OnSelectTimer(Sender: TObject);
begin
  FSelecting := False;
end;

initialization
  RegisterCnCodingToolset(TCnEditorExtendingSelect);

end.
