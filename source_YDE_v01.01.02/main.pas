unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,DOSPipes,syncobjs, Menus,settings,inifiles,functions,audio,
  ExtCtrls,unitTextEcrypt,Jpeg,frmLang,bug;

type
  TfrmMain = class(TForm)
    RichEdit1: TRichEdit;
    Edit1: TEdit;
    btnStart: TButton;
    MainMenu1: TMainMenu;
    MenuFile: TMenuItem;
    MenuSettings: TMenuItem;
    GroupBoxVideoOrAudio: TGroupBox;
    RadioButtonVideo: TRadioButton;
    RadioButtonAudio: TRadioButton;
    GroupBoxSettings: TGroupBox;
    CheckBoxSub: TCheckBox;
    CheckBoxIgnoreErrors: TCheckBox;
    CheckBoxAbortAnError: TCheckBox;
    CheckBoxForceResume: TCheckBox;
    CheckBoxSimulation: TCheckBox;
    CheckBoxDirectDisk: TCheckBox;
    GroupBox3: TGroupBox;
    edtDownloadRateLimit: TEdit;
    btnLearnFormat: TButton;
    memobug: TMemo;
    btnStop: TButton;
    labelLink: TLabel;
    ProgressBar1: TProgressBar;
    GroupBoxFolder: TGroupBox;
    LabelFolderName: TLabel;
    edtDownloadFolderSecond: TEdit;
    GroupBoxMerge: TGroupBox;
    edtAudioformat: TEdit;
    edtVideoFormat: TEdit;
    LabelAudioformat: TLabel;
    LabelVideoFormat: TLabel;
    CheckBoxMerge: TCheckBox;
    GroupBoxConsole: TGroupBox;
    CheckBoxOnlySub: TCheckBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    Timer1: TTimer;
    CheckBoxKeepVideo: TCheckBox;
    CheckBoxUseUser: TCheckBox;
    GroupBoxYoutubeDLCode: TGroupBox;
    Image1: TImage;
    CheckBoxLang: TCheckBox;
    CheckBoxPlaylist: TCheckBox;
    MenuUpdate: TMenuItem;
    StatusBar1: TStatusBar;
    LabelWarningPlaylist: TLabel;
    btnupdate: TButton;
    Label5: TLabel;
    btnClearAdv: TButton;
    Label6: TLabel;
    RadioGroupOAudio: TRadioGroup;
    RadioGroupVideo: TRadioGroup;
    RadioGroupOVideo: TRadioGroup;
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MenuSettingsClick(Sender: TObject);
    procedure btnLearnFormatClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnMergeClick(Sender: TObject);
    procedure CheckBoxMergeClick(Sender: TObject);
    procedure RadioButtonAudioClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    //procedure btnupdateClick(Sender: TObject);
    procedure MenuLangClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBoxLangClick(Sender: TObject);
    procedure Edit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuUpdateClick(Sender: TObject);
    procedure RadioButtonVideoClick(Sender: TObject);
    procedure btnupdateClick(Sender: TObject);
    procedure btnClearAdvClick(Sender: TObject);
    procedure RadioGroupOAudioClick(Sender: TObject);
    procedure RadioGroupVideoClick(Sender: TObject);
    procedure RadioGroupOVideoClick(Sender: TObject);
    procedure edtDownloadRateLimitKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    Started, Abort: boolean;
    lastStamp: DWord;
    CriticalSection: TCriticalSection;
    procedure ClearRadioButtonofAdvancedMenu;
    function CheckComponentsandControls: String;
  end;

var
  lang:String;
  frmMain: TfrmMain;
  IniFile : TIniFile;
  LangIniFile:TIniFile;
  versionini:TIniFile;
  folderyoutube:string;
  version:string;
  folderffmpeg:string;
  folderdownload:string;
  params,uzanti:string;
  percent:Integer; // for progress bar
  comingversion:String;
  tr:Boolean;
   isupdate:Boolean;
   zaman:integer;
  bbug:boolean;

