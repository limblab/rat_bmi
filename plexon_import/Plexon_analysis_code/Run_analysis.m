close all;
clear all;
home;

% directories.rawdata  = 'Y:\data\rats\';
directories.rawdata  = 'C:\Users\aak600\Desktop\data';
directories.figure   = 'C:\Users\aak600\Dropbox\motorcortex_database\figures';
directories.database = 'C:\Users\aak600\Dropbox\motorcortex_database\';
% 
% directories.rawdata = '/Volumes/L_MillerLab/data/rats/';
% directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
% directories.database = '/Users/amina/Dropbox/motorcortex_database/';

filename = 'A3_20160414_clusters-01.plx';

inds = strfind(filename,'_');
filestart = filename(1:inds(2)-1);

fontsize = 16;

cd(directories.rawdata)
load([filestart '_times.mat'])

[~,~,frequency,~,~,~,~,~,~,~,~,recording_length_sec,~] = plx_information(filename);
timedata.binwidth = 1;
timedata.timebinedges = 0:timedata.binwidth:recording_length_sec;
timedata.timebincenters = 0.5*timedata.binwidth+timedata.timebinedges(1:end-1);
if  isempty(times(1).range)
    timedata.times(1).range = [0 recording_length_sec];
    timedata.times(1).type  = 'Entire rec.';
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Get cluster data and save in a file, then use clusterdata file instead of .plx file (much faster) %%%%%%%%%%%%%%%%%%%%%%%%%

[tscounts, wfcounts, evcounts, contcounts] = plx_info(filename, 1);

cd(directories.rawdata) 
clusters = struct(); clusterind = 1;
for channel = 1:32
    for channelcluster = 1:4

        numspikes = wfcounts(channelcluster+1,channel+1);
        if numspikes > 0
            [channel channelcluster numspikes]

            clusters(clusterind).channel = channel;
            clusters(clusterind).channelcluster = channelcluster;

            [n, clusters(clusterind).spiketimes] = plx_ts(filename, clusters(clusterind).channel, clusters(clusterind).channelcluster);
[min(clusters(clusterind).spiketimes) max(clusters(clusterind).spiketimes)]
            clusters(clusterind).firingrate = histc(clusters(clusterind).spiketimes,timedata.timebinedges); clusters(clusterind).firingrate(end) = [];
            [clusters(clusterind).smoothedfiringrate] = smooth_gaussian(clusters(clusterind).firingrate,5);
            clusterind = clusterind+1;
        end
    end
end
% save([filestart '_clusterdata'],'clusters')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% load([filestart '_clusterdata'])
 colors = lines(length(clusters));
% 
% % %%%%%%%%%%%%%%%%%%%%%%% PLOT waveforms for all clusters for recording %%%%%%%%%%%%%%%%%%%%%%%%%
% % figure; set(gcf,'Units','Inches','Position',[1 1 6 6],'Renderer','zbuffer');
% % set(gcf,'PaperPositionMode','auto','InvertHardcopy','off','PaperSize',[10 10],'Color',[1 1 1]); hold on;
% % 
% % for clusterind = 1:length(clusters)
% %    subplot(6,6,clusterind)
% %    [n, npw, ts, wave] = plx_waves(filename, clusters(clusterind).channel, clusters(clusterind).channelcluster);
% % plot(wave','Color',colors(clusterind,:))
% % axis tight;
% % clear wave;
% % end
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% 
% %%%%%%%%%%%%%%%%%%%%%%%% PLOT spiketimes for all clusters for recording %%%%%%%%%%%%%%%%%%%%%%%%%
figure; set(gcf,'Units','Inches','Position',[1 1 6 4],'Renderer','zbuffer');
set(gcf,'PaperPositionMode','auto','InvertHardcopy','off','PaperSize',[10 10],'Color',[1 1 1]); hold on;

% subplot('Position',[.1 .1 .8 .4]); hold on;
% for timeind = 1:length(times)
%     patch([times(timeind).range fliplr(times(timeind).range)],[0 0 length(clusters) length(clusters)],'k','FaceColor','k','EdgeColor','none','FaceAlpha',1)
%     text(mean(times(timeind).range), 1.1*length(clusters),times(timeind).type,'Rotation',90,'FontSize',fontsize);
% end

for clusterind = 1:length(clusters)
    x = [clusters(clusterind).spiketimes clusters(clusterind).spiketimes]/60;
    y = [clusterind*ones(length(clusters(clusterind).spiketimes),1)-1 clusterind*ones(length(clusters(clusterind).spiketimes),1)];
    line(x',y','Color',colors(clusterind,:))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%% PLOT smoothed firing rates for all clusters for recording %%%%%%%%%%%%%%%%%%%%%%%%%

figure; set(gcf,'Units','Inches','Position',[1 1 8 5],'Renderer','zbuffer');
set(gcf,'PaperPositionMode','auto','InvertHardcopy','off','PaperSize',[10 10],'Color',[1 1 1]); hold on;

% subplot('Position',[.1 .1 .8 .6]); hold on;
% for timeind = 1:length(times)
%     patch([times(timeind).range fliplr(times(timeind).range)]/60,[0 0 length(clusters) length(clusters)],'k','FaceColor',[0 0 .6],'EdgeColor','none','FaceAlpha',.25)
%     text(mean(times(timeind).range)/60, 1.05*length(clusters),times(timeind).type,'Rotation',90,'FontSize',fontsize);
% end

cd(directories.figure);
for clusterind = 1:length(clusters)
    plot(timedata.timebincenters/60,clusters(clusterind).smoothedfiringrate/max(clusters(clusterind).smoothedfiringrate)+clusterind-1,'Color',colors(clusterind,:))
end
axis tight;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% clusterpairs = nchoosek(1:length(clusters),2);
% 
% for pairind = 1:length(clusterpairs)
%     
%     [paircorr,lags,bounds] = crosscorr(clusters(clusterpairs(pairind,1)).spiketimes,clusters(clusterpairs(pairind,2)).spiketimes);
% 
% figure(pairind);
% plot(lags,paircorr)
% end
