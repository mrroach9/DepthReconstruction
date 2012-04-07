%clear all;
warning off;
%[I1, I2] = readImage('left.jpg', 'right.jpg');
%rEye = calcEyePosition(I1, I2, 'n');
[depthI, match_struct] = calcDepthImage(I1, I2, rEye,'n');
%   depthI = expandReliableArea(depthI, match_struct, rEye);

% x = [184, 600]/2;
% y = [518, 370]/2;
% drawFeasibleArea(I1,I2,x,y,rEye);
% drawMatches(I1,I2,depthI, x,y,mapX,mapY);