function [plexondata] = load_plexondata_spikes(filename, binSize)


%filename = [animal '_' date '_sortedonly.plx'];

% Time information: recording length and bins for calculating firing rates
[~,~,~,~,~,~,~,~,~,~,~,plexondata.recording_length_sec,~] = plx_information(filename);

plexondata.binneddata.binwidth       = binSize;
plexondata.binneddata.timebinedges   = 0:plexondata.binneddata.binwidth:plexondata.recording_length_sec;
plexondata.binneddata.timebincenters = 0.5*plexondata.binneddata.binwidth+plexondata.binneddata.timebinedges(1:end-1);

[spikecountmatrix, ~] = plx_info(filename, 1);

% Get cluster data
for channel = 1:48
    numclusters = length(find(spikecountmatrix(:,channel+1)>0));
    %[channel numclusters]
    if numclusters > 0
            clusters = struct();
            for cluster = 1:numclusters
                numspikes = spikecountmatrix(cluster+1,channel+1);
       %       [cluster (numspikes)]
                [~, clusters(cluster).spiketimes]    = plx_ts(filename, channel, cluster);
                spikehist = histc(clusters(cluster).spiketimes,plexondata.binneddata.timebinedges); spikehist(end) = [];
                clusters(cluster).binneddata.spikeratedata = spikehist/plexondata.binneddata.binwidth;
            end
            plexondata.channels(channel).clusters = clusters;
    end
end
