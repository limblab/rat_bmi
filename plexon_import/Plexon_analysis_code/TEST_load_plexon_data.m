close all;
home;
clear all;

directories.rawdata = '/Volumes/L_MillerLab/data/rats/AK/';
directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
directories.database = '/Users/amina/Dropbox/motorcortex_database/';

animal = 'A5';
date = '20160518';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd([directories.rawdata 'plexon'])
filename = [animal '_' date '_clusters.plx'];

% [~,~,frequency,~,~,~,~,~,~,~,~,recording_length_sec,~] = plx_information(filename);
% timedata.binwidth = 1;
% timedata.timebinedges = 0:timedata.binwidth:recording_length_sec;
% timedata.timebincenters = 0.5*timedata.binwidth+timedata.timebinedges(1:end-1);

% %%%%%%%%%%%%%%%%%%%%%%%%% Get cluster data 
% 
% [tscounts, wfcounts, evcounts, contcounts] = plx_info(filename, 1);
% 
% cd([directories.rawdata '/plexon'])
% clusters = struct(); clusterind = 1;
% for channel = 1:32
%     for channelcluster = 1:4
%         numspikes = wfcounts(channelcluster+1,channel+1);
%         if numspikes > 0
%             clusters(clusterind).channel = channel;
%             clusters(clusterind).channelcluster = channelcluster;
%             [n, clusters(clusterind).spiketimes] = plx_ts(filename, clusters(clusterind).channel, clusters(clusterind).channelcluster);
%             clusters(clusterind).firingrate = histc(clusters(clusterind).spiketimes,timedata.timebinedges); clusters(clusterind).firingrate(end) = [];
%             [clusters(clusterind).smoothedfiringrate] = smooth_gaussian(clusters(clusterind).firingrate,5);
%             clusterind = clusterind+1;
%         end
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%% Get vicon frame/trial data from ad channel
[ad_freq,~,starttime_sec,~,vicon_trials] = plx_ad_v([animal '_' date '.plx'], 16);
[~,~,~,~,vicon_frames]                           = plx_ad_v([animal '_' date '.plx'], 17);

plx_adchannel_times = starttime_sec+ (0:(1/ad_freq):(1/ad_freq)*(length(vicon_trials)-1));

trialstart_times = plx_adchannel_times(find(diff(vicon_trials) > 1)+1);
trialend_times   = plx_adchannel_times(find(diff(vicon_trials) < -1));

figure; hold on;
plot(plx_adchannel_times,vicon_frames,'r')
plot(plx_adchannel_times,vicon_trials,'k')

vicon_framestart_inds = find(diff(vicon_frames) > 1)+1;
frameend_inds   = find(diff(vicon_frames) < -1);

if vicon_framestart_inds(1)>frameend_inds(1)
    vicon_framestart_inds(1) = [];
end
if vicon_framestart_inds(end)>frameend_inds(end)
    vicon_framestart_inds(1) = [];
end

vicon_framestart_times = plx_adchannel_times(vicon_framestart_inds);
frameend_times   = plx_adchannel_times(frameend_inds);

vicon_framestart_times(vicon_framestart_times<trialstart_times(1)) = [];
frameend_times(frameend_times<trialstart_times(1)) = [];
vicon_framestart_times(vicon_framestart_times>trialend_times(end)) = [];
frameend_times(frameend_times>trialend_times(end)) = [];

plot(vicon_framestart_times,5.5*ones(length(vicon_framestart_times),1),'k+')
plot(frameend_times,5*ones(length(frameend_times),1),'r+')

keyboard

trialdata_plexon = struct();
for trialind = 1:length(trialstart_times)
    
    trialdata_plexon(trialind).starttime = trialstart_times(trialind);
    trialdata_plexon(trialind).endtime   = trialend_times(trialind);
    
    trial_vicon_framestart_inds = find(vicon_framestart_times>=trialstart_times(trialind) & vicon_framestart_times<=trialend_times(trialind));
    trial_frameend_inds   = find(frameend_times>=trialstart_times(trialind) & frameend_times<=trialend_times(trialind));
   
    if trial_vicon_framestart_inds(1)>trial_frameend_inds(1)
        trial_vicon_framestart_inds(1) = [];
    end
    if trial_vicon_framestart_inds(end)>trial_frameend_inds(end)
        trial_vicon_framestart_inds(1) = [];
    end
    
    trial_vicon_framestart_times = vicon_framestart_times(trial_vicon_framestart_inds);
    trial_frameend_times   = frameend_times(trial_frameend_inds);
    
    trialdata_plexon(trialind).frametimes = 0.5*(trial_vicon_framestart_times+trial_frameend_times);
end

% 
% % 
% % figure; hold on;
% % plot(plx_adchannel_times,vicon_frames,'r')
% % plot(plx_adchannel_times,vicon_trials,'k')
% % 
% % plot(vicon_framestart_times,5*ones(length(vicon_framestart_times),1),'k+')
% % plot(frameend_times,5*ones(length(frameend_times),1),'r+')
% % 
% % plot(trialdata_plexontart_times,[6 6],'ko')
% % plot(trialend_times,[6 6],'ro')
% % 
% % for trialind = 1:length(trialdata_plexontart_times)
% %     plot(trialdata_plexon(trialind).frametimes,5.5*ones(length(trialdata_plexon(trialind).frametimes),1),'k+')
% % 
% % end
% % 
% % 
