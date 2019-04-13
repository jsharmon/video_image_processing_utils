%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepared by Jonah Harmon; last updated 3/12/19

% This script will streamline labeling of tumor-containing images. The
% user will provide a folder that contains the images. The script will run
% through every image in the folder and allow the user to draw a mask
% defining the location of the tumor in the image. A cropped version of the
% original image (to get rid of the VSX border) as well as a binary image
% containing the data from the mask, will be saved in a .mat file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%% Allow user to choose the folder of interest; looking for '.tif'
disp('Choose folder in which relevant images are contained.')
path = uigetdir();
disp('Choose folder in which labeled data will be saved.')
savepath = uigetdir();
files = dir(fullfile(path, '*.tif'));

%% Loop through each file in folder
len = length(files);
for i = 1:len
    % Read, crop, and display image - remove boundary but don't worry about
    % matching image size
    im = rgb2gray(imread(fullfile(path, files(i).name)));
    disp('Draw rectangle such that relevant image is fully contained within it.')
    imshow(im)
    crop = imrect();
    pos = getPosition(crop);
    
    % If image is bad, double click instead of cropping to skip to next
    if(pos(3) < 15)
        continue
    end
    
    % If image is good, crop and continue
    im = im(pos(2):(pos(2)+pos(4)), pos(1):(pos(1)+pos(3)));
    imshow(im);
    
    % Get polygonal ROI and convert to binary mask
    roi = impoly();
    mask = createMask(roi);
    
    % Save im and mask to a .mat file
    filename = strcat(path(end-3:end), 'Image', sprintf('%03d',i));
    save(fullfile(savepath, filename), 'im', 'mask');
end

%% Finish up
close all