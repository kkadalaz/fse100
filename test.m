turnRight(brick, 90)

function turnRight(brick, degrees)
    
    startAngle = brick.GyroAngle(2);
    disp('printing start angle');
    startAngle
    
    if ~isnan(startAngle)
        endAngle = startAngle + degrees;

        endAngle
        
        while brick.GyroAngle(2) <= endAngle
            brick.GyroAngle(2)
            brick.MoveMotor('A', -30);
            brick.MoveMotor('B', 30);
        end
        disp('exited loop')
 
%        updateOrientation(degrees);

        disp('past wait')
        brick.StopAllMotors();
    else
        disp('startAngle is nan');
    end
end