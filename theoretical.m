

setupEV3(brick)
    
while 1
    
    % added this one line of code
    getColor(brick);
    color = getColor(brick)
end

function setupEV3(brick)
    disp('setting up robot');

    brick.SetColorMode(3, 2);

    getColor(brick)
    getColor(brick)
%    getDist(brick)
%    getDist(brick)

    disp('robot set up');
end

function color = getColor(brick)
    color = brick.ColorCode(1);
end