implementation

{$R *.dfm}
procedure LoopFunc(Output: string; var input: string; var terminate: Boolean; const PI: TProcessInformation; var UserData: DWord);
var
  aForm: TfrmMain;

  Msg,TempMsg: String;
  tt:string;
  Stophandle: THandle;
  tempPercent:Integer;
begin

  aForm := TfrmMain(UserData);
  aForm.CriticalSection.Enter;

  try
    aForm.RichEdit1.Text := Output+aForm.RichEdit1.Text ;
    tempPercent:=LearnPercentofVideo(aForm.RichEdit1.Text,percent);
    percent:=tempPercent;
    aForm.ProgressBar1.Position:=percent;

    if percent=100 then
    begin

    end;

    //tt:=ExtractTextBetween(aForm.RichEdit1.Text,'[download]','%');

    TempMsg:=aForm.RichEdit1.Text;
    if aForm.Abort then
    begin
      if (aForm.lastStamp = 0) then
      begin
        // If anyone know why I get a "handle is invalid" after this call,
        // Please maill me your answer: grobety@fulgan.com
        if not GenerateConsoleCtrlEvent(CTRL_BREAK_EVENT , Stophandle) then
        begin
          Msg := sysErrorMessage(Getlasterror);
          aForm.RichEdit1.DefAttributes.Color := clRed;
          aForm.RichEdit1.Clear;
          aForm.RichEdit1.Lines.Append(Msg);
          aForm.RichEdit1.Lines.Append('TERMINATING PROCESS');
          aForm.RichEdit1.Lines.Append(TempMsg);
          //aForm.RichEdit1.DefAttributes.Color := clBlack;
          Terminate := true;
        end
        else
          aForm.lastStamp := GetTickCount;
      end
      else
      begin
        aForm.RichEdit1.DefAttributes.Color := clRed;
        aForm.RichEdit1.Clear;
        aForm.RichEdit1.Lines.Append(Msg);        
        aForm.RichEdit1.Lines.Append('Timed out waiting for app to terminate');
        aForm.RichEdit1.Lines.Append('TERMINATING PROCESS');
        //aForm.RichEdit1.DefAttributes.Color := clBlack;
        terminate := (GetTickCount - aForm.lastStamp) > 2000;
      end;
    end;
  finally
    aForm.CriticalSection.Leave;
  end;
  Application.ProcessMessages;
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
var
  str:String;
  yol:string;
  resimyolu:string;

begin
    Timer1.Enabled:=true;
    LabelWarningPlaylist.Visible:=false;
    //bir kerelik güncelleme varmý ona bakýlýyor.
    // bunu silmek gerek bir alt satýrý hata geliyor
    isupdate:=true;
    if isupdate=false then begin
     isupdate:=frmLanguage.IsthereanyUpdate;
     isupdate:=True;
    end;
    //////////////////////////////////////////////////


  uzanti:='';
  yol:=trim(Edit1.Text);
  uzanti:=copy(yol,length(yol)-2,3);
  //ShowMessage(uzanti);
  if not(uzanti='txt') then
  begin
  //------------------------------------------------------------
  // burada bilgi geliyor. þarký adi
  Edit1.Text:='';
  Edit1.PasteFromClipboard;
        if CheckBoxPlaylist.Checked=false then
        begin

          params:=folderyoutube+' -e '+Edit1.Text;
          memobug.Lines.Add(params);

          if not Started then
          begin
            Abort := false;
            Started := true;
            lastStamp := 0;
            WatchProcessUntillOver(params+'', '', '', nil, LoopFunc, Cardinal(self), 0);
            Started := false;
          end
          else
          begin
            Abort := true;
          end;

        frmMain.Caption:='  Youtube-DL Extractor --- '+RichEdit1.Lines[0];
        Timer1.Enabled:=true;

        params:=folderyoutube+' --get-thumbnail '+Edit1.Text;
        memobug.Lines.Add(params);

        if not Started then
        begin
          Abort := false;
          Started := true;
          lastStamp := 0;
          WatchProcessUntillOver(params+'', '', '', nil, LoopFunc, Cardinal(self), 0);
          Started := false;
        end
        else
        begin
          Abort := true;
        end;
        //ShowMessage(RichEdit1.Lines.Strings[0]);
        resimyolu := 'b.jpg';
        if  DeleteFile(resimyolu) then
        begin
            if not TryDownloadFile(RichEdit1.Lines.Strings[0],resimyolu) then
            begin
              resimyolu := ExtractFilePath(Application.ExeName) + 'b.jpg';
            end;
            image1.Picture.LoadFromFile(resimyolu);
        end else if not FileExists(resimyolu) then
        begin
          if not TryDownloadFile('https://i.ytimg.com/vi/tuK6n2Lkza0/hqdefault.jpg',resimyolu) then
          begin
            resimyolu := ExtractFilePath(Application.ExeName) + 'b.jpg';
          end;
            image1.Picture.LoadFromFile(resimyolu);
        end;

      end;
  end;
