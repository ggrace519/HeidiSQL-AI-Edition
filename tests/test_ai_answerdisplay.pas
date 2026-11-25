unit test_ai_answerdisplay;

{$mode delphi}{$H+}

interface

uses
  SysUtils, fpcunit, testregistry, ai.answerdisplay;

type
  TAnswerDisplayTest = class(TTestCase)
  published
    procedure TextWithoutFenceUnchanged;
    procedure SqlFenceLinesLeftOut;
    procedure ExistingBlankLinesNotDoubled;
    procedure UnclosedFenceWhileStreaming;
    procedure LongerFenceKeepsInnerBackticks;
    procedure IndentedFence;
    procedure TwoBlocks;
    procedure CrLfAnswer;
    procedure EmptyAnswer;
  end;

implementation

function L(const Parts: array of String): String;
begin
  Result := String.Join(sLineBreak, Parts);
end;

procedure TAnswerDisplayTest.TextWithoutFenceUnchanged;
begin
  AssertEquals(L(['Just text.', '', 'Second line.']),
    AnswerForDisplay('Just text.'#10#10'Second line.'));
end;

procedure TAnswerDisplayTest.SqlFenceLinesLeftOut;
begin
  AssertEquals(L(['Try this:', '', 'SELECT 1;', '', 'It returns one row.']),
    AnswerForDisplay('Try this:'#10'```sql'#10'SELECT 1;'#10'```'#10'It returns one row.'));
end;

procedure TAnswerDisplayTest.ExistingBlankLinesNotDoubled;
begin
  AssertEquals(L(['Try this:', '', 'SELECT 1;', '', 'Done.']),
    AnswerForDisplay('Try this:'#10#10'```sql'#10'SELECT 1;'#10'```'#10#10'Done.'));
end;

procedure TAnswerDisplayTest.UnclosedFenceWhileStreaming;
begin
  AssertEquals(L(['Sure:', '', 'SELECT id']),
    AnswerForDisplay('Sure:'#10'```sql'#10'SELECT id'));
end;

procedure TAnswerDisplayTest.LongerFenceKeepsInnerBackticks;
begin
  AssertEquals(L(['```', 'SELECT 1;', '```']),
    AnswerForDisplay('````markdown'#10'```'#10'SELECT 1;'#10'```'#10'````'));
end;

procedure TAnswerDisplayTest.IndentedFence;
begin
  AssertEquals(L(['1. Run:', '', '   SELECT 1;']),
    AnswerForDisplay('1. Run:'#10'   ```sql'#10'   SELECT 1;'#10'   ```'));
end;

procedure TAnswerDisplayTest.TwoBlocks;
begin
  AssertEquals(L(['First:', '', 'SELECT 1;', '', 'Then:', '', 'SELECT 2;']),
    AnswerForDisplay('First:'#10'```sql'#10'SELECT 1;'#10'```'#10'Then:'#10'```'#10'SELECT 2;'#10'```'));
end;

procedure TAnswerDisplayTest.CrLfAnswer;
begin
  AssertEquals(L(['Here:', '', 'SELECT 1;']),
    AnswerForDisplay('Here:'#13#10'```sql'#13#10'SELECT 1;'#13#10'```'));
end;

procedure TAnswerDisplayTest.EmptyAnswer;
begin
  AssertEquals('', AnswerForDisplay(''));
end;

initialization
  RegisterTest(TAnswerDisplayTest);

end.
