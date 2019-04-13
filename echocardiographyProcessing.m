%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepared by Jonah Harmon; last updated 10/23/18

% This script quantifies certain cardiac parameters given a B-mode cine
% loop of the heart. Has been used with transverse slices of the mouse
% heart. Videos should be sampled at minimum fps = 2 * heart rate
% (to meet Nyquist). Videos taken with the L22-14v60FPSRaylines script work
% well, as the sampling is >> 2*HR.

% The steps essentially involve simulating an M-mode image, where a series
% of slices are combined into a single image and given vs time. I have done
% some light processing to make it easier to select points, namely
% stretching the image laterally by repeating each slice thrice.

% Equations are from Tsujita et al. 2005 and Gao et al. 2011.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%% Read in the video
[filename, filepath] = uigetfile('.avi');
v = VideoReader(strcat(filepath, filename));

% Read each video frame into a matrix and convert to grayscale
i = 1;
while(hasFrame(v))
    ims(:,:,i) = im2double(rgb2gray(readFrame(v)));
    i = i+1;
end

vidSize = size(ims);

%% Draw linear mask on first image, create empty matrix for M-mode
imshow(ims(:,:,1)); title('Draw from the bottom up, vertical line')
fcn = @(pos) [min(pos(:,1)) pos(1,2); min(pos(:,1)) pos(2,2)];
linearROI = imline('PositionConstraintFcn', fcn);
lineMask = createMask(linearROI);

%% Loop through images, get line of pixels from each
i = 1;
for n = 1:3:3*vidSize(3)
    im = ims(:,:,i) + 0.01;
    roiIm = lineMask.*im;
    % Duplicate rows to stretch in x-axis
    mModeIm(:,n) = nonzeros(roiIm);
    mModeIm(:,n+1) = nonzeros(roiIm);
    mModeIm(:,n+2) = nonzeros(roiIm);
    i = i+1;
end

%% Get LVIDd
pxToMM = 1/40; % mm/px

imshow(mModeIm); title('Select 3 clear end diastole diameters.')

for i = 1:1:3
    endDias(i) = imline('PositionConstraintFcn', fcn);
    pos = getPosition(endDias(i));
    p1 = pos(1,:); p2 = pos(2,:); % separate the endpoints
    endDiasPx = sqrt((p2(2)-p1(2))^2+(p2(1)-p1(1))^2);
    endDiasDistMM(i) = pxToMM*endDiasPx;
end

LVIDd = mean(endDiasDistMM);

%% Get LVIDs
imshow(mModeIm); title('Select 3 clear end systole diameters.')

for i = 1:1:3
    endSys(i) = imline('PositionConstraintFcn', fcn);
    pos = getPosition(endSys(i));
    p1 = pos(1,:); p2 = pos(2,:); % separate the endpoints
    endSysPx = sqrt((p2(2)-p1(2))^2+(p2(1)-p1(1))^2);
    endSysDistMM(i) = pxToMM*endSysPx;
end

LVIDs = mean(endSysDistMM);

%% Get IVS
imshow(mModeIm); title('Select 3 clear end diastole IVS (top wall thickness).')

for i = 1:1:3
    IVS(i) = imline('PositionConstraintFcn', fcn);
    pos = getPosition(IVS(i));
    p1 = pos(1,:); p2 = pos(2,:); % separate the endpoints
    IVSPx = sqrt((p2(2)-p1(2))^2+(p2(1)-p1(1))^2);
    IVSDistMM(i) = pxToMM*IVSPx;
end

IVS = mean(IVSDistMM);

%% Get LVPW
imshow(mModeIm); title('Select 3 clear end diastole LVPW (bottom wall thickness).')

for i = 1:1:3
    LVPW(i) = imline('PositionConstraintFcn', fcn);
    pos = getPosition(LVPW(i));
    p1 = pos(1,:); p2 = pos(2,:); % separate the endpoints
    LVPWPx = sqrt((p2(2)-p1(2))^2+(p2(1)-p1(1))^2);
    LVPWDistMM(i) = pxToMM*LVPWPx;
end

LVPW = mean(LVPWDistMM);

%% Calculate fractional shortening, ejection fraction, LV mass (mg)
close Figure 1 % Close m-mode image

FS = ((LVIDd-LVIDs)/LVIDd)*100;
EF = (((LVIDd^3-LVIDs^3))/LVIDd^3)*100;
LVmass = 1.05*((LVIDd + IVS + LVPW)^3-LVIDd^3);

disp(strcat('Fractional shortening:', num2str(FS), '%'))
disp(strcat('Ejection fraction:', num2str(EF), '%'))
disp(strcat('LV mass:', num2str(LVmass), ' mg'))


