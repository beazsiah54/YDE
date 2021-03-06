unit settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,inifiles,unitTextEcrypt;

type
  TfrmSettings = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    edtyoutubefolder: TEdit;
    edtffmpegFolder: TEdit;
    btnSave: TButton;
    edtDownloadFolder: TEdit;
    Label3: TLabel;
    GroupBox2: TGroupBox;
    edtUser: TEdit;
    edtPassword: TEdit;
    btnUserSave: TButton;
    Label4: TLabel;
    Label5: TLabel;
    procedure btnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnUserSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSettings: TfrmSettings;
  IniFile : TIniFile;

  folderyoutube:string;
  ffmpegfolder:string;
  folderdownload:string;
  status:integer;
  user:String;
  password:string;
implementation

{$R *.dfm}

procedure TfrmSettings.btnSaveClick(Sender: TObject);
begin
  IniFile.WriteInteger('Settings','status',1);
  IniFile.WriteString('Settings','youtube_dl_folder',edtYoutubeFolder.Text);
  IniFile.WriteString('Settings','ffmpeg',edtffmpegfolder.Text);
  IniFile.WriteString('Settings','downloadfolder',edtDownloadFolder.Text);
end;

procedure TfrmSettings.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
IniFile.Free;
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  Left:=(Screen.Width-Width)  div 2;
  Top:=(Screen.Height-Height) div 2;
    //IniFile := TIniFile.Create('C:\Users\bob\Desktop\youtube-dl  v3\myapp.ini') ;
    IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini')) ;
    

    status:=IniFile.ReadInteger('Settings','status',0);
    if status=0 then
    begin
        ffmpegfolder:=ExtractFilePath(ParamStr(0))+'ffmpeg.exe';
        edtffmpegfolder.Text:=ffmpegfolder;
        folderyoutube:=ExtractFilePath(ParamStr(0))+'youtube-dl.exe';
        edtYoutubeFolder.Text:=folderyoutube;
        folderdownload:=  ExtractFilePath(ParamStr(0));
        edtDownloadFolder.Text:=folderdownload;
    end else
    begin
        ffmpegfolder:=IniFile.ReadString('Settings','ffmpeg','No Value');
        edtffmpegfolder.Text:=ffmpegfolder;
        folderyoutube:=IniFile.ReadString('Settings','youtube_dl_folder','No Value');
        edtYoutubeFolder.Text:=folderyoutube;
        folderdownload:=  IniFile.ReadString('Settings','downloadfolder','No Value');
        edtDownloadFolder.Text:=folderdownload;
        user:= IniFile.ReadString('Settings','user','No Value');
        password:= IniFile.ReadString('Settings','password','No Value');
        edtUser.Text:=user;
        edtPassword.Text:=password;
    end;
end;

procedure TfrmSettings.btnUserSaveClick(Sender: TObject);
begin
  IniFile.WriteString('Settings','user',edtUser.Text);
  IniFile.WriteString('Settings','password',Base64Encode(edtPassword.Text));
end;

end.
