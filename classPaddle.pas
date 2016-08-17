unit classPaddle;

// Paddle objects deflect ball
// PlayerPaddle moves to mouse
// OpponentPaddle moves to deflect AIBall

interface
uses FMX.Objects, Classes, GameValues, UITypes;

type

  // Base class - not used
  TPaddle = class(TRectangle)
  published
    constructor Create(AOwner : TComponent);
    function GetYCenter : Single;
  end;

  TPlayerPaddle = class(TPaddle)
  published
    constructor Create(AOwner : TComponent; PosX : Integer; PosY : Integer);
    procedure MovePaddle(PosY : Single);
  end;

  // OpponentPaddle moves to deflect ball
  TOpponentPaddle = class(TPaddle)
    published
      constructor Create(AOwner : TComponent; PosX : Integer; PosY : Integer);
      procedure MovePaddle(PosY : Single);
  end;

implementation
uses Game;

  constructor TPaddle.Create(AOwner : TComponent);
  begin
    Inherited Create(AOwner);
    Width := PaddleWidth;
    Height := PaddleHeight;
    Visible := True;
  end;

  // Position.Y returns top right of paddle, this returns center of paddle
  function TPaddle.GetYCenter : Single;
  begin
    Result := Trunc(Position.Y + (Height/2));
  end;

  constructor TPlayerPaddle.Create(AOwner : TComponent; PosX : Integer; PosY : Integer);
  begin
    Inherited Create(AOwner);
    Position.X := PosX;
    Position.Y := PosY;
    Fill.Color := PlayerColour;
  end;

  // When mouse moves move paddle accordingly
  procedure TPlayerPaddle.MovePaddle(PosY: Single);
  begin
    if PosY < MinPaddleY then Position.Y :=0
    else if PosY > MaxPaddleY then Position.Y := MaxPaddleY
    else Player.Position.Y := PosY - (PaddleHeight/2);
  end;

  constructor TOpponentPaddle.Create(AOwner : TComponent; PosX : Integer; PosY : Integer);
  begin
    Inherited Create(AOwner);
    Position.X := PosX;
    Position.Y := PosY;
    Fill.Color := OpponentColour;
  end;

  // Paddle attempts to move towards AIBall
  procedure TOpponentPaddle.MovePaddle(PosY : Single);
  var
    PaddleCenter : Single;
    Diff : Single;
  begin
    Diff := Trunc(PosY) - GetYCenter;
    // AIBall below PaddleCenter - Move down
    if Diff > 0 then
    begin
      if Diff < AIPaddleSpeed then Position.Y := Position.Y + Diff
      else Position.Y := Position.Y + AIPaddleSpeed;
    end
    else
    // AIBall above PaddleCenter - Move up
    if Diff < 0 then
    begin
      if -Diff < AIPaddleSpeed then Position.Y := Position.Y - Diff
      else Position.Y := Position.Y - AIPaddleSpeed;
    end;
  end;
end.
