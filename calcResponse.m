function [R_pick, R_image, F_list, patch_list] = ...
         calcResponse(image, image_std, win_std, alpha, radius, point_num)
% The function calculates response image R given the input image I, by 
% first calculating Gaussian derivitive of the image Ix, Iy, then calculate
% matrix M using Gaussian window on each pixel. Finally calculating 
% R = det(M) - alpha * trace(M)^2 with thresholding to obtain response
% image.
% Parameters:
%   image               input image.
%   image_std           std. deviation for Gaussian derivitive.
%   win_std             std. deviation for Gaussian windowing.
%   alpha               constant for calculating response value.
%   radius              used in non-maxima supression.
%   point_num           number of points selected as features.

PATCH_RAD = 10;
image = double(image);
image = image / 255.0;

%% Calculate Gaussian derivitive
x = -3 * image_std : 3 * image_std;
dx = -x .* exp(-x.*x/(2*image_std^2)) / (sqrt(2*pi)*image_std^3);
dy = dx';
Ix = imfilter(image, dx, 'same', 'symmetric', 'conv');
Iy = imfilter(image, dy, 'same', 'symmetric', 'conv');

%% Calculate M matrix
X = gausswin(2 * ceil(3*win_std) + 1, 3);
win = X*X';
win = win / sum(sum(win));
M(1,1,:,:) = imfilter(Iy.^2, win, 'same', 'symmetric', 'conv');
M(1,2,:,:) = imfilter(Ix.*Iy, win, 'same', 'symmetric', 'conv');
M(2,1,:,:) = M(1,2,:,:);
M(2,2,:,:) = imfilter(Ix.^2, win, 'same', 'symmetric', 'conv');

%% Calcualte response image with thresholding
imR = zeros(size(M,3), size(M,4), 'double');
for i = 1 : size(M,3)
    for j = 1 : size(M,4)
        imR(i,j) = det(M(:,:,i,j)) - alpha * trace(M(:,:,i,j))^2;
    end;
end;
imR = imR / max(max(imR));
imR(imR < 0) = 0;
R_image = imR;

%% Non-maxima supression with radius
pr = PATCH_RAD;
pd = pr * 2 + 1;
R = zeros(size(imR), 'double');
F_list = zeros(point_num, 2, 'uint32');
patch_list = zeros(pd, pd, point_num, 'uint8');
for i = 1 : point_num
    [m, col] = max(imR);
    [~, x] = max(m);
    y = col(x);
    R(y,x) = imR(y,x);
    F_list(i,:) = [x y];
    imR(max(y - radius, 1) : min(size(R, 1), y + radius), ...
        max(x - radius, 1) : min(size(R, 2), x + radius)) = 0;
    
    A = M(:,:,y,x);
    [U, ~, ~] = svd(A);
    d = eig(A);
    d = d*pr/min(d);
    patch = zeros(pd,pd,'uint8');
    for ty = 1 : pd
        for tx = 1 : pd
            p = U * (d.*(([ty; tx]-pr-1)/pr));
            p = int16(p' + double([y,x]));
            if p(1) > 0 && p(1) <= size(image,1) && ...
               p(2) > 0 && p(2) <= size(image,2)
                patch(ty,tx) = 255*image(p(1),p(2));
            end;
        end;
    end;
    meany = sum(sum(double(patch).*repmat((1:pd)',1,pd))) / ...
            sum(sum(double(patch)));
    if (meany > pr+1)
        patch = imrotate(patch, 180);
    end;
    patch_list(:,:,i) = patch;
end;
R_pick = R;
end



