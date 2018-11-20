
setupEV3(brick);
solveMaze(brick);

% initial robot setup

function setupEV3(brick)
    disp('setting up robot');

    brick.SetColorMode(3, 4); % RGB mode
    brick.GyroCalibrate(2);

    disp('robot set up');
end

% maze solving algorithm

function solveMaze(brick)
    disp('entering solveMaze');
    
    complete = false;

    while ~complete
        color = getColor();

        red = color(1);
        green = color(2);
        blue = color(3);

        if red >= green + blue
            disp('in red square');
            pause(2);
        elseif green >= red + blue
            disp('in green square');
            disp('exiting solveMaze')
            complete = true;
        elseif blue >= green + red
            disp('in blue square');
            keyboardControl(brick);
        end
    end
    disp('exiting solveMaze')
end

% keyboard controls

function keyboardControl(brick)
    global key

    disp('entering keyboardControls');
    
    InitKeyboard();

    complete = false;
    
    while ~complete
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
                complete = true;
        end
    end
    
    CloseKeyboard();
    
    disp('exiting keyboardControl');
end

