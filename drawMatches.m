function drawMatches(I1, I2, depthI, x, y, mapX, mapY)
    h = double(size(I1,1)) / 2;
    w = double(size(I1,2)) / 2;
    
    Ia = zeros(4*h, 2*w, 'uint8');
    Ia(1 : 2*h, :) = I1;
    Ia(2*h+1 : end, :) = I2;
    figure;imshow(Ia);hold on;
    for i = 1 : length(x)
        tx = mapX(y(i), x(i));
        ty = mapY(y(i), x(i));
        ty = ty + 2*h;
        l = line([x(i), tx], [y(i),ty]);
        plot(l);
    end;
    hold off;
end