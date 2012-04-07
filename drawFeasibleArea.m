function drawFeasibleArea(I1, I2, x, y, rEye)
    h = double(size(I1,1)) / 2;
    w = double(size(I1,2)) / 2;
    WINDOW_SIZE = w / 25;
    GAP_SIZE = w / 125;
    
    feasible_area1 = repmat(false, size(I1));
    feasible_area2 = repmat(false, size(I2));
    for i = 1 : length(x)
        d = [1,30];
        xt = ((x(i)-w)*d - rEye(1)) ./ (d - rEye(3)) + w;
        yt = ((y(i)-h)*d - rEye(2)) ./ (d - rEye(3)) + h;
        xt(1) = max(WINDOW_SIZE + 1, xt(1));
        yt(1) = max(WINDOW_SIZE + GAP_SIZE + 1, yt(1));
        feasible_area2( ...
            yt(1)-WINDOW_SIZE-GAP_SIZE : yt(2) + WINDOW_SIZE+GAP_SIZE,...
            xt(1) - WINDOW_SIZE : xt(2) + WINDOW_SIZE) = true;
        
        feasible_area1(y(i) - WINDOW_SIZE : y(i) + WINDOW_SIZE,...
                       x(i) - WINDOW_SIZE : x(i) + WINDOW_SIZE) = true;
    end;
    
    Ia = zeros(4*h, 2*w, 'uint8');
    tI1 = I1(1 : 2*h, 1 : 2*w);
    tI2 = I2(1 : 2*h, 1 : 2*w);
    tI1(~feasible_area1) = 0;
    tI2(~feasible_area2) = 0;
    Ia(1 : 2*h, :) = tI1;
    Ia(2*h+1 : 4*h, :) = tI2;
    figure;imshow(Ia);
end