//-------------------------------------------------
percent:=0;
RichEdit1.DefAttributes.Color := clwhite;

  //folderffmpeg:=IniFile.ReadString('Settings','ffmpeg','No Value');
  //folderyoutube:=IniFile.ReadString('Settings','youtube_dl_folder','No Value');
  //folderdownload:=IniFile.ReadString('Settings','downloadfolder','No Value');
  str:=CheckComponentsandControls;

  if uzanti='txt' then
  begin
    params:=str;
  end else begin
    params:=str+' '+Edit1.Text;
  end;


  str:=findPosOfUserFromParams(params);
  memobug.Lines.Clear;
  memobug.Lines.Add(str);
  frmbug.Memo1.Lines.Add(str);
  if not Started then
  begin
    Abort := false;
    Started := true;
    lastStamp := 0;
    WatchProcessUntillOver(params+'', '', '', nil, LoopFunc, Cardinal(self), 0);
    Started := false;
    //Image1.Picture.LoadFromFile('logo.jpg');
  end
  else
  begin
    Abort := true;
  end;
  ProgressBar1.Position:=0;

   ClearRadioButtonofAdvancedMenu ;
   RadioGroupOAudio.Height:=20;
   RadioGroupOVideo.Height:=20;
   RadioGroupVideo.Height:=20;

   bbug:=true;

end;

procedure TfrmMain.FormCreate(Sender: TObject);

begin
  bbug:=false;
  isupdate:=false;
//  LabelPlaylist.Visible:=false;
  Left:=(Screen.Width-Width)  div 5;
  Top:=(Screen.Height-Height) div 2;

  folderyoutube:=ExtractFilePath(ParamStr(0))+'youtube-dl.exe';
  folderffmpeg:=ExtractFilePath(ParamStr(0))+'ffmpeg.exe';
  folderdownload:=  ExtractFilePath(ParamStr(0))+'Download\';

  percent:=0;
  CriticalSection := TCriticalSection.Create;
  IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini')) ;
  version:=IniFile.ReadString('Settings','version','');    // yazýlý version
  StatusBar1.SimpleText:='V : '+version;

  versionini := Tinifile.Create(ExtractFilePath(Application.ExeName)+'update.ini') ;
  lang:=IniFile.ReadString('Settings','lang','');
  if lang='tr' then
    CheckBoxLang.Checked:=true;
  //son update versionu
  comingversion:=versionini.ReadString('Settings','version','');

  if comingversion<>version then
  begin
    ShowMessage('Last Update is Wrong');
  end;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
CriticalSection.free;

end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
Edit1.Text:='';
  if started then
  begin
    Abort := true;
    CanClose := false;
  end;
Timer1.Enabled:=false;
frmMain.Caption:='Youtube-Dl Extractor';
end;

