close all;
% clear all;
% home;
%
% directories.rawdata = '/Volumes/L_MillerLab/data/rats/AK/';
% directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
% directories.database = '/Users/amina/Dropbox/motorcortex_database/';
%
% animal = 'A2';
% date   = '20160419';
%
% fontsize = 16;
%
% [clusters,trialdata_plexon] = load_plexon_data(animal,date,directories);
%
 [trialdata_vicon] = load_vicon_data(animal,date,directories);

% 
% for cluster = 1:length(clusters)
%     
%     numspikes = length(clusters(cluster).spiketimes);
%     figure(cluster);
%     subplot(2,1,1);
%     line([clusters(cluster).spiketimes clusters(cluster).spiketimes]',[zeros(numspikes,1) ones(numspikes,1)]','Color','k')
%     subplot(2,1,2)
%     plot(clusters(cluster).smoothedfiringrate)
% subplot(3,1,3)
% 
% end
% 
% cd([directories.rawdata '/plexon'])
% filename = [animal '_' date '_clusters.plx'];
% 
% [~,~,frequency,~,~,~,~,~,~,~,~,recording_length_sec,~] = plx_information(filename);
% timedata.binwidth = 1;
% timedata.timebinedges = 0:timedata.binwidth:recording_length_sec;
% timedata.timebincenters = 0.5*timedata.binwidth+timedata.timebinedges(1:end-1);
% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%% Get cluster data 
% % 
% % [tscounts, wfcounts, evcounts, contcounts] = plx_info(filename, 1);
% % 
% % cd([directories.rawdata '/plexon'])
% % clusters = struct(); clusterind = 1;
% % for channel = 1:32
% %     for channelcluster = 1:4
% %         numspikes = wfcounts(channelcluster+1,channel+1);
% %         if numspikes > 0
% %             %             [channel channelcluster numspikes]
% % 
% %             clusters(clusterind).channel = channel;
% %             clusters(clusterind).channelcluster = channelcluster;
% % 
% %             [n, clusters(clusterind).spiketimes] = plx_ts(filename, clusters(clusterind).channel, clusters(clusterind).channelcluster);
% %             % [min(clusters(clusterind).spiketimes) max(clusters(clusterind).spiketimes)]
% %             clusters(clusterind).firingrate = histc(clusters(clusterind).spiketimes,timedata.timebinedges); clusters(clusterind).firingrate(end) = [];
% %             [clusters(clusterind).smoothedfiringrate] = smooth_gaussian(clusters(clusterind).firingrate,5);
% %             clusterind = clusterind+1;
% %         end
% %     end
% % end
% 
% timedata.binwidth = .05;
% timedata.timebinedges = 0:timedata.binwidth:recording_length_sec;
% timedata.timebincenters = 0.5*timedata.binwidth+timedata.timebinedges(1:end-1);
% 
% for clusterind = 1:length(clusters)
% spikecountarray = zeros(length(timedata.timebincenters),1);
% for binind = 1:(length(timedata.timebinedges)-1)
%     numspikes = length(find(clusters(clusterind).spiketimes>=timedata.timebinedges(binind) & clusters(clusterind).spiketimes<=timedata.timebinedges(binind+1)));
%    spikecountarray(binind) = numspikes;
%    clear numspikes
% end
% 
% figure(clusterind)
% crosscorr(spikecountarray,spikecountarray)
% end
% 
% 
