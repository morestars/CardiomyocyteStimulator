%% Create avi from tif files

tic
disp('Running TIF to AVI conversion program...')

workingDir = 'E:\JHU_CBSL\2019-07-16_NoPacing';
%mkdir(workingDir)
%mkdir(workingDir,'images')

imageNames = dir(fullfile(workingDir,'*.tif'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile(workingDir,'cellMovie.avi'), 'Uncompressed AVI');
outputVideo.FrameRate = 40;
open(outputVideo)

disp('Converting frames to AVI file...')
for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,imageNames{ii}));
   writeVideo(outputVideo,img)
   disp(ii)
end

close(outputVideo)

disp('AVI file completed.')
toc
%% Display video in Matlab

cellAvi = VideoReader(fullfile(workingDir,'cellMovie2.avi'));

ii = 1;
while hasFrame(cellAvi)
   mov(ii) = im2frame(readFrame(cellAvi));
   ii = ii+1;
end

figure 
imshow(mov(1).cdata, 'Border', 'tight')
movie(mov,1,cellAvi.FrameRate)
