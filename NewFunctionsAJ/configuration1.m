clear all;
close all; clc;
myPath = '/Users/ambikasatish/Desktop/Miller Lab/matlab codes and data ';

directory = [myPath '/rat_bmi-master/'];
directories.rawdata = [directory 'Data_Intracortical/N5/17-10-16'];
cd(directories.rawdata)

SPIKEtargetfile = 'N5_171016_noobstacles_EMG_1.plx';        % !Different from original file if sorted
EMGtargetfile = 'N5_171016_noobstacles_EMG_1.plx';          % EMGs are not saved in the sorted file after offline sorting
filenameKin = '17-10-16_noobstacles_EMG_1.xlsx';
fileMetaData.treadmillSpeed = 13;

rat = SPIKEtargetfile(1:2);
date = SPIKEtargetfile(4:9);
if SPIKEtargetfile(11) == '3'
    trialType = 'Obstacles';
else
    trialType = 'No Obstacles';
end

standardFilename = strcat(rat,'_',date,'_',trialType);


% In case the plexon routines are not already in the Path:
plexonRoutinesPath = [myPath '\rat_bmi-master\plexon_import'];
addpath(genpath(plexonRoutinesPath));

% Plexon parameters plexon channel definitions for this file
spikeCh = 1:48;  
viconCh = 16;   % this has the TTL signal indicating when Vicon is acquiring data
fieldCh = [0:15 32:47];            % Specify the channels that contain field (LFP or EFP) recordings
EMGCh = 48:54; % EMGCh = 48:56;
%FieldCh2Use = setdiff(1:32,[2 4 20 21 30]);  % this is defined by what the bad channels are 
FieldCh2Use = [2 4 8 7 13 15 17 20 22 23 30 32];  % this is defined by what the bad channels are 
sorted = 0; % Change to 1 if you're using sorted.plx file, if unsorted, set to 0 - not sure what this is doing
EMGCh_labels = {'Ref','TA', 'LG', 'BFp', 'Bfa', 'VL', 'GS'};


% Vicon parameters
viconScalingFactor = 4.7243;    % Factor to convert Vicon kinematics to mm.% this is now in the file reading - should be updated
viconFreq = 200;                % Frequency (Hz) at which kinematic data is acquired. Necessary to bin data. EXTRACT THIS FROM THE XLS FILE IF POSSIBLE
referenceMarker = 'hip_middle'; % Marker of reference. Make center of coordinates. TIP: Use stable marker -> hip_middle. Leave empty otherwise.

% parameters for running LFPs
binSize = 0.05;                 % Bin size for binning the data (in seconds): 0.05 = bins of 50ms
LFPwindowSize = 256;            % Size of the window used to bin the data. Trade off between freq resolution & window overlapping
FFTwindowSize = LFPwindowSize;  % Size of the FFT window. Divide data into overlapping sections of the same window length to compute PSD.
nFFT = FFTwindowSize;           % Number of FFT points used to calculate the PSD estimate(make it power of 2 for faster processing). nFFT larger than the window of data (FFTwindowSize) will result in zero-padding the data.

% freqBands: Specify the frequency bands of interest to decode from in the following format: 
% [b1_Flow b1_Fhigh; b2_Flow b2_Fhigh; etc] e.g. (5 bands) [0 4; 4 10; 10 40; 40 80; 80 500]
freqBands = [8 19; 20 69; 70 129; 130 199; 200 300];

%compile parameters from config file to be used downstream
LFPParams.binSize = binSize;
LFPParams.freqBands = freqBands;
LFPParams.LFPwindowSize = LFPwindowSize;
LFPParams.FFTwindowSize = FFTwindowSize;
LFPParams.nFFT = nFFT;


LFPanalysisParams.binSize = LFPParams.binSize;  
%LFPanalysisParams.data_ch = finalDataSelections.goodFieldChannels; 
LFPanalysisParams.freqBands = LFPParams.freqBands;  
LFPanalysisParams.LFPwindowSize = LFPParams.LFPwindowSize; 
LFPanalysisParams.FFTwindowSize = LFPParams.FFTwindowSize; 
LFPanalysisParams.nFFT = LFPParams.nFFT; 
%LFPanalysisParams.bins = LFPParams.bins; !!might need this!!
