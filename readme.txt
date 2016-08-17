A quick pong clone in Delphi.

Game is the main file, classBall and classPaddle are definitions of objects used in Game.

classBall handles ball movement and collision, and thus, the target the opponent paddle moves towards
classPaddle handles the paddles, following the mouse for the player and following the AIBall for the opponent

GameValues contain the constants used: Ballspeed, paddle size, etc.

Reading Delphi:
Delphi is an IDE with a visual form designer, so without actually owning Delphi and being able to open the project it can be a bit hard to read.

The .pas files are the main code parts, though they often rely on objects in the forms, defined in the .fmx files.