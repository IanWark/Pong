unit classBall;

// Ball object that bounces off paddles and scores when reaches far left/right side
// TAIBall is an invisible ball sent ahead of TBall so the AI can predict path of ball

interface
uses classPaddle,
  FMX.Objects, Classes, Types, UITypes, GameValues;

type

  TBall = class(TRoundRect)
  private
    cX : Extended;
    cY : Extended;
  published
    property velX : Extended
      read cX write cX;
    property velY : Extended
      read cY write cY;

    constructor Create(AOwner: TComponent);
    procedure CenterBall;
    procedure Reset(PlayerServe : Boolean);
    function GetCenterY : Single;
    procedure Tick;
    function OutOfBoundsX(newX : Single) : Boolean;
    function OutOfBoundsY(newY : Single) : Boolean;
    function Collision(Rect : TPaddle; newX : Single; newY : Single) : Boolean;
  end;

  // TAIBall is an invisible ball sent ahead of TBall so the AI can predict path of ball
  TAIBall = class(TBall)
  private
    Stopped : Boolean;
  published
    constructor Create(AOwner : TComponent);
    procedure Tick;
    function OutOfBoundsX(newX : Single) : Boolean;
    procedure SendBall(Ball : TBall);
  end;

implementation
uses Game;

constructor TBall.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);
  Width := BallSize;
  Height:= BallSize;
  Visible := True;
  Fill.Color := BallColour;

  velX := 0;
  velY := 0;
end;

// Moves ball to center of screen
procedure TBall.CenterBall;
begin
  Position.X := GameForm.Center.Position.X - (BallSize/2) + 1;
  Position.Y := GameForm.Center.Position.Y - (BallSize/2) + 1;
end;

// If it is player's serve, ball comes towards player
// Else, towards opponent
procedure TBall.Reset(PlayerServe : Boolean);
begin
  velY := 0;
  if PlayerServe then
  begin
    Position.X := Trunc(GameForm.Width/4 - BallSize/2) - (WidthAdjust*2 + 1);
    Position.Y := Trunc(GameForm.Height/2 - BallSize/2) - HeightAdjust;
    velX := BallSpeed;
    Game.AIBall.centerBall;
  end
  else
  begin
    Position.X := Trunc(3*GameForm.Width/4 - BallSize/2) - (WidthAdjust*2 + 1);
    Position.Y := Trunc(GameForm.Height/2 - BallSize/2) - HeightAdjust;
    velX := -BallSpeed;
    Game.AIBall.SendBall(Self);
  end;
end;

// Position.Y returns top right of ball, this returns center of ball
function TBall.GetcenterY;
begin
  Result := Position.Y + (Height/2);
end;

// Every tick, check for collisions/out of bounds, else move according to velocity
procedure TBall.Tick;
var
  Event : Boolean;
  newX : Single;
  newY : Single;
begin
  Event := False;
  newX := Position.X + velX;
  newY := Position.Y + velY;

  // Check for out of bounds
  if OutOfBoundsX(Position.X) then Event := True
  else
  if OutOfBoundsY(newY) then Event := True
  else
  //  Check for collision with paddles
  if Collision(Opponent, newX, newY) then Event := True
  else
  if Collision(Player, newX, newY) then Event := True;

  // if nothing exciting happened, just move ball
  if not Event then
  begin
    Position.X := newX;
    Position.Y := newY;
  end;
end;

// If out of bound left/right, score point and reset serve
// Used in Tick
function TBall.OutOfBoundsX(newX: Single) : Boolean;
begin
  // Left (Opponent)
  if (newX < 0) then
  begin
    Ball.Reset(True);
    Inc(Game.PlayerScore, 1);
    GameForm.SetScores;
    Result := True;
  end
  else
  // Right (Player)
  if (newX > MaxBallX) then
  begin
    Ball.Reset(False);
    Inc(Game.OpponentScore, 1);
    GameForm.SetScores;
    Result := True;
  end
  else Result := False;
