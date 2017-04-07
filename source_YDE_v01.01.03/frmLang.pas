{
ftp klas�r�ne rar i�inde exe-> bak yaparak att�m
ayn� klas�re v2.00.00.txt att�m
e�er gelen versiyon �u anki versiyondan farkl� ise guncelle fonksyionu calisyor.
}

unit frmLang;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,inifiles,Menus, ComCtrls, Gauges, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdFTP,IdFTPCommon,DOSPipes,syncobjs;

type
  TfrmLanguage = class(TForm)
    StatusBar1: TStatusBar;
    IdFTP: TIdFTP;
    Gauge1: TGauge;
    btnUpdateProgram: TButton;
    GroupBox1: TGroupBox;
    edthost: TEdit;
    edtuser: TEdit;
    edtpass: TEdit;
    btnftpkaydet: TButton;
    edtfolder: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure IdFTPStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: String);
    procedure IdFTPWork(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
    procedure IdFTPWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCountMax: Integer);
    procedure IdFTPWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
    procedure btnUpdateProgramClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnUpdateProgramKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    //procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure langturkish;
    function FTPDosyaAl( IdFTP : TIdFTP; SrcDosya, DesDosya:TFileName; Ftp, RemoteDir, Login, Pass : String ):Boolean;
    procedure Guncelle();
    function IsthereanyUpdate():Boolean;
  end;

var
  frmLanguage: TfrmLanguage;
  LangIniFile:TIniFile;
  IniFile : TIniFile;
  version : TIniFile;
  xDosyaUzunluk : LongInt;
  FTPAdres,
  KaynakDizin,
  Pass,
  KaynakDosya,
  KaynakDosyam,
  HedefDosya      : String;
  mychar:Char;
  Namemail:String;
  gelenstr:String;
implementation

{$R *.dfm}
uses main;
procedure TfrmLanguage.FormCreate(Sender: TObject);
var
  i: Integer;
begin
    GroupBox1.Visible:=false;
    //ShowMessage(Application.ExeName);
    LangIniFile := Tinifile.Create(ExtractFilePath(Application.ExeName)+'YDElang.ini') ;
    IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini')) ;
    versionini := Tinifile.Create(ExtractFilePath(Application.ExeName)+'update.ini') ;
    FTPAdres    := edthost.Text;
    KaynakDizin := edtfolder.Text;
    Namemail    := edtuser.Text;
    Pass        := edtpass.Text;
    //StatusBar1.SimpleText:=

  If FileExists(ExtractFilePath(Application.Exename) +'Guncelle.BAT')
    then DeleteFile(ExtractFilePath(Application.Exename) +'Guncelle.BAT');
end;

function TfrmLanguage.FTPDosyaAl(IdFTP: TIdFTP; SrcDosya,
  DesDosya: TFileName; Ftp, RemoteDir, Login, Pass: String): Boolean;
begin
   Result := False;
  //IdFtp.Host     := Ftp;
  //IdFtp.Username := Login;
  //IdFtp.Password := Pass;
   //IdFtp.Passive  := True;
  //IdFTP.Port:=21;
  //IdFtp.Connect;
  //If IdFtp.Connected then
  //begin

    //IdFtp.ChangeDir(RemoteDir);

    // Gauge'de kullanmak i�in
    // Dosya Uzunlu�unu grlobal bir de�i�kene at�yoruz...
    xDosyaUzunluk := IdFtp.Size( SrcDosya );
    Try
      IdFtp.TransferType := ftBinary; // Uses IdFTPCommon
      IdFtp.Get(SrcDosya, DesDosya, True);
    Finally
      Result := True;
    end;
    IdFtp.Quit;
  //end;
end;

