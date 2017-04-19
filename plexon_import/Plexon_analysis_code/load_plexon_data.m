function [clusters,trialdata_plexon] = load_plexon_data(animal,date,directories)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


cd([directories.rawdata 'plexon'])
filename = [animal '_' date '_clusters.plx'];

[~,~,frequency,~,~,~,~,~,~,~,~,recording_length_sec,~] = plx_information(filename);
timedata.binwidth = 1;
timedata.timebinedges = 0:timedata.binwidth:recording_length_sec;
timedata.timebincenters = 0.5*timedata.binwidth+timedata.timebinedges(1:end-1);

%%%%%%%%%%%%%%%%%%%%%%%%% Get cluster data 

[tscounts, wfcounts, evcounts, contcounts] = plx_info(filename, 1);

cd([directories.rawdata '/plexon'])
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

%%%%%%%%%%%%%%%%%%%%%%%%% Get vicon frame/trial data from ad channel
[ad_freq,~,starttime_sec,~,vicon_duration] = plx_ad_v([animal '_' date '.plx'], 16);
[~,~,~,~,frames]                           = plx_ad_v([animal '_' date '.plx'], 17);

plx_adchannel_times = starttime_sec+ (0:(1/ad_freq):(1/ad_freq)*(length(vicon_duration)-1));

trialstart_times = plx_adchannel_times(find(diff(vicon_duration) > 1)+1);
trialend_times   = plx_adchannel_times(find(diff(vicon_duration) < -1));

figure; hold on;
plot(plx_adchannel_times,frames,'r')
plot(plx_adchannel_times,vicon_duration,'k')

framestart_inds = find(diff(frames) > 1)+1;
frameend_inds = find(diff(frames) < -1);

if framestart_inds(1)>frameend_inds(1)
    framestart_inds(1) = [];
end
if framestart_inds(end)>frameend_inds(end)
    framestart_inds(1) = [];
end

framestart_times = plx_adchannel_times(framestart_inds);
frameend_times   = plx_adchannel_times(frameend_inds);

framestart_times(framestart_times<trialstart_times(1)) = [];
frameend_times(frameend_times<trialstart_times(1)) = [];
framestart_times(framestart_times>trialend_times(end)) = [];
frameend_times(frameend_times>trialend_times(end)) = [];

plot(framestart_times,5.5*ones(length(framestart_times),1),'k+')
plot(frameend_times,5*ones(length(frameend_times),1),'r+')
keyboard
trialdata_plexon = struct();
for trialind = 1:length(trialstart_times)
    
    trialdata_plexon(trialind).starttime = trialstart_times(trialind);
    trialdata_plexon(trialind).endtime   = trialend_times(trialind);
    
    trial_framestart_inds = find(framestart_times>=trialstart_times(trialind) & framestart_times<=trialend_times(trialind));
    trial_frameend_inds   = find(frameend_times>=trialstart_times(trialind) & frameend_times<=trialend_times(trialind));
   
    if trial_framestart_inds(1)>trial_frameend_inds(1)
        trial_framestart_inds(1) = [];
    end
    if trial_framestart_inds(end)>trial_frameend_inds(end)
        trial_framestart_inds(1) = [];
    end
    
    trial_framestart_times = framestart_times(trial_framestart_inds);
    trial_frameend_times   = frameend_times(trial_frameend_inds);
    
    trialdata_plexon(trialind).frametimes = 0.5*(trial_framestart_times+trial_frameend_times);
end

% 
% % 
% % figure; hold on;
% % plot(plx_adchannel_times,frames,'r')
% % plot(plx_adchannel_times,vicon_duration,'k')
% % 
% % plot(framestart_times,5*ones(length(framestart_times),1),'k+')
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
