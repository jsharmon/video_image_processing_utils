%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepared by Jonah Harmon; last updated 4/2/19

% This script crops a video to a desired length given a starting time and
% desired duration.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all 
close all

%% Get file path/name
cd('C:\Users\verasonics\jonah')

[filename, filepath] = uigetfile('.avi');
cd(filepath)

%% Set number of frames to keep, start point
starttime = 31;
newLen = 30; % Set in seconds
fps = 21; % For OBS recordings
numFrames = newLen * fps;

vr = VideoReader(strcat(filepath, filename));
vr.CurrentTime = starttime;

%% Read and write video
vw = VideoWriter(strcat(filename(1:end-4), '_processed'));
vw.FrameRate = fps;

open(vw);
for i=1:1:numFrames
    f = im2double(rgb2gray(readFrame(vr)));
    writeVideo(vw, f);
end
close(vw);
