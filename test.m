
% gyro();

% function gyro
%     global brick

%     while 1
%         brick.GyroAngle(2)
%     end
% end

% function angle = getAngle
%     global brick
%     angle = brick.GyroAngle(2);
% end

% driveStraight(brick, 360)
% turnRight(brick, 90)
% brick.UltrasonicDist(3)
% turnLeft(brick, 180)
% brick.UltrasonicDist(3)

distances = collectDistances(brick)
choosePath(distances)


function path = choosePath(distances)
    front = distances(1);
    right = distances(2);
    left = distances(3);

    fprintf('front distance: %f\n', front);
    fprintf('right distance: %f\n', right);
    % fprintf('left distance: %f\n', left);

    if right <= 15
        % wall is to the right
        path = 'straight';
        if front <= 15
            % wall is also to the front, turn left
            path = 'left';
        end
    else
        % wall is not to the right
        path = 'right';
    end

end

% command groups

function distances = collectDistances(brick)
    front = brick.UltrasonicDist(3);
    turnRight(brick, 90);
    right = brick.UltrasonicDist(3);
    % turnLeft(brick, 180);
    % left = brick.UltrasonicDist(3);

    distances = [front right];
end

% motor commands

function driveStraight(brick, distance)
    disp('entering driveStraight')

    fprintf('starting location: %d\n', brick.GetMotorAngle('A'));

    brick.MoveMotorAngleRel('AB', 100, distance, 'Coast');
    brick.WaitForMotor('AB');

    fprintf('ending location: %d\n', brick.GetMotorAngle('A'));

    disp('exiting driveStraight')
end

function turnRight(brick, degrees)
    disp('entering turnRight');

    startAngle = brick.GyroAngle(2);
    fprintf('current angle: %d\n', startAngle)
    fprintf('turning right %d degrees\n', degrees);
    
    if ~isnan(startAngle)
        endAngle = startAngle + degrees;

        fprintf('turning to %d degrees\n', endAngle);

        while brick.GyroAngle(2) <= endAngle
            brick.MoveMotor('A', -30);
            brick.MoveMotor('B', 30);
        end

        fprintf('current angle: %d degrees\n', brick.GyroAngle(2));

        brick.StopAllMotors();
    else
        disp('startAngle is nan');
    end

    disp('exiting turnRight');
end

function turnLeft(brick, degrees)
    disp('entering turnLeft');

    startAngle = brick.GyroAngle(2);
    fprintf('current angle: %d\n', startAngle)
    fprintf('turning left %d degrees\n', degrees);
    
    if ~isnan(startAngle)
        endAngle = startAngle - degrees;

        fprintf('turning to %d degrees\n', endAngle);

        while brick.GyroAngle(2) >= endAngle
            brick.MoveMotor('A', 30);
            brick.MoveMotor('B', -30);
        end

        fprintf('current angle: %d degrees\n', brick.GyroAngle(2));

        brick.StopAllMotors();
    else
        disp('startAngle is nan');
    end

    disp('exiting turnRight');
end