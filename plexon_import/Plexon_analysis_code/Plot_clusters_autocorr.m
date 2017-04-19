clear all;
close all;
home;

directories.rawdata = '/Volumes/L_MillerLab/data/rats/AK/plexon/';
directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
directories.database = '/Users/amina/Dropbox/motorcortex_database/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trials(1).animal = 'A1';
trials(1).date = '20160312';
trials(1).clusters(1).channel        = 2;
trials(1).clusters(1).channelcluster = 1;

trials(2).animal = 'A2';
trials(2).date = '20160408';
trials(2).clusters(1).channel        = 22;
trials(2).clusters(1).channelcluster = 1;
trials(2).clusters(2).channel        = 22;
trials(2).clusters(2).channelcluster = 2;

trials(3).animal = 'A2';
trials(3).date = '20160419';
trials(3).clusters(1).channel        = 1;
trials(3).clusters(1).channelcluster = 1;
trials(3).clusters(2).channel        = 7;
trials(3).clusters(2).channelcluster = 1;

trials(4).animal = 'A3';
trials(4).date = '20160414';
trials(4).clusters(1).channel        = 2;
trials(4).clusters(1).channelcluster = 1;
trials(4).clusters(2).channel        = 2;
trials(4).clusters(2).channelcluster = 2;
trials(4).clusters(3).channel        = 2;
trials(4).clusters(3).channelcluster = 3;
trials(4).clusters(4).channel        = 2;
trials(4).clusters(4).channelcluster = 4;
trials(4).clusters(5).channel        = 7;
trials(4).clusters(5).channelcluster = 1;

trials(5).animal = 'A3';
trials(5).date = '20160419';
trials(5).clusters(1).channel        = 2;
trials(5).clusters(1).channelcluster = 1;
trials(5).clusters(2).channel        = 2;
trials(5).clusters(2).channelcluster = 2;
trials(5).clusters(3).channel        = 2;
trials(5).clusters(3).channelcluster = 3;
trials(5).clusters(4).channel        = 2;
trials(5).clusters(4).channelcluster = 4;
trials(5).clusters(5).channel        = 3;
trials(5).clusters(5).channelcluster = 1;
trials(5).clusters(6).channel        = 7;
trials(5).clusters(6).channelcluster = 1;
trials(5).clusters(7).channel        = 7;
trials(5).clusters(7).channelcluster = 2;
trials(5).clusters(8).channel        = 12;
trials(5).clusters(8).channelcluster = 1;

trials(6).animal = 'A3';
trials(6).date = '20160421';
trials(6).clusters(1).channel        = 2;
trials(6).clusters(1).channelcluster = 1;
trials(6).clusters(2).channel        = 2;
trials(6).clusters(2).channelcluster = 2;
trials(6).clusters(3).channel        = 7;
trials(6).clusters(3).channelcluster = 1;
trials(6).clusters(4).channel        = 7;
trials(6).clusters(4).channelcluster = 2;
trials(6).clusters(5).channel        = 12;
trials(6).clusters(5).channelcluster = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for trialind = 3%[5 6]:length(trials)
    animal = trials(trialind).animal;
    date = trials(trialind).date;
    
    filename = [animal '_' date '_clusters.plx'];
    inds = strfind(filename,'_');
    
    cd(directories.rawdata)
    [~,~,frequency,~,~,~,~,~,~,~,~,recording_length_sec,~] = plx_information(filename);
    frate_timebinwidth = 1;
    frate_timebinedges = 0:frate_timebinwidth:recording_length_sec;
    frate_timebincenters = 0.5*frate_timebinwidth+frate_timebinedges(1:end-1);
    
    spikecount_timebinwidth = .05;
    spikecount_timebinedges = 0:spikecount_timebinwidth:recording_length_sec;
    spikecount_timebincenters = 0.5*spikecount_timebinwidth+spikecount_timebinedges(1:end-1);
    
    % get cluster data
    [tscounts, wfcounts, evcounts, contcounts] = plx_info(filename, 1);
    
    clusters = struct(); clusterind = 1;
    channel = trials(trialind).clusters(clusterind).channel;
    channelcluster = trials(trialind).clusters(clusterind).channelcluster;
    numspikes = wfcounts(channelcluster+1,channel+1);
    
    [n, spiketimes] = plx_ts(filename, channel, channelcluster);
    firingrate = histc(spiketimes,frate_timebinedges); firingrate(end) = [];
    smoothedfiringrate = smooth_gaussian(firingrate,5);
    
    
    spikecount_timearray = histc(spiketimes,spikecount_timebinedges); spikecount_timearray(end) = [];
    
    figure;
    crosscorr(spikecount_timearray,spikecount_timearray);
    
    
    figure;
    crosscorr(smoothedfiringrate,smoothedfiringrate);
    
    % plot waveforms for each cluster
    %         figure;
    %         cd(directories.rawdata)
    %         [n, npw, ts, wave] = plx_waves(filename, clusters(clusterind).channel, 1);
    %         plot(wave','Color','k')
    %         axis tight;
    %         text(8,1.1*max(max(wave)),[filenamestring ' ch' num2str(clusters(clusterind).channel) ' cluster '  num2str(clusters(clusterind).channelcluster)])
    %         cd(directories.figure); print([filename(1:inds(2)) '_ch' num2str(clusters(clusterind).channel) '_cl'  num2str(clusters(clusterind).channelcluster)],'-r150','-dtiff','-f1'); close all;
    %         clear wave;
end







