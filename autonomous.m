
% square to square distance: 2' 1"

% initMaze();
setupEV3();
solveMaze();

function setupEV3
    global brick

    disp('setting up robot');

    brick.SetColorMode(3, 4); % RGB mode
    brick.GyroCalibrate(2);
    
    disp('robot set up');
end

function solveMaze
    global brick
    global maze
    global row
    global column
    global orientation

    disp('solving maze');
    
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
            disp('terminating solveMaze()');
            complete = true;
        elseif blue >= green + red
            disp('in blue square');
            keyboardControl();
        else
            disp('oof, in algorithm');

            complete = true;
        end
    end
end

% keyboard controls

function keyboardControl
    global brick
    global key

    disp('entering keyboard controls');
    
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
    
    disp('exiting keyboard control');
end

% movement functions

function driveStraight(distance)
    global brick

    disp('Moving forward')

    brick.MoveMotor('AB', distance);
    brick.WaitForMotor('AB');

    disp('Finished moving forward')
end

function turnRight(degrees)
    global brick
    
    startAngle = brick.GyroAngle(2);
    disp('printing start angle');
    disp(startAngle);
    
    if ~isnan(startAngle)
        endAngle = startAngle + degrees;

        while brick.GyroAngle(2) <= endAngle
            brick.MoveMotor('A', -30);
            brick.MoveMotor('B', 30);
        end
        brick.WaitForMotor('AB');

        updateOrientation(degrees);

        brick.StopAllMotors();
    else
        disp('startAngle is nan');
    end
end

function turnLeft(degrees)
    global brick
    
    startAngle = brick.GyroAngle(2);
    endAngle = startAngle - degrees;
    
    brick.MoveMotor('A', 30);
    brick.MoveMotor('B', -30);

    while brick.GyroAngle(2) >= endAngle
    end

    % update orientation, if we ever use this
    
    brick.StopAllMotors();
end

% pickup/dropoff

function pickup
    global brick
    brick.MoveMotorAngleRel('C', 30, 45, 'Brake');
end

function dropoff
    global brick
    brick.MoveMotorAngleRel('C', 30, -45, 'Brake');
end

% get sensor values

function dist = getDist
    global brick
    dist = brick.UltrasonicDist(3);
end

function angle = getAngle
    global brick
    angle = brick.GyroAngle(2);
end

function color = getColor
    global brick
    color = brick.ColorRGB(1);
end

% maze functions

function atEnd = isAtEnd(row, column)
    atEnd = (row == 1 || row == 3) && (column == 1 && column == 7);
end

function dirs = dirsToEval(row, column)
    global directions
    
    directions = ['N' 'E' 'S' 'W'];

    if row == 1
        directions(directions=='N') = [];
    elseif row == 3
        directions(directions=='S') = [];
    end
    
    if column == 1
        directions(directions=='W') = [];
    elseif column == 6
        directions(directions=='E') = [];
    end
    
    dirs = directions;
end

function evalDirs(dirs)
    global orientation

    if ismember(orientation, dirs)
        disp(strcat("checking ", orientation));
        disp(getDist());
        dirs(dirs==orientation) = [];
    end
    
    for dir=dirs
        degrees = toDeg(dir) - toDeg(orientation);
        disp('turning ');
        disp(degrees);
        turnRight(degrees);
        disp(getDist());
    end
end


function deg = toDeg(orientation)
    switch orientation
        case 'N'
            deg = 0;
        case 'E'
            deg = 90;
        case 'S'
            deg = 180;
        case 'W'
            deg = 270;
    end
end
