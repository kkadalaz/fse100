
initMaze();
setupEV3(brick);
solveMaze(brick);

function setupEV3(brick)
    disp('setting up robot');

    brick.SetColorMode(3, 4); % RGB mode
    brick.GyroCalibrate(2);

    getDist(brick)
    getDist(brick)
    getAngle(brick)
    getAngle(brick)
    
    disp('robot set up');
end

function initMaze
    disp('initializing maze');

    global maze
    global row
    global column
    global orientation

    maze = zeros(3, 6);

%    row = input('Row: ');
%    column = input('Column: ');
%    orientation = input('Orientation: ', 's');

    row = 3;
    column = 1;
    orientation = 'N';

    maze(row, column) = 1;

%    disp(maze);
%    dirs = dirToEval(row, column);

%    getMaxDir(brick, dirs, orientation)
%    disp(isAtEnd(row, column));

    disp('maze initialized');
end

function solveMaze(brick)
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

 %       if red >= green + blue
 %           disp('in red square');
 %           pause(2);
 %       elseif green >= red + blue
 %           disp('in green square');
 %           disp('terminating solveMaze()');
 %           complete = true;
 %       elseif blue >= green + red
 %           disp('in blue square');
 %           keyboardControl(brick);
 %       else
            disp('oof, in algorithm');

            dirs = dirsToEval(row, column);
            maxDir = getMaxDir(brick, dirs);
            degrees = resolveOrientation(maxDir, orientation)
            turnRight(brick, degrees);
            driveStraight(brick);
            
            complete = true;
 %       end
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

function driveStraight(brick)
    brick.MoveMotorAngleRel('AB', 50, 360, 'Coast');
    brick.WaitForMotor('AB');
end

function turnRight(brick, degrees)
    turn = degrees * 2;

    startAngle = brick.GyroAngle(2);

    brick.MoveMotorAngleRel('A', 30, -turn, 'Coast');
    brick.MoveMotorAngleRel('B', 30, turn, 'Coast');
    brick.WaitForMotor('AB');

    disp('diffAngle')
    brick.GyroAngle(2) - startAngle
    
    updateOrientation(degrees);
end

function updateOrientation(degrees)
    global orientation
    
    directions = ['N' 'E' 'S' 'W'];
    
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
%    directions = {'N', 'E', 'S', 'W'};
%    directions = ['N', 'E', 'S', 'W'];
    directions = 'NESW';

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

function maxDir = getMaxDir(brick, dirs)
    global orientation

    keyset = dirs;
    valueset = [];

    if ismember(orientation, dirs)
        valueset = [valueset, getDist(brick) ];
        dirs(dirs==orientation) = [];
    end
    
    for dir=dirs
        disp('in evalDirs');
        
        degrees = toDeg(dir) - toDeg(orientation);
        disp('turning');
        degrees
        turnRight(brick, degrees);
        valueset = [valueset, getDist(brick) ];
    end
 
    valueset
    
    map = containers.Map(cellstr(keyset')', valueset);

    k = keys(map);
    v = values(map);

    value = max(valueset);
    index = cellfun(@(x)isequal(x, value), v);
    maxDir = char(k(index))
end

function degrees = resolveOrientation(dir, nextDir)
    degrees = toDeg(dir) - toDeg(nextDir);
end

function deg = toDeg(dir)
    switch dir
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
