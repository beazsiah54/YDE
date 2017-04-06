unit functions;

interface

uses
    SysUtils, Variants, Classes,StdCtrls,StrUtils,Forms,Dialogs,ExtActns;
//procedure MakeLang(str:string);
function LearnPercentofVideo(str:String;lastpercent:integer):Integer;
function ExtractTextBetween(const Input, Delim1, Delim2: string): string;
function findPosOfUserFromParams(str:string):string;
function TryDownloadFile(const AURL, AFileName: string): Boolean;
function CheckVersion(Nowstr:String;Comingstr:String):Boolean;
function GetByte(str: String): string;
function GetResolution(str: String): String;
function Get3String(str:string):string;
implementation

//procedure MakeLang(str:string);

function Get3String(str:string):string;
begin
	result:=trim(copy(str,1,3));
end;

function GetResolution(str: String): String;
begin
  Result:=trim(Copy(str,20,13));
end;

function GetByte(str: String): string;
var
   indexdot:integer;
   i:integer;
   resultstr:String;
begin
    for i:=0 to Length(str)-1 do
    begin
         if str[i]=',' then
         begin
            indexdot:=i;
         end;
    end;
    //ShowMessage(IntToStr(indexdot));
    result:=Copy(str,indexdot+1,Length(str)-indexdot);
end;


function CheckVersion(Nowstr:String;Comingstr:String):Boolean;
begin
  if Nowstr=Comingstr then
    Result:=true
  else
    Result:=False;
end;
function TryDownloadFile(const AURL, AFileName: string): Boolean;
begin
  Result := False;
  with TDownLoadURL.Create(nil) do
  try
    URL := AURL;
    Filename := AFileName;
    try
      ExecuteTarget(nil);
      Result := True;
    except
      ; //please, improve this handling specific exceptions
    end;
  finally
    Free;
  end;
end;
function findPosOfUserFromParams(str:string):string;
var
 i,pos:Integer;
 cstr:String;
begin
 pos:=AnsiPos('-p',str);
 if pos=0 then
 begin
  Result:=str;
 end else
 begin
  cstr:=copy(str,pos+3,length(str));
    for i:=1 to length(cstr)-1 do
    begin
      //ShowMessage(cstr[i]);
      if cstr[i]=' ' then
      begin
        //ShowMessage(inttostr(i));
        //ShowMessage(cstr);
        cstr:=copy(cstr,1,i-1);
        //ShowMessage(cstr);
        break;
      end;
    end;

 end;
 cstr:= StringReplace(str, cstr, '***secret pass***',
                          [rfReplaceAll, rfIgnoreCase]);
 Result:=cstr;
end;

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
