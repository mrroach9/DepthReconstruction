function [depthI, match_struct] = calcDepthImage(I1, I2, rEye, vis)
%% Configuration
    h = double(size(I1,1)) / 2;
    w = double(size(I1,2)) / 2;
    WINDOW_SIZE = w / 25;
    GAP_SIZE = w / 125;
    
    margin = WINDOW_SIZE + GAP_SIZE;
    x_range = double(max(1 + margin, 0.3*w) : 2*w - margin);
    y_range = double(margin + 1 : 2*h - margin);
    x_start = max(1 + margin, 0.3*w);
    y_start = uint16(margin + 1);
    
    depthI = -ones(size(I1), 'double');
    match_struct = struct('x', cell(size(I1)), 'y', 0, 'depth', 0.0, ...
                          'mapx', 0, 'mapy', 0, ...
                          'rel', 0.0, 'match', [], ...
                          'match_x_offset', 0, 'match_y_offset', 0);

%% Calculate depth image.
    fprintf('Calculating depth image...\n');
    figure;
    for xp = x_range
        for yp = y_range
            y = uint16(yp);
            x = uint16(xp);
            
            xt = ((xp-w) - rEye(1)) ./ (1 - rEye(3)) + w;
            yt = ((yp-h) - rEye(2)) ./ (1 - rEye(3)) + h;
            xt = max(margin + 1, xt);
            yt = max(margin + 1, yt);
             
            w1 = double(I1(yp - WINDOW_SIZE : yp + WINDOW_SIZE ,...
                           xp - WINDOW_SIZE : xp + WINDOW_SIZE));
            w2 = double(I2(yt - margin : yp + margin , ...
                           xt - margin : xp + margin));
            match = normxcorr2(w1, w2);
            match = match(2 * WINDOW_SIZE + 1 : 2*margin + 1 + yp-yt, ...
                          2 * WINDOW_SIZE + 1 : 2*margin + 1 + xp-xt);
            [maxRowMatch, row] = max(match, [], 1);
            [~, col] = max(maxRowMatch);
            mx = double(col) - GAP_SIZE + xt - 1;
            my = double(row(col)) - GAP_SIZE + yt - 1;
            maxDepth = ((mx-w)*rEye(3) - rEye(1)) / ...
                       (double(mx) - xp);
            
            match_struct(y, x).x = x;
            match_struct(y, x).y = y;
            match_struct(y, x).match = maxRowMatch;
            match_struct(y, x).match_x_offset = uint16(xt - GAP_SIZE);
            match_struct(y, x).match_y_offset = uint16(yt - GAP_SIZE);
            match_struct(y, x).depth = maxDepth;
            match_struct(y, x).mapx = uint16(mx);
            match_struct(y, x).mapy = uint16(my);
            match_struct(y, x).rel = reliability(maxRowMatch);
            
            depthI(y, x) = min(1, 1/maxDepth);
        end;
        fprintf('\t%d/%d\n', xp - x_start, length(x_range));
       
        imshow(depthI, [0, max(max(depthI))]);
        pause(0.01);
    end;
 
%% Visualization
    if strcmp(vis, 'v')
        figure;imshow(depthI, [0, max(max(depthI))]);
        figure;imshow(relI, [0, 1]);
        x = randi(2*w, 20, 1);
        y = randi(2*h, 20, 1);
        Ia = zeros(2*size(I1,1), size(I1,2), 'uint8');
        Ia(1 : size(I1,1), :) = I1;
        Ia(size(I1,1)+1:end, :) = I2;
        figure;imshow(Ia);hold on;
        for i = 1 : 20
            tx = mapX(y(i),x(i));
            ty = mapY(y(i),x(i));
            if tx == 0 || ty == 0
                continue;
            end;
            ty = ty + 2*h;
            l = line([x(i), tx], [y(i),ty]);
            plot(l);
        end;
        hold off;
    end;
end