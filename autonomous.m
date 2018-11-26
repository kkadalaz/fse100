
initMaze();
setupEV3(brick);
solveMaze(brick);

function setupEV3(brick)
    disp('setting up robot');

    brick.SetColorMode(3, 2);

    getColor(brick)
    getColor(brick)
    getDist(brick)
    getDist(brick)

    disp('robot set up');
end

function initMaze
    disp('initializing maze');

    global maze
    global row
    global column
    global orientation

    maze = zeros(3, 6);

    row = input('Row: ');
    column = input('Column: ');
    orientation = input('Orientation: ', 's');


%    maze(row, column) = 1;

    disp('maze initialized');
end

function solveMaze(brick)
    global maze
    global row
    global column
    global orientation

    disp('solving maze');
    
    complete = false;
    directionArray = [];
    iterations = 0;
    wheelchair = false;

    while ~complete
    
        % added this one line of code
        getColor(brick);

        color = getColor(brick);

        if color == 5
           disp('in red square')
           pause(2);
        elseif (color == 3 && wheelchair) 
           disp('in green square');
           disp('terminating solveMaze()');
           
           dropoff(brick)
           dropoff(brick)

           complete = true;
       elseif color == 2
           disp('in blue square');
           keyboardControl(brick);
           wheelchair = true;

           row = input('Row: ');
           column = input('Column: ');
           orientation = input('Orientation: ', 's');
        else

            disp('evaluating directions');
            dirs = dirsToEval(row, column, maze);
            values = getValues(brick, dirs);
            disp('done evaluating directions');
            disp('distances');

            values

            maze

            if(isempty(values) || isempty(values(values > 35)))
                disp('backtracking');
                backtracking = true;
                while(backtracking)

                   % find and remove direction
                   disp('last direction traversed');
                   dir = directionArray(end)
                   directionArray(end) = [];

                   % switch direction
                   if(dir == "N")
                    dir = "S";
                   elseif (dir == "S")
                    dir = "N";
                   elseif (dir == "E")
                    dir = "W";
                   elseif (dir == "W")
                    dir = "E";
                   end

                   % go backwards
                   degrees = resolveOrientation(dir, orientation);
                   turnRight(brick, degrees);
                   driveStraight(brick);
                   maze(row, column) = 1;
                   updateRowCol(dir)

                   % search for adjacent unvisited cells
                   disp('dirs to evaluate');
                   dirs = dirsToEval(row, column, maze)
                   disp('distances');
                   values = getValues(brick, dirs)

                   % if there is an adjacent unvisted cell and it is not a
                   % wall
                   if(~isempty(values) && ~isempty(values(values > 35)))
                       disp('adjacent unvisited cell');

                       maxDir = getMaxDir(dirs, values);
                       degrees = resolveOrientation(maxDir, orientation);
                       turnRight(brick, degrees); 
                       driveStraight(brick);
                       maze(row, column) = 1;
                       directionArray = [directionArray, maxDir];
                       updateRowCol(maxDir);

                       disp('done backtracking');
                       backtracking = false;
                   end               
                end
            else
                disp('not backtracking');

                maxDir = getMaxDir(dirs, values);
                disp('maxDir');
                maxDir

                degrees = resolveOrientation(maxDir, orientation);
                turnRight(brick, degrees); 
                driveStraight(brick);

                % make sure to update Row/Col variable/DirectionArray/visitedCells
                maze(row, column) = 1;
                directionArray = [directionArray, maxDir];
                updateRowCol(maxDir);
        end            
        end
        % test end condition
        iterations = iterations + 1;
        if(iterations == 100)
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

function driveStraight(brick)
    brick.StopAllMotors('Brake');
    pause(1);
    brick.MoveMotorAngleRel('AB', 75, 1080, 'Coast');
    brick.WaitForMotor('AB');
end

function turnRight(brick, degrees)
    turn = degrees * 2;

    startAngle = brick.GyroAngle(2);

    brick.MoveMotorAngleRel('A', 30, -turn, 'Coast');
    brick.MoveMotorAngleRel('B', 30, turn, 'Coast');
    brick.WaitForMotor('AB');

%    disp('diffAngle')
%    brick.GyroAngle(2) - startAngle
    
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

function color = getColor(brick)
    color = brick.ColorCode(1);
end

% maze functions

function atEnd = isAtEnd(row, column)
    atEnd = (row == 1 || row == 3) && (column == 1 && column == 7);
end

function dirs = dirsToEval(row, column, maze)
    directions = 'NESW';

    if row == 1
        directions(directions=='N') = [];
    else
        if maze(row - 1, column) == 1
            directions(directions=='N') = [];
        end
    end
            
    if row == 3
        directions(directions=='S') = [];
    else
        if maze(row + 1, column) == 1
            directions(directions=='S') = [];
        end
    end
    
    if column == 1
        directions(directions=='W') = [];
    else
        if maze(row, column - 1) == 1
            directions(directions=='W') = [];
        end
    end
    
    if column == 6
        directions(directions=='E') = [];
    else
        if maze(row, column + 1) == 1
            directions(directions=='E') = [];
        end
    end
    
    dirs = directions;
end

function maxDir = getMaxDir(dirs, valueset)

    keyset = dirs;
    map = containers.Map(cellstr(keyset')', valueset);

%    disp('keyset')
%    keyset

%    disp('valueset')
%    valueset

    
    k = keys(map);
    v = values(map);

    value = max(valueset);
    index = cellfun(@(x)isequal(x, value), v);
    maxDir = char(k(index));
end


function values = getValues(brick, dirs)
    global orientation
    valueset = [];
    
    if (~isempty(dirs))
%        if ismember(orientation, dirs)
%            valueset = [valueset, getDist(brick) ];
%            dirs(dirs==orientation) = [];
%        end

        for dir=dirs
%            disp('in evalDirs');

            degrees = toDeg(dir) - toDeg(orientation);
%            disp('turning');
%            degrees
            turnRight(brick, degrees);
            valueset = [valueset, getDist(brick)];
        end
    end
 
    values = valueset;
end

function degrees = resolveOrientation(dir, nextDir)
    degrees = toDeg(dir) - toDeg(nextDir);
end

function updateRowCol(dir)
    global row
    global column
    
    if(dir == "N")
        row = row - 1;
    elseif (dir == "S")
        row = row + 1;
    elseif (dir == "E")
        column = column + 1;
    elseif (dir == "W")
        column = column - 1;
    end
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
        otherwise
            disp('in toDeg. printing input');
            deg
    end
end
