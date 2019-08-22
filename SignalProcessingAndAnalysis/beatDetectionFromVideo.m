%% Beat detection with LED stimulation indication
% Andrew Masteller
%{
 
%}
%% Setup
disp('Setup...')
tSetup = tic;
 
% Set working directory
workingDir = 'E:\JHU_CBSL\2019-07-16_NoPacing';

v = VideoReader(fullfile(workingDir, 'cellMovie.mp4'));

%outputVideo = VideoWriter(fullfile(workingDir,'cellMovie'),'MPEG-4');

% Set up detection array
theAvgDiff = zeros(1,2000-1);
theAvgPix = zeros(1,2000-1);
theDiffSum = zeros(1,2000-1);
theDiffMat = zeros(500, 496, 2000);
img = uint8(zeros(500, 496, 2000));

tSetup = toc(tSetup);
fprintf('Setup completed in %0.3f seconds.\n', tSetup);

%% Processing
disp('Processing...')
tProcessing = tic;
img1 = readFrame(v);
% Compare sequential frames
for ii = 1:2000-1
   img2 = readFrame(v);
   theDiff = imabsdiff(img1(:,:,1), img2(:,:,1));
   theDiffMat(:,:,ii) = theDiff;
   theDiffSum(ii) = sum(theDiff, 'all');
   theAvgDiff(ii) = sum(theDiff, 'all')/numel(theDiff);
   theAvgPix(ii) = mean(img1, 'all');
   img(:,:,ii) = img1(:,:,1);
   img1 = img2;
end

tProcessing = toc(tProcessing);
fprintf('Processing completed in %0.3f seconds.\n', tProcessing)

%% Identify LED indicator
disp('Indentifying LED flashes...')
tLED = tic;

% Uses overall average pixel values of original tif files
stimTiming = zeros(size(theAvgPix));
for ii = 1:length(theAvgPix)
    if theAvgPix(ii) >= mean(theAvgPix) % 255 max for 8-bit files
        stimTiming(ii) = 1;
    end
end

stimTrig = diff(stimTiming) == -1;
stimLocs = find(diff(stimTiming) == -1);

tLED = toc(tLED);
fprintf('LED identification completed in %0.3f seconds.\n', tLED)

%% Attenuate out the LED flash
disp('Attenuate out LED flash')
tAtten = tic;

theAvgDiffAtten = theAvgDiff;
attenParam = mean(theAvgDiff(1:50));

for ii = 1:length(theDiffSum)
    if stimTiming(ii) == 1
        theAvgDiffAtten(ii-2) = attenParam;
        theAvgDiffAtten(ii-1) = attenParam;
        theAvgDiffAtten(ii) = attenParam;
        theAvgDiffAtten(ii+1) = attenParam;
        theAvgDiffAtten(ii+2) = attenParam;
    end
end

tAtten = toc(tAtten);
fprintf('Attenuation completed in %0.3f seconds.\n', tAtten)
%%

%% Peaks
minPeakHeight = mean(theAvgDiffAtten) + 2.5*std(theAvgDiffAtten);
[pks, locs] = findpeaks(theAvgDiffAtten, 'MinPeakHeight', minPeakHeight);

frameRate = 40;
time = 0:1/frameRate:length(imageNames)/frameRate;
t = time(1:length(theAvgDiff));

figure
findpeaks(theAvgDiffAtten, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', 10);
hold on
plot(stimTiming/4+min(theAvgDiffAtten)-0.25)

%% NEO
%x = theAvgDiffAtten;
x = theAvgDiff;
Neo = zeros(1, length(x)-2);

for ii = 1:length(Neo)
    Neo(ii) = x(ii+1)^2 - ( x(ii)*x(ii+2) );
end

minPeakHeight = mean(Neo)+std(Neo);
[pksNeo, locsNeo] = findpeaks(Neo,'MinPeakHeight',minPeakHeight);

figure
findpeaks(Neo,'MinPeakHeight',minPeakHeight)
%% Plots
disp('Generating plots')

figure
area(stimTiming*(max(theAvgDiffAtten)-min(theAvgDiffAtten))+min(theAvgDiffAtten))
hold on
plot(theAvgDiffAtten, 'LineWidth', 1)
hold off
ylim([min(theAvgDiffAtten) max(theAvgDiffAtten)])
legend('LED Indicator', 'CM Beat Measure')


%% 
theNomDiffSumAtten = theNomDiffSum;
for ii = 1:length(theNomDiffSumAtten)
    if stimTiming(ii) == 1
        theNomDiffSumAtten(ii) = 8.8e5;
        theNomDiffSumAtten(ii-1) = 8.8e5;
        theNomDiffSumAtten(ii-2) = 8.8e5;
        theNomDiffSumAtten(ii+1) = 8.8e5;
        theNomDiffSumAtten(ii+2) = 8.8e5;
    end
end


%%
theAvgDiffAtten = theAvgDiff;

for ii = 1:length(theAvgDiffAtten)
    if stimTiming(ii) == 1
        theAvgDiffAtten(ii) = NaN;
        theAvgDiffAtten(ii-1) = NaN;
        theAvgDiffAtten(ii-2) = NaN;
        theAvgDiffAtten(ii+1) = NaN;
        theAvgDiffAtten(ii+2) = NaN;
    end
end

theAvgDiffAtten(isnan(theAvgDiffAtten)) = mode(theAvgDiffAtten);
%%
frameRate = 40;
time = 0:1/frameRate:length(imageNames)/frameRate;
t = time(1:length(theAvgDiff));
%% Save File
save(fullfile(workingDir, 'data.mat'))
%% END

%{
NOTES:

* look at percentage of visual field that responds
fraction of capture
how many/which pixels don't change in intensity 
finds dead zones in monolayer

* multi-well plate
try with 4-well if it's simpler
try non-sterile multi-well setup for current drop concerns

%}
%% readMe
readMe = {'D:\JHU_CBSL\2019-07-16_2000msCL';
    'JHU013C cell line'};
%%
figure
plot(t, theAvgDiffAtten, 'LineWidth', 2)
hold on
plot(t, stimTiming/4+2.5)
plot(t, theAvgDiff)
legend('Attenuated', 'LED Flash', 'Unattenuated')
xlabel('Time (s)')
ylabel('Average Pixel Difference')
hold off

%%
img = zeros(500, 496, 3998);
for ii = 1:length(imageNames)-1
   img(:,:,ii) = imread(fullfile(workingDir,imageNames{ii}));
end
%%

colormap('jet');
caxis([0 7]);
colorbar;
for ii = 3:1590
    subplot(2,2,1)
    imagesc(theDiffMat(:,:,ii))
    caxis([0 7])
    
    subplot(2,2,2)
    plot(theAvgDiffAtten(1:ii))
    ylim([2 5])
    xlim([ii-50 ii+10])
        
    subplot(2,2,3)
    imshow(img(:,:,10),[0 255])
    
    pause(0.2)
end

