function [I1, I2] = readImage(filename1, filename2)
    IMAGE_WIDTH = 500.0;

    fprintf('Reading and processing images...');
    I1 = rgb2gray(imread(filename1));
    I2 = rgb2gray(imread(filename2));
    I1 = imresize(I1, IMAGE_WIDTH/size(I1,2));
    I2 = imresize(I2, IMAGE_WIDTH/size(I2,2));
    fprintf('done.\n');
end