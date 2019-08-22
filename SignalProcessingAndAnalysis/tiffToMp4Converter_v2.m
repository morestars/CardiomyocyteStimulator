%% Create MP4 from TIF files
% Andrew Masteller
% Modification of Matlab tutorial

tic
clear
disp('Running TIF to MP4 conversion program...')

folderNames = {'D:\JHU_CBSL\2019-07-16_1000msCL';
    'D:\JHU_CBSL\2019-07-16_700msCL_PostIso';
    'D:\JHU_CBSL\2019-07-16_700msCL';
    'D:\JHU_CBSL\2019-07-16_500msCL_PostIso';
    'D:\JHU_CBSL\2019-07-16_500msCL'};

for jj = 1:length(folderNames)
    
    tempDisp = sprintf('Opening folder %s', folderNames{jj});
    disp(tempDisp)
    workingDir = folderNames{jj};

    imageNames = dir(fullfile(workingDir,'*.tif'));
    imageNames = {imageNames.name}';

    outputVideo = VideoWriter(fullfile(workingDir,'cellMovie'),'MPEG-4');
    outputVideo.FrameRate = 40;
    open(outputVideo)

    disp('Converting frames to MP4 file...')
    for ii = 1:length(imageNames)
       img = imread(fullfile(workingDir,imageNames{ii}));
       writeVideo(outputVideo,img)
    end

    close(outputVideo)
end

disp('MP4 file completed.')
toc

