function distImage = calcFeatureDistance(P1, P2, method)

% The function calculates the distance of all features between two images
% with given feature lists, using either SSD distance or NCC distance given
% in method argument. P1 and P2 are both m*m*k matrix where k is the number
% of features in both images calculated in calcResponse method and m is the
% size of patches.
% The return value is a k*k grayscale image in which the pixel (i,j)
% indicates the distance of feature #i in image #1 and feature #j in image
% #2.
%
% Parameters:
%   P1, P2              Input feature patches for I1 and I2. Must have the
%                       same sizes.
%   rad                 Radius of patches used to calculate distance.
%   method              Either 'ssd' or 'ncc'.

f_num = size(P1, 3);
distImage = zeros(f_num, 'double');

%% Preprocessing
P1 = double(P1)/255.0;
P2 = double(P2)/255.0;
sqr_list = zeros(2, f_num, 'double');
for i = 1 : f_num
    P1(:,:,i) = P1(:,:,i) - mean(mean(P1(:,:,i)));
    P2(:,:,i) = P2(:,:,i) - mean(mean(P2(:,:,i)));
    sqr_list(1, i)  = sum(sum(P1(:,:,i).^2));
    sqr_list(2, i)  = sum(sum(P2(:,:,i).^2));
end;
    
%% Calculating SSD and NCC distances
for i = 1 : f_num
    for j = 1 : f_num
        if strcmp(method, 'ssd')
            distImage(i,j) = ...
                1 / double(sum(sum((P1(:,:,i) - P2(:,:,j)).^2)));
        elseif strcmp(method, 'ncc')
            distImage(i,j) = ...
                sum(sum(P1(:,:,i).*P2(:,:,j))) / ...
                sqrt(sqr_list(1,i) * sqr_list(2,j));
        end;
    end;
end;
if strcmp(method,  'ssd')
    distImage(distImage > 10) = 10;
    distImage = sqrt(distImage);
    distImage = distImage / max(max(distImage));
end;
end