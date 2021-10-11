unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, SEA;

type
  TMainForm = class(TForm)
    FileLbl: TLabel;
    FileEdit: TEdit;
    InfoLbl: TLabel;
    EncryptBtn: TButton;
    DecryptBtn: TButton;
    QuitBtn: TButton;
    Bar: TProgressBar;
    OpenDlg: TOpenDialog;
    KeyLbl: TLabel;
    KeyEdit: TEdit;
    RandomBtn: TButton;
    FastOption: TRadioButton;
    SecureOption: TRadioButton;
    TypeLbl: TLabel;
    procedure FileEditEnter(Sender: TObject);
    procedure QuitBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RandomBtnClick(Sender: TObject);
    procedure EncryptBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;
  Running: Boolean;

implementation

{$R *.dfm}

procedure Callback(Position, Count: Longword);
begin
 if (Position mod 32768 <> 0) and (Position <> Count) then Exit;
 MainForm.Bar.Max := Count;
 MainForm.Bar.Position := Position;
 Application.ProcessMessages;
end;

procedure TMainForm.FileEditEnter(Sender: TObject);
begin
 if OpenDlg.Execute then
  begin
   FileEdit.Text := ExtractFileName(OpenDlg.FileName);
   EncryptBtn.Enabled := FileExists(OpenDlg.FileName);
   DecryptBtn.Enabled := FileExists(OpenDlg.FileName);
  end;
end;

procedure TMainForm.QuitBtnClick(Sender: TObject);
begin
 Close;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 randomize;
 DoubleBuffered := True;
 Bar.DoubleBuffered := True;
end;

procedure TMainForm.RandomBtnClick(Sender: TObject);
begin
 KeyEdit.Text := Format('%x%x%x%x%x', [random(256), random(256), random(256), random(256), random(256)]);
end;

procedure TMainForm.EncryptBtnClick(Sender: TObject);
const
 CryptType: array [Boolean] of Longword = (OPERATION_FAST, OPERATION_SECURE);
begin
 if Sender is TButton then with TButton(Sender) do
  try
   EncryptBtn.Enabled := False;
   DecryptBtn.Enabled := False;
   Running := True;
   if not EncryptFile(OpenDlg.FileName, ObtainKey(KeyEdit.Text), Tag or CryptType[SecureOption.Checked], Callback) then
    raise Exception.Create('Erreur lors de l''encryptage/décryptage du fichier.');
  finally
   Bar.Position := 0;
   EncryptBtn.Enabled := True;
   DecryptBtn.Enabled := True;
   Running := False;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if Running then
  begin
   Action := caNone;
   MessageDlg('Impossible d''arrêter pendant l''encryptage/décryptage : le fichier serait alors à moitié encrypté et à moitié décrypté, ce qui rendrait sa reconstitution quasiment impossible.', mtWarning, [mbOK], 0);
  end;
end;

end.
