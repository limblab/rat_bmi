clc; close all; clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUMMARY
%{
% Wrapper script to import, analyze and bin Epidural Data and decode 
% kinematics from it. Not yet adapted to decode EMG.
%
% INPUTS:
%   - .plx file: Plexon file containing the neural & EMG data
%
%   - .csv file: CSV file containing kinematic data.
%
% OUTPUTS:
%   - mat_files folder: Folder created inside your data folder with a .mat
%       file containing all the analyzed data.
%
%   - Results folder: Folder containing the results of the analysis including
%       figures.
%
% TIPS:
%
% TODO:
%   - Adapt the code to decode EMG
%   - Modify the decoding section of the code so that it decodes every
%       field in the .binnedkinematics field, not just one target signal (i.e. 
%       it should decode the raw kinematics, the referenced kinematics etc. and 
%       and save all results)
%   - Make standard plotting functions. The 2 plotting functions at the end
%      of this code have not been validated.
%   - Make 'PlotEpiduralData' script a function.
%
%}
% Code written by Pablo Tostado. Updated July 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add directories to path and specify files to work with:

%Path to your local copy of the repo
myPath = 'C:\Users\Pablo_Tostado\Desktop\Northwestern_University\MyWorkFolder\Analysis';

% In case the plexon routines are not already in the Path:
plexonRoutinesPath = [myPath '\rat_bmi\plexon_import'];
addpath(genpath(plexonRoutinesPath));

