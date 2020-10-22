program SchachProjekt;

uses
  Forms,
  HauptFm in 'HauptFm.pas' {Form1},
  uBauern in 'uBauern.pas',
  uFEN in 'uFEN.pas',
  uLaeufer in 'uLaeufer.pas',
  uSchach in 'uSchach.pas',
  uSpringer in 'uSpringer.pas',
  uTurm in 'uTurm.pas',
  uDame in 'uDame.pas',
  uKoenig in 'uKoenig.pas',
  uHeuristik in 'uHeuristik.pas',
  uMaxMin in 'uMaxMin.pas',
  uABVerfahren in 'uABVerfahren.pas',
  NetzwerkFm in 'NetzwerkFm.pas' {NetzwerkFormular},
  uBenJak in 'uBenJak.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TNetzwerkFormular, NetzwerkFormular);
  Application.Run;
end.
