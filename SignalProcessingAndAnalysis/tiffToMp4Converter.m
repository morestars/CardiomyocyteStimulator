%% Create MP4 from TIF files
% Andrew Masteller
% Modification of Matlab tutorial

tic
clear
disp('Running TIF to MP4 conversion program...')

workingDir = 'C:\Users\amast\OneDrive - Johns Hopkins University\CBSL (Tung Lab)\20190726_135712\Pass4\XXX';
%mkdir(workingDir)
%mkdir(workingDir,'images')

imageNames = dir(fullfile(workingDir,'*.tif'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile(workingDir,'cellMovie_eg'),'MPEG-4');
outputVideo.FrameRate = 10;
open(outputVideo)

disp('Converting frames to MP4 file...')
for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,imageNames{ii}));
   writeVideo(outputVideo,img)
end

close(outputVideo)

disp('MP4 file completed.')
toc

%%

info1 = imfinfo(fullfile(workingDir,imageNames{1}));
info2 = imfinfo(fullfile(workingDir,imageNames{2}));

t1 = datetime(info1.ImageDescription(23:45), 'InputFormat', 'yyyy.MM.dd-HH:mm:ss.SSS', 'Format', 'preserveinput');
t2 = datetime(info2.ImageDescription(23:45), 'InputFormat', 'yyyy.MM.dd-HH:mm:ss.SSS', 'Format', 'preserveinput');
dt = duration(t2 - t1, 'Format', 'hh:mm:ss.SSS');


