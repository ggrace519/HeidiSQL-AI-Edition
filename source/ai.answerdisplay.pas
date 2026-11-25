unit ai.answerdisplay;

// Formats a model answer for the plain-text transcript of the assistant panel. No LCL
// dependencies.

{$mode delphi}{$H+}

interface

// Answer without its Markdown code fence lines ("```sql", "```"): the transcript is plain
// text, where the fences are noise. The code inside a fence is kept, set apart from the
// text around it by one blank line. Fences pair up like in ExtractSqlBlocks: a fence closes
// with a run of at least as many backticks as opened it, and an unclosed fence (an answer
// still streaming) runs to the end.
function AnswerForDisplay(const Answer: String): String;

implementation

uses
  SysUtils, ai.text;

function AnswerForDisplay(const Answer: String): String;
var
  Lines, Output: TStringArray;
  Line, Trimmed: String;
  Run, OpenRun: Integer;
  PendingBlank: Boolean;
begin
  Output := nil;
  OpenRun := 0;
  PendingBlank := False;
  Lines := SplitLines(Answer);
  for Line in Lines do begin
    Trimmed := Line.Trim;
    Run := BacktickRun(Trimmed);
    if ((OpenRun = 0) and (Run >= 3)) or ((OpenRun > 0) and (Run >= OpenRun)) then begin
      if OpenRun = 0 then
        OpenRun := Run
      else
        OpenRun := 0;
      PendingBlank := True;
      Continue;
    end;
    if PendingBlank and (Trimmed <> '') and (Length(Output) > 0)
      and (Output[High(Output)].Trim <> '') then begin
      SetLength(Output, Length(Output) + 1);
      Output[High(Output)] := '';
    end;
    PendingBlank := False;
    SetLength(Output, Length(Output) + 1);
    Output[High(Output)] := Line;
  end;
  Result := String.Join(sLineBreak, Output);
end;

end.
