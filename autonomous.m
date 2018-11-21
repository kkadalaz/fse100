
% initMaze();
% setupEV3(brick);
solveMaze(brick);

function setupEV3(brick)
    disp('setting up robot');

    brick.SetColorMode(3, 4); % RGB mode
    brick.GyroCalibrate(2);
    
    disp('robot set up');
end

function initMaze
    disp('initializing maze');

    global maze
    global row
    global column
    global orientation

    maze = zeros(3, 6);
    maze

%    row = input('Row: ');
%    column = input('Column: ');
%    orientation = input('Orientation: ', 's');

    row = 3;
    column = 1;
    orientation = 'N';

    maze(row, column) = 1;

%    disp(maze);
%    dirs = dirToEval(row, column);

%    evalDirs(brick, dirs, orientation)
%    disp(isAtEnd(row, column));

    disp('maze initialized');
end

function solveMaze(brick)
    global maze
    global row
    global column
    global orientation

    disp('solving maze');
    
    complete = false;

    while ~complete
        color = getColor(brick);

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
            keyboardControl(brick);
        else
            disp('oof, in algorithm');

            dirs = dirsToEval(row, column);
            evalDirs(brick, orientation, dirs);
            % getDist(brick)
            complete = true;
        end
    end
end

% keyboard controls

function keyboardControl(brick)
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

% turn functions

function turnRight(brick, degrees)
    
    startAngle = brick.GyroAngle(2);
    disp('printing start angle');
    startAngle
    
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

function turnLeft(brick, degrees)
    startAngle = brick.GyroAngle(2);
    endAngle = startAngle - degrees;
    
    brick.MoveMotor('A', 30);
    brick.MoveMotor('B', -30);

    while brick.GyroAngle(2) >= endAngle
    end

    % update orientation, if we ever use this
    
    brick.StopAllMotors();
end

function updateOrientation(degrees)
    global orientation
    global directions
    
    wrap = degrees / 90;
    position = find(directions==orientation);
    repeat = ceil((wrap + position) / 4);
    wrapped = repmat(directions, 1, repeat);
    orientation = wrapped(position + wrap);
end

% pickup/dropoff

function pickup(brick)
    brick.MoveMotorAngleRel('C', 30, 45, 'Brake');
end

function dropoff(brick)
    brick.MoveMotorAngleRel('C', 30, -45, 'Brake');
end

% get sensor values

function dist = getDist(brick)
    dist = brick.UltrasonicDist(3);
end

function angle = getAngle(brick)
    angle = brick.GyroAngle(2);
end

function color = getColor(brick)
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

function evalDirs(brick, orientation, dirs)

    if ismember(orientation, dirs)
        orientation
        disp('ultrasonic:')
        getDist(brick)
        dirs(dirs==orientation) = [];
    end
    
    for dir=dirs
        degrees = toDeg(dir) - toDeg(orientation);
        disp('turning ');
        degrees
        turnRight(brick, degrees);
        getDist(brick)
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
