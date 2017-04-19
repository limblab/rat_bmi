close all;
clear all;
home;

directories.rawdata = '/Volumes/L_MillerLab/data/rats/AK/plexon';
directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
directories.database = '/Users/amina/Dropbox/motorcortex_database/';

cd(directories.rawdata)
allfiles = dir('*_clusters.plx');

for fileind = 1:length(allfiles)
    
    filename = allfiles(fileind).name;
    inds = strfind(filename,'_');
    filenamestring = [filename(1:inds(1)-1) ' ' filename(inds(1)+1:inds(2)-1)];
    
    cd(directories.rawdata)
    [~,~,frequency,~,~,~,~,~,~,~,~,recording_length_sec,~] = plx_information(filename);
    timedata.binwidth = 1;
    timedata.timebinedges = 0:timedata.binwidth:recording_length_sec;
    timedata.timebincenters = 0.5*timedata.binwidth+timedata.timebinedges(1:end-1);
    
    % get cluster data
    [tscounts, wfcounts, evcounts, contcounts] = plx_info(filename, 1);
    
    clusters = struct(); clusterind = 1;
    for channel = 1:32
        for channelcluster = 1:4
            numspikes = wfcounts(channelcluster+1,channel+1);
            if numspikes > 0
                clusters(clusterind).channel = channel;
                clusters(clusterind).channelcluster = channelcluster;
                [n, clusters(clusterind).spiketimes] = plx_ts(filename, clusters(clusterind).channel, clusters(clusterind).channelcluster);
                clusters(clusterind).firingrate = histc(clusters(clusterind).spiketimes,timedata.timebinedges); clusters(clusterind).firingrate(end) = [];
                [clusters(clusterind).smoothedfiringrate] = smooth_gaussian(clusters(clusterind).firingrate,5);
                clusterind = clusterind+1;
            end
        end
    end
    
    % plot waveforms for each cluster
    for clusterind = 1:length(clusters)
        figure;
        cd(directories.rawdata)
        [n, npw, ts, wave] = plx_waves(filename, clusters(clusterind).channel, 1);
        plot(wave','Color','k')
        axis tight;
        text(8,1.1*max(max(wave)),[filenamestring ' ch' num2str(clusters(clusterind).channel) ' cluster '  num2str(clusters(clusterind).channelcluster)])
        cd(directories.figure); print([filename(1:inds(2)) '_ch' num2str(clusters(clusterind).channel) '_cl'  num2str(clusters(clusterind).channelcluster)],'-r150','-dtiff','-f1'); close all;
        clear wave;
    end
end