procedure TfrmMain.MenuSettingsClick(Sender: TObject);
var
  frmSettings: TfrmSettings;
begin
  frmSettings:=TfrmSettings.Create(self);
  frmSettings.ShowModal;

end;

function TfrmMain.CheckComponentsandControls: String;
var
  str:String;
  str1:String;
  useer,pass:String;
  audio_user:String;
begin
  //user account aliniyor eger 0 ise user yok
  useer:=frmSettings.edtUser.Text;
  pass:=Base64Decode(frmSettings.edtPassword.Text);
  //--------------------------------------
  str:=folderyoutube;

  if uzanti='txt' then
  begin
    str:=str+' -a ' + trim(Edit1.Text);
  end;

  if edtDownloadRateLimit.Text<>'0' then
    str:=str+' --rate-limit '+edtDownloadRateLimit.Text+' ';

  if CheckBoxSimulation.Checked=true then
    str:=str+' --simulate ';

  if CheckBoxIgnoreErrors.Checked=true then
  begin
    str:=str+' --ignore-errors ';
  end else if CheckBoxAbortAnError.Checked=true then
  begin
    str:=str+' --abort-an-error ';
  end;

  if CheckBoxForceResume.Checked=true then
    str:=str+' --continue ';

  if CheckBoxDirectDisk.Checked=true then
    str:=str+' --no-part ';

  if CheckBoxSub.Checked=true then
  begin
     //str:=str+' --write-auto-sub ';    // --sub-lang LANGS
     if CheckBoxLang.Checked=true then
     begin
          str:=str+' --write-sub  --embed-subs  --sub-lang tr ';
     end;
  end;

  if CheckBoxUseUser.Checked=true then
  begin
      if not (useer='0') then
      begin
        str:=str+' -u '+ useer +' -p '+ pass +' ' ;
        audio_user:=  ' -u '+ useer +' -p '+ pass +' ';
      end;
  end;

  if RadioButtonAudio.Checked=true then
  begin
        if CheckBoxUseUser.Checked=true then
        begin
            if not (useer='0') then
            begin
              if CheckBoxKeepVideo.Checked=true then
              begin
                  if uzanti='txt' then begin
                    str:=folderyoutube+' -a '+trim(Edit1.Text)+audio_user +' --keep --extract-audio --audio-format mp3 ';
                  end else begin
                    str:=folderyoutube+audio_user +' --keep --extract-audio --audio-format mp3 ';
                  end;

              end else begin
                  if uzanti='txt' then begin
                      CheckBoxMerge.Checked:=false;
                      str:=folderyoutube+' -a '+trim(Edit1.Text)+audio_user+' --extract-audio --audio-format mp3 ';
                  end else begin
                      CheckBoxMerge.Checked:=false;
                      str:=folderyoutube+audio_user+' --extract-audio --audio-format mp3 ';
                  end;

              end;
            end;
        end else
        begin
            if CheckBoxKeepVideo.Checked=true then
            begin
              if uzanti='txt' then begin
                  str:=folderyoutube+' -a '+trim(Edit1.Text)+' --keep --extract-audio --audio-format mp3 ';
              end else begin
                  str:=folderyoutube+' --keep --extract-audio --audio-format mp3 ';
              end;

            end else begin
              if uzanti='txt' then begin
                  CheckBoxMerge.Checked:=false;
                  str:=folderyoutube+' -a '+trim(Edit1.Text)+' --extract-audio --audio-format mp3 ';
              end else begin
                CheckBoxMerge.Checked:=false;
                str:=folderyoutube+' --extract-audio --audio-format mp3 ';
              end;
            end;
        end;

  end;

  if CheckBoxMerge.Checked=true then
  begin
    str:=str+' --format '+edtVideoFormat.Text+'+'+edtAudioformat.Text+' --merge-output-format mp4 ';
  end;

  if CheckBoxOnlySub.Checked=true then
  begin
    str:=str+' --all-subs --skip-download ';
  end;

  if length(folderdownload)>0 then    // last if
  begin
    if length(edtDownloadFolderSecond.Text)>0 then
    begin
      str:=str+' -o "'+folderdownload+'\'+edtDownloadFolderSecond.Text+'\%(title)s-%(id)s.%(ext)s" ';
    end else
    begin
      str:=str+' -o "'+folderdownload+'\%(title)s-%(id)s.%(ext)s" ';
    end;
  end else
  begin
    ShowMessage('Destination folder is nil');
    str:='';
  end;

  Result:=str;
