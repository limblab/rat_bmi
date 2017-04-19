function [clustersort] = load_plexon_clusterdata(animal,date)

filename = [animal '_' date '_clustersort.plx'];

% Time information: recording length and bins for calculating firing rates
[~,~,~,~,~,~,~,~,~,~,~,clustersort.recording_length_sec,~] = plx_information(filename);

clustersort.timebins.binwidth = .1;
clustersort.timebins.timebinedges   = 0:clustersort.timebins.binwidth:clustersort.recording_length_sec;
clustersort.timebins.timebincenters = 0.5*clustersort.timebins.binwidth+clustersort.timebins.timebinedges(1:end-1);


[spikecountmatrix, ~] = plx_info(filename, 1);
% [spikecountmatrix, ~, ~, ~] = plx_info(filename, 1);

clusterchannels = [];
% Get cluster data
for channel = 1:48
    numclusters = length(find(spikecountmatrix(:,channel+1)>0));
    [channel numclusters];
    if numclusters >0
        clusters = struct();
        clusterchannels = [channel clusterchannels];
        for cluster = 1:numclusters
            numspikes = spikecountmatrix(cluster+1,channel+1);
            if numspikes > 0
                [channel cluster];
                [~, clusters(cluster).spiketimes]    = plx_ts(filename, channel, cluster);
                clusters(cluster).firingrate         = histc(clusters(cluster).spiketimes,clustersort.timebins.timebinedges);
                clusters(cluster).firingrate(end)    = [];
                clusters(cluster).smoothedfiringrate = smooth_gaussian(clusters(cluster).firingrate,5);
            end
        end
        clustersort.channels(channel).clusters = clusters;
    end
    clear clusters;
end
