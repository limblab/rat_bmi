% function [plexondata] = load_plexondata_raw(animal,date)

filename = [animal '_' date '.plx'];

% Time information: recording length and bins for calculating firing rates
[~,~,~,~,~,~,~,~,~,~,~,plexondata.recording_length_sec,~] = plx_information(filename);

plexondata.timebins.binwidth = .1;
plexondata.timebins.timebinedges   = 0:plexondata.timebins.binwidth:plexondata.recording_length_sec;
plexondata.timebins.timebincenters = 0.5*plexondata.timebins.binwidth+plexondata.timebins.timebinedges(1:end-1);


% Get cluster data
for channel = 1:48
    allspiketimes = plx_ts(filename, channel, 0);
    [channel length(allspiketimes)]
%     
%         [channel cluster];
%         [~, channels(channel).spiketimes]    = plx_ts(filename, channel, 0);
%         channels(channel).firingrate         = histc(clusters(cluster).spiketimes,plexondata.timebins.timebinedges);
%         channels(channel).firingrate(end)    = [];
%         channels(channel).smoothedfiringrate = smooth_gaussian(clusters(cluster).firingrate,5);
%         
    
end

plexondata.unsorted.channels = channels;
