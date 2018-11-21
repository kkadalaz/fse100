global key
InitKeyboard();

% Motor @ port A is the right motor
% Motor @ port B is the left motor
% Motor @ port C is wheelchair arm

% Sensor @ port 1 is color sensor
% Sensor @ port 2 is gyroscope
% Sensor @ port 3 is ultrasonic

while 1
    pause(0.1);
    switch key
        case 'w'
            brick.MoveMotor('AB', 50);
        case 's'
            brick.MoveMotor('AB', -50);
        case 'a'
            brick.MoveMotor('A', 50);
            brick.MoveMotor('B', -50);
        case 'd'
            brick.MoveMotor('A', -50);
            brick.MoveMotor('B', 50);
        case 'uparrow'
            brick.MoveMotorAngleRel('C', 30, 45, 'Brake');
        case 'downarrow'
            brick.MoveMotorAngleRel('C', 30, -45, 'Brake');
        case 'q'
            brick.StopAllMotors();
    end
end

CloseKeyboard();