end;

procedure TfrmMain.btnLearnFormatClick(Sender: TObject);
var
   i,index:integer;
   TOnlyAudio,TOnlyVideo,TVideo:TStringList;
   subFirst3:String;
   strMemo:String;
begin
    RichEdit1.Clear;
    ClearRadioButtonofAdvancedMenu;

    TOnlyAudio:=TStringList.Create;
    TOnlyAudio.CommaText:=inifile.ReadString('Settings','TAudioOnly','Novalue');
    TOnlyVideo:=TStringList.Create;
    TOnlyVideo.CommaText:=inifile.ReadString('Settings','TVideoOnly','Novalue');
    TVideo:=TStringList.Create;
    TVideo.CommaText:=inifile.ReadString('Settings','TVideo','Novalue');

    params:=folderyoutube+' --console-title -F '+Edit1.Text;
    memobug.Lines.Add(params);
  
  if not Started then
  begin
    Abort := false;
    Started := true;
    lastStamp := 0;
    WatchProcessUntillOver(params, '', '', nil, LoopFunc, Cardinal(self), 0);
    Started := false;
  end
  else
  begin
    Abort := true;
  end;
   RadioGroupOAudio.Height:=20;
   RadioGroupOVideo.Height:=20;
   RadioGroupVideo.Height:=20;
   for i:=0 to RichEdit1.Lines.Count-1 do
   begin
        strMemo:=RichEdit1.Lines.Strings[i];
        subFirst3:=trim(Copy(strMemo,0,3));
        //ListBox1.Items.Add(subFirst3);
        //only audio
        index:=TOnlyAudio.IndexOfName(subFirst3);

        if index>-1 then
        begin
            RadioGroupOAudio.Height:= RadioGroupOAudio.Height+20;
            RadioGroupOAudio.Items.Add(TOnlyAudio.Names[index]+' '+TOnlyAudio.ValueFromIndex[index]+' '+getbyte(strMemo));
            //ListBox1.Items.Add(TOnlyAudio.Names[index]+' '+TOnlyAudio.ValueFromIndex[index]+' '+getbyte(strMemo));
        end;
        //only video
        index:=TOnlyVideo.IndexOfName(subFirst3);

        if index>-1 then
        begin
            RadioGroupOVideo.Height:=RadioGroupOVideo.Height+20;
            RadioGroupOVideo.Items.Add(TOnlyVideo.Names[index]+' '+TOnlyVideo.ValueFromIndex[index]+' '+getbyte(strMemo)+' '+getresolution(strMemo));
           //ListBox1.Items.Add(TOnlyVideo.Names[index]+' '+TOnlyVideo.ValueFromIndex[index]+' '+getbyte(strMemo)+' '+getresolution(strMemo));
        end;
        // for video
        index:=TVideo.IndexOfName(subFirst3);

        if index>-1 then
        begin
            RadioGroupVideo.Height:=RadioGroupVideo.Height+20;
            RadioGroupVideo.Items.Add(TVideo.Names[index]+' '+TVideo.ValueFromIndex[index]+' '+getresolution(strMemo));
           //ListBox1.Items.Add(TVideo.Names[index]+' '+TVideo.ValueFromIndex[index]+' '+getresolution(strMemo));
        end;
    end;
 {
  RichEdit1.DefAttributes.Color := clwhite;
  params:=folderyoutube+' --console-title -F '+Edit1.Text;
  memobug.Lines.Add(params);
  //https://www.youtube.com/watch?v=28qzyK924MI
  if not Started then
  begin
    Abort := false;
    Started := true;
    lastStamp := 0;
    WatchProcessUntillOver(params, '', '', nil, LoopFunc, Cardinal(self), 0);
    Started := false;
  end
  else
  begin
    Abort := true;
  end;     }
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  ClearRadioButtonofAdvancedMenu;
  LabelWarningPlaylist.Visible:=false;
  Image1.Picture.LoadFromFile('logo.jpg');
  Edit1.Text:='';
  if started then
  begin
    Abort := true;
  end;
  frmMain.Caption:='Youtube-Dl Extractor';
  Timer1.Enabled:=false;
