%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepared by Jonah Harmon; last updated 10/23/18

% This script will generate a plot of pixel intensity vs time within a
% user-specified ROI. This is useful for quantifying perfusion. Cine loops
% captured using a contrast imaging mode (I've been using
% L22-14v128RyLnsAM) work best. I have been using microbubbles with 
% 90:10 DSPC:DSPE-mPEG2000 shells and perfluoropropane cores. The injection
% should be done while the animal is under anesthesia and a minimum of 3
% seconds worth of video should be captured prior to visible perfusion
% through the region of interest.

% In short, this script will ask the user to draw an ROI on a selected
% image pulled from the video, at a time point at which the region of
% interest will have already been perfused such that the user can easily
% see the perfused region. Then, an average pixel intensity will be
% calculated within the region. Over time, a rolling average will be
% generated as well to smooth out noise, including larger spikes from
% motion due to breathing. Finally, the user will be asked to select the
% lowest and highest points on the plot in order to calculate the slope of
% the rise and the maximal fold increase in pixel intensity.

% The for_abstract variable was used when generating data for the 2019 IEEE
% IUS abstract submission (Ultrasound-guided gas embolization using ADV)
% and can be left as false during normal use. If desired, however, it can
% be set to true and used to save the values from the plot to a csv file
% for use in statistics or plotting with other software.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%% Automate running through multiple videos
% If multipleMasks = true, the user will draw a separate mask every 100
% frames in the video. If it is false, the user will draw a mask on the first
% frame in the video and that mask will be used for quantification.
% multMasks = input('Draw mask on first frame only (type false) or every frame (type true)\n');
multMasks = 0;
numVids = input('How many animals to analyze?\n');
pers = input('Average how many frames? (1 = no persistence)\n');

times = [];
vals = [];
rollAvgVals = [];
slope = [];
maxOverMin = [];
for_abstract = 0;

startFrame = 0;
for i = 1:1:numVids
    [filename, filepath] = uigetfile('.avi');
    [times(i,:), vals(i,:), rollAvgVals(i,:), slope(i), maxOverMin(i)] = perfQuant(filepath, filename, multMasks, pers);
    if(for_abstract == 1)
        fullData = [times', rollAvgVals', vals'];
        csvwrite('C:\Users\verasonics\jonah\Second_HCC_Study\ius-abstract\M3-fast-correct-orientation.csv', fullData);
    end
end



%% Create function for perfusion quantification
function [times, vals, rollAvgVals, slope, maxOverMin] = perfQuant(filepath, filename, multipleMasks, pers)
close all

%% Create VideoReader object for pulling in video frames
v = VideoReader(strcat(filepath, filename));
numFrames = v.Duration*v.FrameRate; % Get number of frames in video

%% Get frame rate from file name
searchPattern = 'FR'; % The naming of the files must be consistent!
frStr = filename(strfind(filename, searchPattern)+length(searchPattern):end-4);
frStr(strfind(frStr, 'p')) = '.';
frameRate = str2double(frStr);

totalTime = numFrames/frameRate; % frames/(frames/sec) = sec
times = linspace(0, totalTime, numFrames); % Get vector of time values for plotting

%% Analyze video in 1000 frame chunks to avoid maxing RAM
startSecond = 0;
startframe = startSecond*frameRate;
currentframe = 1;
avgIntVals = [];
chunkSize = 1000;
for j = 1:1:ceil(numFrames/chunkSize)
    v.CurrentTime = startframe/v.FrameRate;
    clear ims
    
    % Read each video frame into a matrix and convert to grayscale
    for i = 1:1:chunkSize
        if (hasFrame(v)&&(pers==1))
            ims(:,:,i) = im2double(rgb2gray(readFrame(v)));
        elseif(hasFrame(v)&&(i<=pers))
            ims(:,:,i) = im2double(rgb2gray(readFrame(v)));
        elseif(hasFrame(v)&&(i>pers))
            ims(:,:,i) = im2double(rgb2gray(readFrame(v)));
            ims(:,:,i) = mean(ims(:,:,i-pers:i),3); % average pers # of frames
        else
            break
        end
    end
    
    startframe = startframe + chunkSize;

    % Loop through images and get average intensity
    % For now just using a single mask for the whole video. This will work in
    % the tumors if movement from breathing is negligible, but may have to add
    % code to do image registration or, in the subideal but easy to implement
    % case, have users draw a mask on the tumor in each image in the video.

    % Only draw ROI on first image, not every loop iteration
    if j==1
        imForROI = imshow(ims(:,:,end));
        userroi = impoly();
        bwmask = createMask(userroi);
    end
    
    imsSize = size(ims);
    % Get array of average intensity values
    for n = 1:1:imsSize(3)
        if (multipleMasks && (mod(n,100) == 0)) % draw new mask every 100 frames
            set(imForROI, 'CData',ims(:,:,n));
            pause(5) % wait 5 seconds for user to move ROI
            bwmask = createMask(userroi);
        end
        roiIm = bwmask.*ims(:,:,n);
        avgIntVals(currentframe) = mean(mean(nonzeros(roiIm)));

        if n <= 50
            rollAvgVals(currentframe) = avgIntVals(currentframe);
        end
        if n > 50
            rollAvgVals(currentframe) = mean(avgIntVals(currentframe-35:currentframe));
        end

        currentframe = currentframe + 1;
    end
end
    
%% Plot avg intensity values vs time, get max and min vals
plot(times, avgIntVals)
title('Select lowest intensity point before perfusion, then highest intensity point after perfusion'); 
xlabel('Time (s)'); ylabel('Normalized intensity')
hold on
plot(times, rollAvgVals, '--g');
legend('Average Intensity', 'Rolling Average Intensity', 'Location', 'northwest')
pointROIMin = impoint();
minPt = getPosition(pointROIMin);
mintime = minPt(1); minval = minPt(2);
pointROIMax = impoint();
maxPt = getPosition(pointROIMax);
maxtime = maxPt(1); maxval = maxPt(2);

%% Specify output
vals = avgIntVals;
slope = (maxval-minval)/(maxtime-mintime);
maxOverMin = maxval/minval;

end