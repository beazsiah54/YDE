unit functions;

interface

uses
    SysUtils, Variants, Classes,StdCtrls,StrUtils ;


function LearnPercentofVideo(str:String;lastpercent:integer):Integer;
function ExtractTextBetween(const Input, Delim1, Delim2: string): string;

implementation

function LearnPercentofVideo(str:String;lastpercent:integer):Integer;
var
  temp:String;
  itemp:integer;
  test:integer;
begin
  try
    temp:=ExtractTextBetween(str,'[download]','% of');
    temp:=trim(temp);
    //itemp:=StrToFloatDef(temp,lastpercent);
    Val(temp,itemp,test);
    Result:=round(itemp);
  except
    Result:=lastpercent;
  end;
end;

function ExtractTextBetween(const Input, Delim1, Delim2: string): string;
var
  aPos, bPos: Integer;
begin
  result := '';
  aPos := Pos(Delim1, Input);
  if aPos > 0 then begin
    bPos := PosEx(Delim2, Input, aPos + Length(Delim1));
    if bPos > 0 then begin
      result := Copy(Input, aPos + Length(Delim1), bPos - (aPos + Length(Delim1)));
    end;
  end;
end;

end.