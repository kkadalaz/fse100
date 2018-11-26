global stat
stat = true;
driveStraight(brick);


function driveStraight(brick)
    global stat
    brick.MoveMotorAngleRel('AB', 75, 1080, 'Coast');
    t = timer('TimerFcn', 'stat=false; disp(''Timer!'');stat', 'StartDelay',5);
    start(t)

    stat=true;
    while(stat==true)
       color = getColor(brick);

       red = color(1);
       green = color(2);
       blue = color(3);
      disp('.')
      stat
      pause(1)


      if red >= green + blue
               disp('in red square');
               pause(2);
      elseif green >= red + blue
               disp('in green square');
               disp('terminating solveMaze()');
               break;
      elseif blue >= green + red
               disp('in blue square');
               keyboardControl(brick);
      else
          disp('xD');

      end

    end
    delete(t)
end

    

function color = getColor(brick)
    color = brick.ColorRGB(1);
end