% global brick
% brick.DisconnectBrick('ENZO');

brick = ConnectBrick('EV3');

brick.MoveMotor('A', 50);
pause(1); 
brick.StopMotor('A');