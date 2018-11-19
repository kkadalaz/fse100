% disconnect
% global brick
% brick.DisconnectBrick('ENZO');

% connect
brick = ConnectBrick('ENZO');

% connection test
% brick.MoveMotor('A', 50);
% pause(1); 
% brick.StopMotor('A');