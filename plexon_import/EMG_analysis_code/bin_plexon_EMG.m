function [emgdatabin] = bin_plexon_EMG(emg_data, params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Want to assemble the emg data into a single
% matrix. Each column is a different analog signal. If desired, the analog data is
% filtered and downsampled according to input specifications.
% EMG data is hi-pass filtered at 50Hz, rectified and low pass filtered
% at 10Hz, unless otherwise specified. It is downsampled to match the desired binsize.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defaults
defaultBinsize = 0.05; %binsize
defaultHP = 50;        %High pass filter
defaultLP = 10;        %Low pass filter
defaultNormalize = 0;  %Normalize EMG

if ~isfield (params, 'binsize')
    fprintf('No binsize specified. Using default: 0.05s');
    params.binsize = defaultBinsize;
end
if ~isfield (params, 'EMG_hp')
    %fprintf('No high pass filter specified. Using default: 50Hz');
    params.EMG_hp = defaultHP;
end
if ~isfield (params, 'EMG_lp')
    %fprintf('No low pass filter specified. Using default: 10Hz');
    params.EMG_lp = defaultLP;
end
if ~isfield (params, 'NormData')
    %fprintf('No EMG normalization.');
    params.NormData = defaultNormalize;
end

emgsamplerate = emg_data.freq;   %Rate at which emg data were actually acquired.
emg_times = single(0:1/emgsamplerate:(size(emg_data.data,1)-1)/emgsamplerate);

%timeframe will be the binned times
% numberbins = floor((emg_times(end)-emg_times(1))/params.binsize);
% timeframe = ones(numberbins,1);
timeframe = (0:params.binsize:emg_times(end)-params.binsize)';
numberbins = length(timeframe);

numEMGs = length(emg_data.channel);
emgtimebins = 1:1:length(emg_data.data(:,1));

%Pre-allocate matrix for binned EMG 
emgdatabin = zeros(numberbins,numEMGs);

% Filter EMG data: [B,A] = butter(N,Wn,'high'), N = order(#poles), Wn = 0.0 < Wn < 1.0, with 1.0 corresponding to half the sample rate.
[bh,ah] = butter(3, params.EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
[bl,al] = butter(3, params.EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params

for E=1:numEMGs
    % Filter EMG data
    tempEMG = double(emg_data.data(emgtimebins,E+1));
    %figure; plot(tempEMG)           
    tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
    %figure; plot(tempEMG)
    tempEMG = abs(tempEMG); %rectify
    %figure; plot(tempEMG)
    tempEMG = filtfilt(bl,al,tempEMG); %lowpass filter
    %figure; plot(tempEMG)
    %end
    %downsample EMG data to desired bin size
%             emgdatabin(:,E) = resample(tempEMG, 1/binsize, emgsamplerate);
    emgdatabin(:,E) = interp1(emg_data.data(emgtimebins,1), tempEMG, timeframe,'linear','extrap');
end

    %Normalize EMGs        
    if params.NormData
        for i=1:numEMGs
%             emgdatabin(:,i) = emgdatabin(:,i)/max(emgdatabin(:,i));
            %dont use the max because of artefact, use 99% percentile
            EMGNormRatio = prctile(emgdatabin(:,i),99);
            emgdatabin(:,i) = emgdatabin(:,i)/EMGNormRatio;
        end
    end
    
end