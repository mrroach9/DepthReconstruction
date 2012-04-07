function nDepthI = expandReliableArea(depthI, match_struct, rEye)
    w = double(size(depthI, 2))/2;
    h = double(size(depthI, 1))/2;
    WINDOW_SIZE = w / 25;
    GAP_SIZE = w / 125;
    
    margin = WINDOW_SIZE + GAP_SIZE;
    x_range = uint16(max(1 + margin, 0.3*w) : 2*w - margin);
    y_range = uint16(margin + 1 : 2*h - margin);
    x_start = max(1 + margin, 0.3*w);
    y_start = margin + 1;
   
    dx = [0 1 0 -1];
    dy = [1 0 -1 0];
    
    for x = x_range
        for y = y_range
            if match_struct(y,x).rel < 0.2
                depthI(y,x) = -1;
            end;
        end;
    end;        
    
    nDepthI = depthI;
    
    fprintf('Expanding reliable area...\n');
    figure;imshow(nDepthI, [0, max(max(nDepthI))]);
    pause(0.1);
    
    change = true;
    while change
        change = false;
        [yp, xp] = find(depthI(y_range, x_range) < -0.1);
        yp = double(yp) + y_start - 1;
        xp = double(xp) + x_start - 1;
        for i = 1 : length(xp)
            x = uint16(xp(i));
            y = uint16(yp(i));
            x_offset = match_struct(yp(i),xp(i)).match_x_offset;
            xm = ((xp(i)-w) - rEye(1)) ./ (1 - rEye(3)) + w - GAP_SIZE;
            xm = max(margin + 1, xm);
            xM = xp(i) + GAP_SIZE;
            accept = false;
            for j = 1 : 4
                if depthI(y+dy(j), x+dx(j)) < 0
                    continue;
                end;
                accept = true;
                mapx = match_struct(y+dy(j), x+dx(j)).mapx;
                xm = uint16(max(mapx - dx(j) - 1, xm));
                xM = uint16(min(mapx - dx(j) + 1, xM));
            end;
            if ~accept 
                continue;
            else
                change = true;
            end;
            xm = xm + 1 - x_offset;
            xM = xM + 1 - x_offset;
            xm = max(1, xm);
            xM = min(xM, length(match_struct(yp(i),xp(i)).match));
            match_range = xm : xM;
            if isempty(match_range)
                [~, mapx] = max(match_struct(yp(i),xp(i)).match);
            else
                [~, mapx] = max(match_struct(yp(i),xp(i)).match(match_range));
            end;
                
            mapx = double(mapx) + double(x_offset) + double(xm) - 2;
            d = ((mapx-w)*rEye(3) - rEye(1)) / (mapx - xp(i));
            if isempty(match_range)
                nDepthI(y,x) = -1;
            else
                nDepthI(y,x) = max(min(1, 1/d), 0);
            end;
        end;
        depthI = nDepthI;
        imshow(nDepthI, [0, max(max(nDepthI))]);
        pause(0.1);
    end;
end