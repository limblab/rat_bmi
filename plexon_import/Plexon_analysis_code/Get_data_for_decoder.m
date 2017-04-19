

profile off; profile on;
close all;
home;
clear all;

directories.rawdata = '/Volumes/L_MillerLab/data/rats/AK/';
directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
directories.database = '/Users/amina/Dropbox/motorcortex_database/';

% directories.rawdata = 'Y:\data\rats\AK\';
% directories.figure   = 'C:\Users\aak600\Dropbox\motorcortex_database\figures';
% directories.database = 'C:\Users\aak600\Dropbox\motorcortex_database\';

animal = 'A5';
date = '20160518';
updownaxis = 'x';

[~,trialdata_plexon] = load_plexon_data(animal,date,directories);

cd([directories.rawdata 'plexon'])
filename = [animal '_' date '.plx'];
% plx_spike_info(filename)
% plx_spike_info(filename): prints .plx f
[~,~,frequency,~,~,~,~,~,~,~,~,recording_length_sec,~] = plx_information(filename);
binneddata.timebinwidth = .05;
binneddata.timebinedges = 0:binneddata.timebinwidth:recording_length_sec;
binneddata.timecenters  = 0.5*binneddata.timebinwidth+binneddata.timebinedges(1:end-1);

% [trialdata_vicon]    = load_vicon_data(animal,date,directories,updownaxis);
% binneddata.cursorposlabels = {'toe';'heel';'knee';'hip_center';'hip_top';'hip_bottom'};
% for trialind = 1%length(experiments(expind).trialdata_vicon)% 1:
%     frametimes = experiments(expind).trialdata_plexon(trialind).frametimes;
% end

% subtract mean, take 3*std


for channel = 1:96
    
    
    cd([directories.rawdata 'plexon'])
    [n, spiketimes] = plx_ts(filename, channel, 1);
    
    if length(spiketimes)>1
        channel
    end
  %  clear spiketimes
%     spikecountarray = histc(spiketimes,binneddata.timebinedges); spikecountarray(end) = [];
    
%     if channelind == 1
%         binneddata.spikeratedata = zeros(length(binneddata.timecenters),length(channels));
%         
%     end
%     binneddata.spikeratedata(:,channelind) = spikecountarray;

end
profile viewer

% for channelind = 1%:96
%     
%     
%     cd([directories.rawdata '/plexon'])
%     [n, spiketimes] = plx_ts(filename, channels(channelind), 0);
%     spikecountarray = histc(spiketimes,binneddata.timebinedges); spikecountarray(end) = [];
%     
% %     if channelind == 1
% %         binneddata.spikeratedata = zeros(length(binneddata.timecenters),length(channels));
% %         
% %     end
% %     binneddata.spikeratedata(:,channelind) = spikecountarray;
% %     
% %     
%     
%     
% %     channels = [2 3 7 12];
% %     binneddata.neuronids = [1 0; 2 0; 3 0 ; 4 0];
%     
% %     clusterind = 0;
% 
% end
% 
