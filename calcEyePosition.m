function rEye = calcEyePosition(I1, I2, vis)
    fprintf('Calculating right eye position using RANSAC...');
%% Configuration
    h = double(size(I1,1)) / 2;
    w = double(size(I1,2)) / 2;
    FEATURE_NUM = uint16(0.4*w);
    BLUR_STD = w * 1.5 / 250;
    WINDOW_STD = w / 500;
    ALPHA = 0.04;
    RADIUS = w * 20 / 250;
    MIN_INL = 0;
    THRESH_ERROR = 0;
    if w <= 300
        MIN_INL = 10;
        THRESH_ERROR = 10;
    elseif w <= 600
        MIN_INL = 20;
        THRESH_ERROR = 100;
    end;
    rEye(1) = 100.0;

%% Calculate Harris corner feature points
    [~, ~, F1_list, P1_list] = ...
        calcResponse(I1, BLUR_STD, WINDOW_STD, ALPHA, RADIUS, FEATURE_NUM);
    [~, ~, F2_list, P2_list] = ...
        calcResponse(I2, BLUR_STD, WINDOW_STD, ALPHA, RADIUS, FEATURE_NUM);
    dist = calcFeatureDistance(P1_list, P2_list, 'ssd');

%% Find putable matches.
    [~, match] = max(dist, [], 2);
    [~, match2] = max(dist, [], 1);
    ind = 1 : FEATURE_NUM;
    cand_set = ind((match2(match) == ind));
    fp1 = double(F1_list(cand_set,:));
    fp2 = double(F2_list(match(cand_set), :));
    fy = rEye(1)*(fp1(:,2)-fp2(:,2))./(fp1(:,1)-fp2(:,1));
    fx = ((fp2(:,1)-w).*(fp1(:,2)-h) - ...
          (fp1(:,1)-w).*(fp2(:,2)-h)) ./ ...
          (fp1(:,1)-fp2(:,1));
    legal = abs(fx) ~= Inf & abs(fy) ~= Inf;
    fx = fx(legal);
    fy = fy(legal);

%% RANSAC
    minError = 1e10;
    minB = [0,0]';
    minInl = 1;
    for i = 1 : length(fx)
        for j = i+1 : length(fx)
            if fx(i) == fx(j) 
                continue;
            end;
            b = regress(fy([i,j]),[1 fx(i); 1 fx(j)]);
            ey = b(1) + b(2) * fx;
            err = (ey-fy).^2;
            inl = err < THRESH_ERROR;
            if sum(inl) > max(MIN_INL, 0.1*length(fx));
                [b,~,r] = regress(fy(inl), [ones(sum(inl),1) fx(inl)]);
                err = sum(r.^2)/length(r);
                if err < minError
                    minError = err;
                    minB = b;
                    minInl = inl;
                end;
            end;
        end;
    end;
    
    rEye(2:3) = minB';
    
%% Visualization
    if strcmp(vis, 'v')
        plot(fx,fy,'.');
        hold on;
        x = [min(fx), max(fx)];
        y = minB(1) + minB(2)*x;
        plot(x,y,'-r');
        hold off;

        Ia = zeros(2*size(I1,1), size(I1,2), 'uint8');
        Ia(1:size(I1,1), :) = I1;
        Ia(size(I1,1)+1:end, :) = I2;
        figure;imshow(Ia);hold on;
        pp1 = fp1(minInl,:);
        pp2 = fp2(minInl,:);
        for i = 1 : size(pp1,1)
            p1 = pp1(i,:);
            p2 = pp2(i,:);
            p2(2) = p2(2) + 2*h;
            l = line([p1(1),p2(1)],[p1(2),p2(2)]);
            plot(l);
        end;
        hold off;
    end;
    fprintf('done.\n');
    disp(['Right eye coordinate: [' num2str(rEye) '], minimum error: ' ...
          num2str(minError) ', inliers: ' num2str(sum(minInl))]);
end
