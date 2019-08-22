%% Beat detection with LED stimulation indication
% Andrew Masteller
%{

%}

tic

%% Setup
disp('Setup')

% Set working directory
workingDir = 'C:\Users\amast\OneDrive - Johns Hopkins University\CBSL (Tung Lab)\20190726_135712\Pass1\XXX';

% Identify all tif files in directory
imageNames = dir(fullfile(workingDir,'*.tif'));
imageNames = {imageNames.name}';

% Set up detection array
theAvgDiff = zeros(1,length(imageNames)-1);
theDiffSum = zeros(1,length(imageNames)-1);
theAvgPix = zeros(1,length(imageNames)-1);

theNomDiffSum = zeros(1, length(imageNames)-1);

t = NaT(1, length(imageNames));

for ii = 1:length(imageNames)
    info = imfinfo(fullfile(workingDir,imageNames{1}));
    t(ii) = datetime(info.ImageDescription(23:45), 'InputFormat', 'yyyy.MM.dd-HH:mm:ss.SSS', 'Format', 'preserveinput');
end
% info2 = imfinfo(fullfile(workingDir,imageNames{2}));
% 
% t1 = datetime(info1.ImageDescription(23:45), 'InputFormat', 'yyyy.MM.dd-HH:mm:ss.SSS', 'Format', 'preserveinput');
% t2 = datetime(info2.ImageDescription(23:45), 'InputFormat', 'yyyy.MM.dd-HH:mm:ss.SSS', 'Format', 'preserveinput');
% dt = duration(t2 - t1, 'Format', 'hh:mm:ss.SSS');


%% Processing
disp('Processing')

% Compare sequential frames
for ii = 1:length(imageNames)-1
   img1 = imread(fullfile(workingDir,imageNames{ii}));
   img2 = imread(fullfile(workingDir,imageNames{ii+1}));
   theDiff = imabsdiff(img1, img2);
   theDiffSum(ii) = sum(theDiff, 'all');
   theAvgDiff(ii) = sum(theDiff, 'all')/numel(theDiff);
   theAvgPix(ii) = mean(img1, 'all');
   theNomDiff = img2 - img1;
   theNomDiffSum(ii) = sum(theNomDiff, 'all');
end

%% Identify LED indicator
disp('Stim timing detection')

% Uses overall average pixel values of original tif files
stimTiming = zeros(size(theAvgPix));
for ii = 1:length(theAvgPix)
    if theAvgPix(ii) >= 200 % 200/255 for 8-bit files
        stimTiming(ii) = 1;
    end
end

stimTrig = diff(stimTiming) == -1;
stimLocs = find(diff(stimTiming) == -1);

%% Attenuate out the LED flash
disp('Attenuate out LED flash')

theDiffSumAtten = theDiffSum;
for ii = 1:length(theDiffSum)
    if stimTiming(ii) == 1
        theDiffSumAtten(ii-2) = 1.77e6;
        theDiffSumAtten(ii-1) = 1.77e6;
        theDiffSumAtten(ii) = 1.77e6;
        theDiffSumAtten(ii+1) = 1.77e6;
        theDiffSumAtten(ii+2) = 1.77e6;
    end
end

%% NEO
%x = theAvgDiffAtten;
x = theAvgDiff;
Neo = zeros(1, length(x)-2);

for ii = 1:length(Neo)
    Neo(ii) = x(ii+1)^2 - ( x(ii)*x(ii+2) );
end

minPeakHeight = mean(Neo)+std(Neo);
[pks, locs] = findpeaks(Neo,'MinPeakHeight',minPeakHeight,'MinPeakDistance',20);

figure
findpeaks(Neo,'MinPeakHeight',minPeakHeight,'MinPeakDistance',20)
%% Plots
disp('Generating plots')

figure
area(stimTiming*(max(theDiffSumAtten)-min(theDiffSumAtten))+min(theDiffSumAtten))
hold on
plot(theDiffSumAtten, 'LineWidth', 1)
hold off
ylim([min(theDiffSumAtten) max(theDiffSumAtten)])
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
%% END
toc

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

