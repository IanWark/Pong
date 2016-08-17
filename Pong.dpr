program Pong;

uses
  System.StartUpCopy,
  FMX.Forms,
  Game in 'Game.pas' {GameForm},
  classBall in 'classBall.pas',
  classPaddle in 'classPaddle.pas',
  GameValues in 'GameValues.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGameForm, GameForm);
  Application.Run;
end.
