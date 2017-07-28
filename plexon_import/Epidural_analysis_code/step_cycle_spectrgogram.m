close all; clear; clc;

myPath = 'C:\Users\Pablo_Tostado\Desktop\Northwestern_University\MyWorkFolder\Analysis\rat_bmi\Data_Epidural\';
myPath = 'C:\Users\Pablo_Tostado\Desktop\Northwestern_University\MyWorkFolder\Analysis\rat_bmi\Data_Intracortical\';
myFile = 'Intracortical\N5\17-07-10\mat_files\N5_170710_noobstacle_1.mat';



load([myPath myFile]);

% Script to plot the step-cycle triggered averaged spectrogram.
% First load a file.

%% PARAMETERS

plxFreq = an_data.freq(1); viconFreq = 200; ratio = plxFreq/viconFreq;

kinPoints = 8000; % # kinematic points to plot
plxPoints = round (kinPoints*ratio);% # plexon points to plot

marker = 26; % Target marker (26 = toe-y)
step_thr = 13; %Threshold to find step peaks
lowPass_freq = 10; % filter to smooth kinematic data and find peaks
epi_channel = 4; % Epidural channel to plot

scalingFactor = 25; %Scaling factor to plot kinematic + neural data together

numSteps = 4; % Number of steps you want to do the averaged spectrogram of.


%% PLOT RAW DATA

% Data
epi_data = an_data.rawEpiduralData.rawEpidural(:, 1:plxPoints);
kin_data = an_data.rawKinematicData.rawKinematics(1:kinPoints, marker);


%Plot neural + kinematic data
figure; plot( 1:length(epi_data) , epi_data(epi_channel, :));
hold on; plot((1:length(kin_data))*ratio, kin_data/scalingFactor);

%Plot kinematic data
figure;
plot((1:length(kin_data(5000:7000)))*ratio, kin_data(5000:7000)/scalingFactor, 'o');

%% Find peaks

kin_data = inpaint_nans(kin_data); % Interpolate NaNs in kinematic data

%Low pass filter to avoid multiple peaks
[bl,al] = butter(3, lowPass_freq*2/viconFreq, 'low');  %lowpass filter params
tempKin_data = filtfilt(bl,al,kin_data); %lowpass filter

[Pks,Locs]= findpeaks(tempKin_data);

% Set threshold to define real peaks
deletePks = Pks < step_thr;
Pks(deletePks) = [];
Locs(deletePks) = [];
epidural_steps = Locs*ratio;

figure; plot(kin_data); 
hold on; plot(Locs, Pks, 'o');

figure; plot(epi_data(1,:)); 
hold on; plot(epidural_steps, Pks, 'o');

%% Now that we have the peaks, divide each step cycle in intervals of 10 and 
% calculate power in a target band for each section. Then plot vs.
% kinematics.

Locs; % Locations at which steps happen in the kinematics temporal scale.
epidural_steps; % Locations at which steps happen in the epidural temporal scale.
epi_data; kin_data; 

ave_Step_length = mean(diff(epidural_steps));

points = (ave_Step_length * numSteps) /2; %Points to look at before & after peak (make it multiples of stepLength to average 1, 2 ,3 etc. steps)

for i = numSteps:length(epidural_steps)-numSteps    
    epidural_data_step(:,:,i) = epi_data(:, (epidural_steps(i)-points):(epidural_steps(i)+points));
    kin_data_step (:,i) = kin_data(( Locs(i)-(points/ratio) ):( Locs(i)+ (points/ratio) ));
end
    
ave_epi = mean(epidural_data_step, 3);
ave_kin = mean(kin_data_step,2);

%Plot averaged kin data:
figure; plot(kin_data_step);
figure; plot(ave_kin);

%% PLOT

FFTwindow = 128;
nFFT = FFTwindow;
freqPlx = an_data.freq(1);
numSamples = length(ave_epi);

peakKinematics = max(ave_kin);   %Normalize kinematics scale to make it easy to look at modulation
normalizFactor = (plxFreq/2 /peakKinematics);  

normalized_kinem = ave_kin * normalizFactor; %Normalize kinematics scale to make it easy to look at modulation
figure; plot(normalized_kinem);

figure; 
%Plot spectrogram
set(gcf, 'color', 'white'); 
spectrogram(ave_epi(1,:), FFTwindow, [], nFFT, freqPlx, 'yaxis'); 
%Plot kinematics on top
hold on; %figure
x = linspace(0,numSamples/freqPlx, numSamples/ratio) %* 1000; %If the time axis of the spectrogram is shown in ms, multiply x*1000
plot(x, normalized_kinem(1:floor(numSamples/ratio)), 'k', 'LineWidth', 2)
title(['Channel: ' num2str(epi_channel) ', Toe y ' ' FFTwindow:' num2str(FFTwindow) ' nFFT:' num2str(nFFT)]); 
set(gca, 'box', 'off');

