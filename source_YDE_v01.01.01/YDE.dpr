program YDE;

uses
  Forms,
  main in 'main.pas' {frmMain},
  settings in 'settings.pas' {frmSettings},
  functions in 'functions.pas',
  audio in 'audio.pas' {frmAudio},
  unitTextEcrypt in 'unitTextEcrypt.pas',
  frmLang in 'frmLang.pas' {frmLanguage};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmLanguage, frmLanguage);
  Application.CreateForm(TfrmSettings, frmSettings);
  //Application.CreateForm(TfrmLanguage, frmLanguage);
  //Application.CreateForm(TfrmSettings, frmSettings);
  //Application.CreateForm(TfrmAudio, frmAudio);
  Application.Run;
end.