%name of the directory where your data is stored
data_dir = [myPath '\rat_bmi\Data_Epidural\E1\17-07-11\'];

% name of the file to import
filename = 'E1_170711_noobstacles_mediummarkers_1'; %.plx extension not needed
filenameKin = '17-07-11_noobstacles.csv';           %.csv extension might be needed                    

%% General parameters:

viconScalingFactor = 4.7243;    % Factor to convert Vicon kinematics to mm.
viconFreq = 200;                % Frequency (Hz) at which kinematic data is acquired. Necessary to bin data. EXTRACT THIS FROM THE XLS FILE IF POSSIBLE

epi_data_ch = 32:47;            % Specify the channels that contain epidural recordings
viconCh = 16;                   % Channel that records when vicon was recording.

binSize = 0.05;                 % Bin size for binning the data (in seconds): 0.05 = bins of 50ms
LFPwindowSize = 256;            % Size of the window used to bin the data. Trade off between freq resolution & window overlapping
FFTwindowSize = LFPwindowSize;  % Size of the FFT window. Divide data into overlapping sections of the same window length to compute PSD.
nFFT = FFTwindowSize;           % Number of FFT points used to calculate the PSD estimate(make it power of 2 for faster processing). nFFT larger than the window of data (FFTwindowSize) will result in zero-padding the data.

referenceMarker = 'hip_middle'; % Marker of reference. Make center of coordinates. TIP: Use stable marker -> hip_middle. Leave empty otherwise.

% freqBands: Specify the frequency bands of interest to decode from in the following format: 
% [b1_Flow b1_Fhigh; b2_Flow b2_Fhigh; etc] e.g. (5 bands) [0 4; 4 10; 10 40; 40 80; 80 500]
freqBands = [8 20; 20 70; 70 115; 130 200; 200 300];
% freqBands = [0 80];

%% Import Epidural Data

% Full set of Analog channels:
% LFPs 1:15; Vicon 16:17; LFPs 32:47; EMGs 48:63;
channels = [16 17 32:47 48:54]; % Specify channels to import

% If the data has already been converted to .mat file, load:
if exist([data_dir 'mat_files/' filename '.mat'])
    disp('loading .mat data');
    load([data_dir 'mat_files/' filename '.mat']);
% Otherwise import and save it:
else
    disp('importing .plx data'); 
    an_data = import_plexon_analog(data_dir, filename, channels); %Import LFPs
    an_data.kinematicData = importVicon([data_dir filenameKin]);  %Import kinematics
    save([data_dir 'mat_files/' filename], 'an_data');
end

%% Compare Neural data and Decoding Signal

% Channel 16 in plexon indicates when Vicon was recording.
% If Vicon was not recording, value in channel 16 is ~0. If it was recording, value
% is ~4.
 
% Keep only data the data when Vicon was recording:
viconChannel = find(an_data.channel == viconCh);

plxVicon = an_data.data(viconChannel,:) > 1;
an_data.data = an_data.data(:,plxVicon);

% This is the actual vicon data, which is usually collected at a different freq:
plxViconSamples = sum(plxVicon);
plxFreq = an_data.freq(1);

viconDataLen = length(an_data.kinematicData.x);
diffSamples = viconDataLen * (plxFreq/viconFreq) - plxViconSamples;

fprintf('There is a difference of %d acquired samples between Vicon & Plexon. \n', abs(diffSamples));

%% LFPs Data Analysis

LFPanalysisParams.binSize = binSize;  LFPanalysisParams.data_ch = epi_data_ch; LFPanalysisParams.freqBands = freqBands; 
LFPanalysisParams.LFPwindowSize = LFPwindowSize; LFPanalysisParams.FFTwindowSize = FFTwindowSize; LFPanalysisParams.nFFT = nFFT;
an_data = do_LFPanalysis_funct(an_data, LFPanalysisParams);

save([data_dir 'mat_files/' filename], 'an_data'); 

%% Process and BIN kinematic data: (If it comes in a struct: .names .x .y .z)

% Make this a function. There must be 2 separate functions to process Kin & EMG
%an_data.processedKinData = processKinematicData_funct (an_data);

kin_data = an_data.kinematicData;
rawKin = []; kinLabels = [];

for i = 1:length(kin_data.names)   
    kinLabels = [ kinLabels {[kin_data.names{i} '_x']} {[kin_data.names{i} '_y']} {[kin_data.names{i} '_z']} ];
    rawKin = [rawKin kin_data.x(:,i) kin_data.y(:,i) kin_data.z(:,i)];
end
% Convert to mm:
rawKin = rawKin / viconScalingFactor;
an_data.rawKinematicData.rawKinematics = rawKin; an_data.rawKinematicData.kinLabels = kinLabels;
clear kinLabels; clear rawKin;

% Reference every marker to the most stable one to disregard threadmill-caused movement. TIP: hip_middle
refMarkerField = ['rawKinematics_ref_' referenceMarker];
rawKin = [];
if ~isempty (referenceMarker)
    
    posRefMarker = strmatch(referenceMarker, an_data.kinematicData.names); % Find marker in array;
    refX = an_data.kinematicData.x(:, posRefMarker); 
    refY = an_data.kinematicData.y(:, posRefMarker); 
    refZ = an_data.kinematicData.z(:, posRefMarker); 
    
    for i = 1:length(kin_data.names)   
        rawKin = [rawKin kin_data.x(:,i)-refX kin_data.y(:,i)-refY kin_data.z(:,i)-refZ];
    end
    an_data.rawKinematicData.(refMarkerField) = rawKin;
end

winSize = LFPwindowSize; 
% viconFreq = 200;

viconSampsPerBin = binSize*viconFreq;
epiKinRatio = an_data.freq(1)/viconFreq;
excludeSamps = round(winSize/epiKinRatio - viconSampsPerBin);

an_data.rawKinematicData.rawKinematics(1:excludeSamps,:) = [];
an_data.rawKinematicData.(refMarkerField)(1:excludeSamps,:) = [];
an_data.rawKinematicData.kinTimeframe = [ 0: 1/viconFreq : size(an_data.rawKinematicData.rawKinematics,1)* (1/viconFreq) - (1/viconFreq) ]';

% BINNING: Vq = interp1(X,V,Xq) interpolates to find Vq, the values of the
% underlying function V = F(X) at the query points Xq. 
an_data.binnedKinematicData.rawKinematics = interp1(an_data.rawKinematicData.kinTimeframe', an_data.rawKinematicData.rawKinematics(:,1:end), an_data.timeframe,'linear','extrap');
an_data.binnedKinematicData.(refMarkerField) = interp1(an_data.rawKinematicData.kinTimeframe', an_data.rawKinematicData.(refMarkerField)(:,1:end), an_data.timeframe,'linear','extrap');

%Interpolate NaNs. Create a vector to tell which marker is worth decoding.
%If it has too many NaNs, discard.
interpolatedKin = []; interpolatedKin_ref = [];
for i = 1:size(an_data.binnedKinematicData.rawKinematics,2)
 interpolatedKin = [interpolatedKin inpaint_nans(an_data.binnedKinematicData.rawKinematics(:,i))];
 interpolatedKin_ref = [interpolatedKin_ref inpaint_nans(an_data.binnedKinematicData.(refMarkerField)(:,i))];
end
an_data.binnedKinematicData.rawKinematics = interpolatedKin;
an_data.binnedKinematicData.(refMarkerField) = interpolatedKin_ref;

%% Decoding  from LFPs

% LimbLab Path:
limlabPath = 'C:\Users\Pablo_Tostado\Desktop\Northwestern_University\LimbLab_Repo\limblab_analysis';
addpath(genpath(limlabPath));

% Set decoding parameters and predict kinematics

% Mandatory fields to specify the signal to decode 
DecoderOptions.PredEMGs = 0;             % Predict EMGs (bool)
DecoderOptions.PredCursPos = 1;          % Predict kinematic data (bool)

% Optional fields. If empty or non-existing, defaults will be used.
DecoderOptions.PolynomialOrder = 2;      % Order of Wiener cascade
DecoderOptions.foldlength = 30;          % Duration of folds (seconds)
DecoderOptions.fillen = 0.5;             % Filter Length: Spike Rate history used to predict a given data point (in seconds). Usually 500ms.
DecoderOptions.UseAllInputs = 1;

% These parameters are standard in the LAB when using the Wiener decoder code:
binnedData.spikeratedata = an_data.binnedEpiduralData.rawEpidural';
binnedData.neuronIDs = [ [1:size(an_data.binnedEpiduralData.rawEpidural, 1)]' zeros(size(an_data.binnedEpiduralData.rawEpidural, 1), 1)];
binnedData.cursorposbin = an_data.binnedKinematicData.rawKinematics; %DECODING SIGNAL
binnedData.cursorposlabels = an_data.rawKinematicData.kinLabels;
binnedData.timeframe = an_data.timeframe;

[PredSignal] = epidural_mfxval_decoding (binnedData, DecoderOptions);

% Save struct with predictions
disp('Saving Offline Predictions...');
an_data.wiener_offlinePredictions = PredSignal;

save([data_dir 'mat_files/' filename], 'an_data'); 

%% Plot data 

% save_dir = [data_dir 'mat_files/'];
close all;
plotOfflinePredictions_funct(an_data, binnedData.cursorposbin, data_dir);
plotEpiduralData; % Make this script a function