end;

procedure TfrmMain.btnMergeClick(Sender: TObject);
var
  str:string;
begin
  percent:=0;
  str:='';
  RichEdit1.DefAttributes.Color := clwhite;

  if length(folderdownload)>0 then
  begin
    if length(edtDownloadFolderSecond.Text)>0 then
    begin
      str:=str+' -o "'+folderdownload+'\'+edtDownloadFolderSecond.Text+'\%(title)s-%(id)s.%(ext)s" ';
    end else
    begin
      str:=str+' -o "'+folderdownload+'\%(title)s-%(id)s.%(ext)s" ';
    end;
  end else
  begin
    ShowMessage('Destination folder is nil');
    str:='';
  end ;

  params:=folderyoutube +' '+ str +' --merge-output-format mp4 '+ Edit1.Text;
  memobug.Lines.Add(params);


end;

procedure TfrmMain.CheckBoxMergeClick(Sender: TObject);
var
  temprichedit:string;
begin
if CheckBoxMerge.Checked=true then
begin
  temprichedit:=RichEdit1.Text;
  RichEdit1.Lines.Clear;
  RichEdit1.DefAttributes.Color := clHighlight;
  RichEdit1.Lines.Append('---------------------------------');
  RichEdit1.Lines.Append('---------------------------------');
  RichEdit1.Lines.Append('FIRST YOU MUST LEARN DATA FORMAT');
  RichEdit1.Lines.Append('PLEASE CLICK "LEARN FORMAT" BUTTON AND  FILL EDITS WITH "FORMAT CODE"s ');
  RichEdit1.Lines.Append('----------------------------------------------------------------------------');
  RichEdit1.Lines.Append('----------------------------------------------------------------------------');
  RichEdit1.Lines.Add(temprichedit);
end;
end;

procedure TfrmMain.RadioButtonAudioClick(Sender: TObject);
var
  frmaudio:TfrmAudio;
  temp:String;
begin
  LabelWarningPlaylist.Visible:=true;
  CheckBoxMerge.Checked:=false;
  ClearRadioButtonofAdvancedMenu;
  {temp:=RichEdit1.Text;
  RichEdit1.Clear;
  RichEdit1.Lines.Add('Selected Audio with formats "'+ComboBoxAudioFormat.Text +'" and You must click START button');
  RichEdit1.Lines.Add('-----------------------------------------');
  RichEdit1.Lines.Add(temp);    }
  //ComboBoxAudioFormat.Enabled:=true;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var
  i:integer;

begin
  frmMain.Caption:=copy(frmMain.Caption,2,length(frmMain.Caption)-1)+frmMain.Caption[1];

  frmbug.Memo1.Clear;
  for i:=RichEdit1.Lines.Count-1 downto 0 do
  begin
    frmbug.Memo1.Lines.Add(RichEdit1.Lines[i]);
  end;
   frmbug.Memo1.Lines.Add('-------------------');
   frmbug.Memo1.Lines.Add(memobug.Text);

end;

