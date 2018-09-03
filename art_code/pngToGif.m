%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Last updated 9/3/2018.

% This script will take a set of images (.png) and convert them into an
% animated gif. Images should be named 'somerandomname#.png' where # is the
% frame number, e.g. flower0001.png. Images should be place into their own
% individual folder with no other files.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read in the images
mydir = uigetdir();
cd(mydir)
files = dir(fullfile(mydir, '*.png'));

for i=1:1:length(files)
    [a,b] = imread(files(i).name, 'png'); 
    ims(:,:,i) = a;
    colMaps(:,:,i) = b;
end

%% Create new file (.gif)
gifFileName = strcat(files(i).name(1:end-8), '.gif');
sizeIms = size(ims);
frameCount = sizeIms(3);

for j = 1:1:frameCount
    if j==1
        imwrite(ims(:,:,j),colMaps(:,:,j),gifFileName,'gif','LoopCount',Inf,'DelayTime',1/12);
    else
        imwrite(ims(:,:,j),colMaps(:,:,j),gifFileName,'gif','WriteMode','append','DelayTime',1/12);
    end
end
