unit Game;

interface

// Mainform that creates game and handles pause/unpause, scores, main game tick,
// and calling the different parts functions at the right time

// classBall handles ball movement and collision, and thus, the target the opponent paddle moves towards
// classPaddle handles the paddles, following the mouse for the player and following the AIBall for the opponent
// GameValues contain the constants used: Ballspeed, paddle size, etc.

uses
  classBall, classPaddle, GameValues,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

var
  PlayerScore : Integer;
  OpponentScore : Integer;

  MinPaddleY : Extended;
  MaxPaddleY : Extended;
  MaxBallY : Extended;
  MaxBallX : Extended;

  Ball : TBall;
  AIBall : TAIBall;
  Player : TPlayerPaddle;
  Opponent : TOpponentPaddle;

type
  TGameForm = class(TForm)
    Tick: TTimer;
    rectPause: TRectangle;
    lPause: TLabel;
    layPause: TLayout;
    Line1: TLine;
    Line2: TLine;
    Center: TCircle;
    Line3: TLine;
    Line4: TLine;
    lScoreOpponent: TLabel;
    layScore: TLayout;
    lScorePlayer: TLabel;
    lOpponent: TLabel;
    lPlayer: TLabel;
    panelMouse: TPanel;
    Background: TRectangle;
    procedure Print(Text : String);
    procedure TickTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rectPauseClick(Sender: TObject);
    procedure SetScores;
    procedure Pause;
    procedure Unpause;
    procedure SendAIBall;

    procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GameForm: TGameForm;

implementation

{$R *.fmx}

// Prints message to screen
// For debugging/development
procedure TGameForm.Print(Text: string);
begin
  ShowMessage(Text);
end;

procedure TGameForm.FormCreate(Sender: TObject);
begin
  // Create invisble target for Opponent to move to
  AIBall := TAIBall.Create(Self);
  AIBall.Parent := Self;

  // Create ball, reset also centres AIBall
  Ball := TBall.Create(Self);
  Ball.Parent := Self;
  Ball.Reset(True);

  // Create paddles
  Player   := TPlayerPaddle.Create(Self,
                                   Width - (PaddleWidth + 20 + WidthAdjust),
                                   Trunc(Height/2 - PaddleHeight/2) - HeightAdjust);
  Opponent := TOpponentPaddle.Create(GameForm,
                                     20,
                                     Trunc(Height/2 - PaddleHeight/2) - HeightAdjust);
  Player.Parent := Self;
  Opponent.Parent := Self;

  // Highest point paddle can go
  MinPaddleY := (PaddleHeight/2);
  // Lowest point paddle can go
  MaxPaddleY := (Height - PaddleHeight - HeightAdjust - 15);
  // Lowest point ball can go
  MaxBallY := (Height - BallSize - HeightAdjust - 15);
  // Most right point ball can go
  MaxBallX := Width;

  PlayerScore := 0;
  OpponentScore := 0;
  SetScores;

  // Start game paused
  Pause;

  // PanelMouse is a invisible panel covering the entire game so MouseMove works properly,
  // even when over another component like the paddle or ball
  panelMouse.BringToFront;
  layPause.BringToFront;
end;

// On tick (every 15 milliseconds)
procedure TGameForm.TickTimer(Sender: TObject);
begin
  Ball.Tick;
  AIBall.Tick;
  Opponent.MovePaddle(AIBall.GetCenterY);
end;

// Clicking while paused unpauses game
procedure TGameForm.rectPauseClick(Sender: TObject);
begin
  Unpause;
end;

// Set scores text
procedure TGameForm.SetScores;
begin
  lScorePlayer.Text := PlayerScore.ToString;
  lScoreOpponent.Text := OpponentScore.ToString;
end;

procedure TGameForm.Pause;
begin
  lPlayer.Visible := True;
  lOpponent.Visible := True;

  layPause.Visible := True;
  layPause.BringToFront;

  Tick.Enabled := False;
end;

procedure TGameForm.Unpause;
begin
  lPlayer.Visible := False;
  lOpponent.Visible := False;

  layPause.Visible := False;

  Tick.Enabled := True;
end;

// Send invisible ball as target for Opponent Paddle
procedure TGameForm.SendAIBall;
begin
  AIBall.SendBall(Ball);
end;

// When mouse moves move paddle accordingly
procedure TGameForm.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  // X = -1 when out of screen
  if X > -1 then
  begin
    Player.MovePaddle(Y);
  end;
end;

end.