end;

// If out of bounds top/bottom, just bounce
// Used in Tick
function TBall.OutOfBoundsY(newY: Single) : Boolean;
begin
  // Top
  if (newY < 0) then
  begin
    Position.Y := 0;
    velY := -velY;
    Result := True;
  end
  else
  // Bottom
  if (newY > MaxBallY) then
  begin
    Position.Y := MaxBallY;
    velY := -velY;
    Result := True;
  end
  else Result := False;
end;

// Checks for collision with paddles
// If collision, set new velocity/position
// Used in Tick
function TBall.Collision(Rect: TPaddle; newX : Single; newY : Single) : Boolean;
var
  X : Single;
  Y : Single;
  Number : Single;
begin
  Result := False;
  // Test 4 corners of the ball
  // Top Left
  X := newX;
  Y := newY;
  if Rect.PointInObject(X,Y) then
  begin
    Result := True;
  end
  else
  begin
    // Top Right
    X := newX + Width;
    if Rect.PointInObject(X,Y) then
    begin
      Result := True;
    end
    else
    begin
      // Bottom Right
      Y := newY + Height;
      if Rect.PointInObject(X,Y) then
      begin
        Result := True;
      end
      else
      begin
        // Bottom Left
        X := newX;
        if Rect.PointInObject(X,Y) then
        begin
          Result := True;
        end;
      end;
    end;
  end;

  // Calculate new velocity/position
  // http://gamedev.stackexchange.com/questions/4253/in-pong-how-do-you-calculate-the-balls-direction-when-it-bounces-off-the-paddl
  if Result then
  begin
    // Relative Y difference
    Number := Rect.GetYCenter - (newY + (Height/2));
    // Normalize Y difference
    Number := Number / (Rect.Height/2);
    // Multiply by maximum bounce angle
    Number := Number * MaxBounceAngle;

    // Calculate new velocity, Set position to just outside paddle
    // Positive veloctiy - Already towards player, send to opponent
    velY := BallSpeed*-Sin(Number);
    if velX > 0 then
    begin
      velX := -BallSpeed*Cos(Number);
      Position.X := Rect.Position.X - Ball.Width;

      // Send invisible AIball to predict path
      GameForm.SendAIBall;
    end
    // Negative velocity - Already towards Opponent, send to player
    else
    begin
      velX := BallSpeed*Cos(Number);
      Position.X := Rect.Position.X + Rect.Width;
    end;
  end;
end;

constructor TAIBall.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  Stopped := True;
  Width := BallSize;
  Height := BallSize;
  Opacity := 0;
end;

// Every tick, check for out of bounds, else move ball
procedure TAIBall.Tick;
var
  Event : Boolean;
  newX : Single;
  newY : Single;
begin
  if not Stopped then
  begin
    Event := False;
    newX := Position.X + velX;
    newY := Position.Y + velY;
    // Check for out of bounds
    if OutOfBoundsX(Position.X) then Event := True
    else
    if OutOfBoundsY(Position.Y) then Event := True;

    // if nothing exciting happened, just move ball
    if not Event then
    begin
      Position.X := newX;
      Position.Y := newY;
    end;
  end;
end;

// if out of bounds on opponent side, stop it there
// Replaces normal ball OutOfBoundsX
function TAIBall.OutOfBoundsX(newX: Single) : Boolean;
begin
  // Left
  if (newX < 0) then
  begin
    Stopped := True;
    Result := True;
  end
  else Result := False;
end;

// Launch a invisible ball using normal balls current vel/pos
procedure TAIBall.SendBall(Ball: TBall);
begin
  velX := Ball.velX * AIBallSpeedMultiplier;
  velY := Ball.velY * AIBallSpeedMultiplier;
  Position.X := Ball.Position.X;
  Position.Y := Ball.Position.Y;
  Stopped := False;
end;

end.