{procedure TfrmMain.btnupdateClick(Sender: TObject);
begin
  // update

params:=folderyoutube+' -U ';
memobug.Lines.Add(params);

if not Started then
  begin
    Abort := false;
    Started := true;
    lastStamp := 0;
    WatchProcessUntillOver(params+'', '', '', nil, LoopFunc, Cardinal(self), 0);
    Started := false;
  end
  else
  begin
    Abort := true;
  end;
end;}

procedure TfrmMain.MenuLangClick(Sender: TObject);
var
  frmlang: TfrmLanguage;
begin
  frmlang:=TfrmLanguage.Create(self);
  frmlang.ShowModal;

end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  I:Integer;
  str:String;

begin
  if lang='tr' then
  begin
    LangIniFile := Tinifile.Create(ExtractFilePath(Application.ExeName)+'YDElang_tr.ini') ;
  end else begin
    LangIniFile := Tinifile.Create(ExtractFilePath(Application.ExeName)+'YDElang_en.ini') ;
  end;

  with frmMain do
  begin
    for I := ComponentCount -1 downto 0 do
    begin
      if Components[i] is TLabel then // Check if it is.
      begin
        TLabel(Components[i]).Caption:=LangIniFile.ReadString('lang',Components[i].Name,'');
        //Memo1.Lines.Add(Components[i].Name) ;
      end else if  Components[i] is TGroupBox then
      begin
        TGroupBox(Components[i]).Caption:=LangIniFile.ReadString('lang',Components[i].Name,'');
        //Memo1.Lines.Add(Components[i].Name) ;
      end else if  Components[i] is TRadioButton then
      begin
         //Memo1.Lines.Add(TRadioButton(Components[i]).Hint) ;
         TRadioButton(Components[i]).Caption:=LangIniFile.ReadString('lang',Components[i].Name,'');
      end else if  Components[i] is TMenuItem then
      begin
        //str:=Components[i].Name;
        //ShowMessage(Components[i].Name);
       // Memo1.Lines.Add('ss')
         //Memo1.Lines.Add(str) ;
         TMenuItem(Components[i]).Caption:=LangIniFile.ReadString('lang',Components[i].Name,'');
      end else if   Components[i] is TButton then
      begin
         TButton(Components[i]).Caption:=LangIniFile.ReadString('lang',Components[i].Name,'');
         TButton(Components[i]).Hint:=LangIniFile.ReadString('lang',Components[i].Name+'Hint','');
         //Memo1.Lines.Add(TButton(Components[i]).Hint) ;
      end else if   Components[i] is TCheckBox then
      begin
         TCheckBox(Components[i]).Caption:=LangIniFile.ReadString('lang',Components[i].Name,'');
         TCheckBox(Components[i]).Hint:=LangIniFile.ReadString('lang',Components[i].Name+'Hint','');
      end else if Components[i] is TEdit then
      begin
         //Memo1.Lines.Add(Components[i].Name) ;
         Tedit(Components[i]).Hint:=LangIniFile.ReadString('lang',Components[i].Name+'Hint','');
      end;

    end;

  end;

end;

procedure TfrmMain.CheckBoxLangClick(Sender: TObject);
begin
  if CheckBoxLang.Checked then
  begin
    IniFile.WriteString('settings','lang','tr');
  end else begin
    IniFile.WriteString('settings','lang','en');
  end;
end;

procedure TfrmMain.Edit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    Edit1.Text:='';
    Edit1.PasteFromClipboard;
  end else if Button = mbRight then
  begin
    Edit1.Text:='';
    Edit1.PasteFromClipboard;
  end;
end;

procedure TfrmMain.MenuUpdateClick(Sender: TObject);
var
  frmSettings: TfrmLanguage;
begin
  frmSettings:=TfrmLanguage.Create(self);
  frmSettings.ShowModal;

end;

procedure TfrmMain.RadioButtonVideoClick(Sender: TObject);
begin
 LabelWarningPlaylist.Visible:=true;
end;

