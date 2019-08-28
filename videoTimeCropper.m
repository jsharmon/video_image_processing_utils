%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepared by Jonah Harmon; last updated 4/2/19

% This script crops a video to a desired length given a starting time and
% desired duration.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all 
close all

%% Get file path/name
[filename, filepath] = uigetfile({'.avi';'.mp4'});
cd(filepath)

%% Set number of frames to keep, start point, output file format
starttime = 140;
newLen = 124; % Set in seconds
fps = 60; % For OBS recordings
numFrames = newLen * fps;
mp4 = 'MPEG-4';

vr = VideoReader(strcat(filepath, filename));
vr.CurrentTime = starttime;

%% Read and write video
vw = VideoWriter(strcat(filename(1:end-4), '_processed'), mp4);
vw.FrameRate = fps;

open(vw);
for i=1:1:numFrames
    f = readFrame(vr);
    writeVideo(vw, f);
end
close(vw);