procedure TfrmLanguage.Guncelle;
begin
  KaynakDosya := ExtractFileName(Application.Exename);
  //KaynakDosya:=  ChangeFileExt( ExtractFilePath(Application.Exename)+ KaynakDosyam, '.rar' );
  KaynakDosya:=  ChangeFileExt(KaynakDosya, '.rar' );
  HedefDosya  := ChangeFileExt( ExtractFilePath(Application.Exename) + ExtractFileName(Application.Exename), '.rar' );
  //HedefDosya  := ChangeFileExt( ExtractFilePath(Application.Exename) + KaynakDosya, '.BAK' );

  If FileExists(HedefDosya) AND ( MessageDlg('Hedef Dosya Mevcut, �zerine yaz�ls�n m� ? '+#13'('+HedefDosya+')', mtInformation, [mbYes, mbCancel], 0) = mrCancel )
   then EXIT
   else DeleteFile(HedefDosya);

  If FTPDosyaAl( IdFtp, KaynakDosya, HedefDosya, FTPAdres, KaynakDizin, Namemail, Pass) then
      MessageDlg('Dosya Ba�ar�yla Al�nd�'+#13#13
                  + '�imdi program yeniden ba�lat�lmak �zere kapat�lacakt�r....',
                  mtConfirmation, [mbOk], 0)
    else MessageDlg('Dosya Al�namad�'+#13'('+KaynakDosya+')', mtError, [mbok], 0);

  With TStringList.Create do begin
    Add('@Echo Off' );
    Add('DEL '+ChangeFileExt(Application.ExeName,'.BAK'));
    Add('dir /s /b *.rar > allzips.txt');
    Add('for /F %%x in (allzips.txt) do (zip\7z x -trar "%%x")');
    Add('timeout /t 2');
    Add( Format('xcopy /y %s %s', [ChangeFileExt(Application.ExeName,'.bak'), Application.ExeName]) );
    Add('DEL '+ChangeFileExt(Application.ExeName,'.BAK'));
    Add( Application.ExeName );
    //Add('timeout /t -1');
    SaveToFile( ExtractFilePath(Application.Exename)+'Guncelle.BAT' );
    Free;
  end;
  IniFile.WriteString('Settings','version',gelenstr);
  IdFTP.Disconnect;
  Application.Terminate;

  WinExec( PChar( ExtractFilePath(Application.Exename)+'Guncelle.BAT'), SW_SHOWNORMAL );

end;

procedure TfrmLanguage.langturkish;
var
  I:Integer;
  str:String;
begin

  with frmMain do
  begin
    for I := ComponentCount -1 downto 0 do
    begin
      if Components[i] is TLabel then // Check if it is.
      begin
        TLabel(Components[i]).Caption:=LangIniFile.ReadString('lang_tr',Components[i].Name,'');
        //Memo1.Lines.Add(Components[i].Name) ;
      end else if  Components[i] is TGroupBox then
      begin
        TGroupBox(Components[i]).Caption:=LangIniFile.ReadString('lang_tr',Components[i].Name,'');
        //Memo1.Lines.Add(Components[i].Name) ;
      end else if  Components[i] is TRadioButton then
      begin
         //Memo1.Lines.Add(TRadioButton(Components[i]).Hint) ;
         TRadioButton(Components[i]).Caption:=LangIniFile.ReadString('lang_tr',Components[i].Name,'');
      end else if  Components[i] is TMenuItem then
      begin
        //str:=Components[i].Name;
        //ShowMessage(Components[i].Name);
       // Memo1.Lines.Add('ss')
         //Memo1.Lines.Add(str) ;
         TMenuItem(Components[i]).Caption:=LangIniFile.ReadString('lang_tr',Components[i].Name,'');
      end else if   Components[i] is TButton then
      begin
         TButton(Components[i]).Caption:=LangIniFile.ReadString('lang_tr',Components[i].Name,'');
         TButton(Components[i]).Hint:=LangIniFile.ReadString('lang_tr',Components[i].Name+'Hint','');
         //Memo1.Lines.Add(TButton(Components[i]).Hint) ;
      end else if   Components[i] is TCheckBox then
      begin
         TCheckBox(Components[i]).Caption:=LangIniFile.ReadString('lang_tr',Components[i].Name,'');
         TCheckBox(Components[i]).Hint:=LangIniFile.ReadString('lang_tr',Components[i].Name+'Hint','');
      end else if Components[i] is TEdit then
      begin
         //Memo1.Lines.Add(Components[i].Name) ;
         Tedit(Components[i]).Hint:=LangIniFile.ReadString('lang_tr',Components[i].Name+'Hint','');
      end;

    end;
  end;
 end;
procedure TfrmLanguage.IdFTPStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
StatusBar1.SimpleText := AStatusText;
end;

procedure TfrmLanguage.IdFTPWork(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
begin
  Gauge1.Progress := AWorkCount;
  Application.ProcessMessages;
end;

procedure TfrmLanguage.IdFTPWorkBegin(Sender: TObject;
  AWorkMode: TWorkMode; const AWorkCountMax: Integer);
begin
  Gauge1.MinValue := 0;
  Gauge1.MaxValue := xDosyaUzunluk;
  Gauge1.Progress := 0;
  Gauge1.Visible  := True;
end;

procedure TfrmLanguage.IdFTPWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin
  Gauge1.Progress := 0;
  Gauge1.Visible  := true;
end;

procedure TfrmLanguage.btnUpdateProgramClick(Sender: TObject);
var
abc:TStringList;
i:integer;
gelenversiyon:String;
begin
  abc:=TStringlist.Create;
  IdFtp.Host     := FTPAdres;
  IdFtp.Username := Namemail;
  IdFtp.Password := Pass;
  IdFtp.Passive  := True;
  IdFTP.Port:=21;
  IdFtp.Connect;
  If IdFtp.Connected then
  begin
    IdFtp.ChangeDir(edtfolder.Text);
    IdFTP.List(abc,'*.txt',true);
  end;

  gelenstr:=abc[0];
  gelenstr:=trim(copy(gelenstr,length(gelenstr)-12,9));
  versionini.WriteString('Settings','version',gelenstr);
  //ShowMessage(gelenstr);
  //ShowMessage(copy(frmMain.StatusBar1.SimpleText,5,8));
  gelenversiyon :=copy(frmMain.StatusBar1.SimpleText,5,8);
  if gelenversiyon<>gelenstr then
  begin
    guncelle;
  end else begin
    ShowMessage('Zaten g�ncel versiyon kullan�yorsunuz');
    IdFTP.Disconnect;
  end;

end;

procedure TfrmLanguage.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 84) and (Shift = [ssCtrl]) then
    GroupBox1.Visible:=true;
end;

procedure TfrmLanguage.btnUpdateProgramKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
FormKeyUp(self,Key,Shift);
end;

function TfrmLanguage.IsthereanyUpdate: Boolean;
var
abc:TStringList;
i:integer;
gelenversiyon:String;
begin
  abc:=TStringlist.Create;
  IdFtp.Host     := FTPAdres;
  IdFtp.Username := Namemail;
  IdFtp.Password := Pass;
  IdFtp.Passive  := True;
  IdFTP.Port:=21;
  IdFtp.Connect;
  If IdFtp.Connected then
  begin
    IdFtp.ChangeDir(edtfolder.Text);
    IdFTP.List(abc,'*.txt',true);
  end;

  gelenstr:=abc[0];
  gelenstr:=trim(copy(gelenstr,length(gelenstr)-12,9));
  versionini.WriteString('Settings','version',gelenstr);
  //ShowMessage(gelenstr);
  //ShowMessage(copy(frmMain.StatusBar1.SimpleText,5,8));
  gelenversiyon :=copy(frmMain.StatusBar1.SimpleText,5,8);
  if gelenversiyon<>gelenstr then
  begin
    ShowMessage('Please Check Update');
    IdFTP.Disconnect;
  end;

end;

end.
