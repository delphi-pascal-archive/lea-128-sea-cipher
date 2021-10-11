program SEA_Example;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  SEA in 'SEA.pas',
  LEA_Hash in 'LEA_Hash.pas';

{$R *.res}
{$R WindowsXP.res}

begin
  Application.Initialize;
  Application.Title := 'Exemple SEA';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
