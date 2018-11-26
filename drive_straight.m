global stat

setupEV3(brick);
driveStraight(brick);

function setupEV3(brick)
    disp('setting up robot');

    brick.SetColorMode(3, 4); % RGB mode

    getColor(brick)
    getColor(brick)
%    getDist(brick)
%    getDist(brick)

    disp('robot set up');
end

function driveStraight(brick)
    global stat
    brick.StopAllMotors('Brake');

    brick.MoveMotorAngleRel('AB', 75, 1080, 'Coast');
    
    
    disp('started timer');
    t = timer('TimerFcn', 'stat=false; disp(''Timer!''); stat', 'StartDelay', 2.5);
    start(t);
    stat = true;
    
    while(stat)
       color = getColor(brick);
        pause(1);
        red = color(1);
        green = color(2);
        blue = color(3);
        stat
        
      if red >= green + blue
           disp('in red square')
           brick.StopAllMotors('Brake');
           pause(2);
           
       elseif green >= red + blue
           disp('in green square');
           disp('terminating solveMaze()');
           break;
       elseif blue >= green + red
           disp('in blue square');
           keyboardControl(brick);
      end
    end
    disp('ended timer');
    delete(t);
    
    brick.WaitForMotor('AB');
end


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

function color = getColor(brick)
    color = brick.ColorRGB(1);
end