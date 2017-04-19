function [multiunitsort] = load_plexon_multiunitdata(animal,date)

filename = ['./' animal '_' date '_multiunitsort.plx'];


    % Time information: recording length and bins for calculating firing rates
    [~,~,~,~,~,~,~,~,~,~,~,multiunitsort.recording_length_sec,~] = plx_information(filename);
    
    multiunitsort.timebins.binwidth = .1;
    multiunitsort.timebins.timebinedges   = 0:multiunitsort.timebins.binwidth:multiunitsort.recording_length_sec;
    multiunitsort.timebins.timebincenters = 0.5*multiunitsort.timebins.binwidth+multiunitsort.timebins.timebinedges(1:end-1);
    
    [spikecountmatrix, ~] = plx_info(filename, 1);
    
    channels = find(spikecountmatrix(1,:)>0)-1;
    
    % Get multiunit data
    cluster = 0;
    for channelind = 1:length(channels)
        
        channel = channels(channelind);
        
        [~,multiunitsort.channels(channel).spiketimes]     = plx_ts(filename, channel, cluster);
        multiunitsort.channels(channel).firingrate         = histc(multiunitsort.channels(channel).spiketimes,multiunitsort.timebins.timebinedges);
        multiunitsort.channels(channel).firingrate(end)    = [];
        multiunitsort.channels(channel).smoothedfiringrate = smooth_gaussian(multiunitsort.channels(channel).firingrate,5);
    end
