% global brick
% brick.DisconnectBrick('ENZO');

brick = ConnectBrick('ENZO');

brick.MoveMotor('A', 50);
pause(1); 
brick.StopMotor('A');