procedure TfrmMain.btnupdateClick(Sender: TObject);
begin
          if not Started then
          begin
            Abort := false;
            Started := true;
            lastStamp := 0;
            WatchProcessUntillOver('youtube-dl.exe -U'+'', '', '', nil, LoopFunc, Cardinal(self), 0);
            Started := false;
          end
          else
          begin
            Abort := true;
          end;
end;

procedure TfrmMain.btnClearAdvClick(Sender: TObject);
begin
    RadioGroupOAudio.ItemIndex:=-1;
    RadioGroupVideo.ItemIndex:=-1;
    RadioGroupOVideo.ItemIndex:=-1;


    CheckBoxMerge.Checked:=false;
    edtAudioformat.Text:='';
    edtVideoFormat.Text:='';
end;

procedure TfrmMain.ClearRadioButtonofAdvancedMenu;
begin
   RadioGroupOAudio.Height:=20;
   RadioGroupOVideo.Height:=20;
   RadioGroupVideo.Height:=20;
    RadioGroupOAudio.ItemIndex:=-1;
    RadioGroupOAudio.Items.Clear;
    RadioGroupVideo.ItemIndex:=-1;
    RadioGroupVideo.Items.Clear;
    RadioGroupOVideo.ItemIndex:=-1;
    RadioGroupOVideo.Items.Clear;
end;

procedure TfrmMain.RadioGroupOAudioClick(Sender: TObject);
var
  temp:String;
begin
  temp:=RichEdit1.Text;

  edtAudioformat.Text:=Get3String(RadioGroupOAudio.Items.Strings[RadioGroupOAudio.itemindex]);
  RadioGroupVideo.ItemIndex:=-1;
  if RadioGroupOVideo.ItemIndex<0 then
  begin
    RadioGroupOVideo.ItemIndex:=0;
   end else begin
    //RichEdit1.DefAttributes.Color := clHighlight;
    RichEdit1.Clear;
    RichEdit1.Lines.Add('Click "Check for Merge" BUTTON from the left side panel and click START');
    RichEdit1.Lines.Add('----------------------------------');
    RichEdit1.Lines.Add(temp);
  end;

end;

procedure TfrmMain.RadioGroupVideoClick(Sender: TObject);
var
  temp:String;
begin
  CheckBoxMerge.Checked:=false;
  edtAudioformat.Text:='';
  edtVideoFormat.Text:='';
  RadioGroupOAudio.ItemIndex:=-1;
  RadioGroupOVideo.ItemIndex:=-1;
  temp:=RichEdit1.Text;
  RichEdit1.Clear;
  RichEdit1.Lines.Add('You selected "video with audio" formats');
  RichEdit1.Lines.Add('CLICK THE START BUTTON  from the TOP SIDE PANEL');
  RichEdit1.Lines.Add('###############################################');
  RichEdit1.Lines.Add('###############################################');
  RichEdit1.Lines.Add(temp);
  //RichEdit1.DefAttributes.Color := clGreen;

end;

procedure TfrmMain.RadioGroupOVideoClick(Sender: TObject);
var
  temp:String;
begin
  temp:=RichEdit1.Text;
  edtVideoFormat.Text:=Get3String(RadioGroupOVideo.Items.Strings[RadioGroupOVideo.itemindex]) ;
  RadioGroupVideo.ItemIndex:=-1;
  if RadioGroupOAudio.ItemIndex<0 then
  begin
    RadioGroupOAudio.ItemIndex:=0;
  end else begin
    //RichEdit1.DefAttributes.Color := clHighlight;
    RichEdit1.Clear;
    RichEdit1.Lines.Add('Click "Check for Merge" BUTTON from the left side panel and click START');
    RichEdit1.Lines.Add('----------------------------------');
    RichEdit1.Lines.Add(temp);
  end;

end;

procedure TfrmMain.edtDownloadRateLimitKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = 84) and (Shift = [ssCtrl]) then
  begin
     frmbug.Show;
    frmbug.Left:=frmMain.Left+frmMain.Width-5;
    frmbug.top:=frmMain.Top;
  end;

end;

end.
