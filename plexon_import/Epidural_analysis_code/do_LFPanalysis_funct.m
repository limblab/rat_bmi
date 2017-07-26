
function LFP_struct = do_LFPanalysis_funct(LFP_struct, params, varargin)

% Epidural Analysis

% Write here a description of what we are doing. 
% CAR, bandpass, power spectrum etc. 
% Explain the data we are creating to decode from

%% Input vararg: set defaults

channels = params.data_ch;
binSize = params.binSize;

%% LFP Data Processing

% Take only the channels that contain epidural data:
[channels, ~] = ismember(LFP_struct.channel, channels);
epiduralData = LFP_struct.data(channels,:);

% Common Average Referencing (CAR) is done to reduce common artifact.
% CAR type 1 : each channel referenced with respect to all channels (including oneself)
% CAR type 2 : each channel referenced with respect to remaining channels (excluding oneself)
LFP_struct.rawEpiduralData = do_CAR(epiduralData);
LFP_struct.rawEpiduralData.rawEpidural = epiduralData;

% Perform the LFP analysis, calculating the power spectrum of the LFPs at
% target frequency bands, binning the data at the same time.
LFP_struct.binnedEpiduralData = do_SpatialFiltering(LFP_struct, params);

%Add time frame for binned data
LFP_struct.timeframe = [ 0 : binSize : length(LFP_struct.binnedEpiduralData.rawEpidural)*binSize - binSize]';

end