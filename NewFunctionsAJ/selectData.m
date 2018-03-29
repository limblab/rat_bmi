%% Create Final Data Structures

%Steps
%   1. Plot EMG channels and pick the good ones - store these in
%   goodEmgChannels
%   2. Plot field channels and pick the good ones (use the same scale) -
%   store these in goodFieldChannels
%   3. Check field channels for artifacts - store the times in
%   fieldArtifactTimes



%% look at the FIELD data and the EMG data to see which channels are bad
% cd('/Users/ambikasatish/Desktop/Miller Lab/matlab codes and data /rat_bmi-master/Extracted Data');
% load(strcat(standardFilename,'_e','.mat'));
%% Kinematic Data
%%%%% Select the desired kinematic measures
[KINdat, KINtimes] = get_CHN_data(kinematicData,'binned');
[Kinmetric,labels] = find_joint_angles(KINdat,kinematicData.KinMatrixLabels);
SelectedKinematicData.kindata = KINdat;
SelectedKinematicData.kinmeasures = Kinmetric;
SelectedKinematicData.labels = labels;
timeframe = kinematicData.Binnedtimeframe;
timeframe = timeframe';
%%
%%% This is only for N9 trials where you want chop off the last few chunks of data
[KINdat, KINtimes] = get_CHN_data(kinematicData,'binned');
KINtimes = KINtimes(1:8900); % added for N9 trial
KINdat = KINdat(1:8900,:); % added for N9 trial
[Kinmetric,labels] = find_joint_angles(KINdat,kinematicData.KinMatrixLabels);
SelectedKinematicData.kindata = KINdat;
SelectedKinematicData.kinmeasures = Kinmetric;
SelectedKinematicData.labels = labels;
kinematicData.Binnedtimeframe = kinematicData.Binnedtimeframe(1:8900);
timeframe = kinematicData.Binnedtimeframe;
timeframe = timeframe';
%% 
%%%%% look at the emg data
ts = mytimeseries;
ts.Time = 1:length(emgdata.data);
ts.Data = emgdata.data;
initialize_ts_gui(ts);
EMGChLabels = emgdata.channelNames2;
set_labels(EMGChLabels);
[emgch2use] = input('Select the good emg channel as [1,2,..]: '); %% choose which emg channels to process
SelectedEMGChannels = emgdata.data(:,emgch2use);
SelectedEMGChannelLabels = EMGChLabels(emgch2use);
% [SelectedEMGData, EMGtimes] = get_CHN_data(SelectedEMGChannels,'binned',timeframe');


%% To filter the selected EMG channels
EMGSelected_params.binsize = 0.05; EMGSelected_params.EMG_lp = 20; EMGSelected_params.EMG_hp = 50;  %EMGSelected_params.bins = ViconSync.binedges;
EMGSelected_params.channels = emgch2use; EMGSelected_params.bins = LFPParams.bins;

SelectedFilteredEMGData.freq = emgdata.freq;
SelectedFilteredEMGData.timeframe = emgdata.timeframe;
SelectedFilteredEMGData.channel = length(emgch2use);

emgsamplerate = emgdata.freq;

[bh,ah] = butter(3, EMGSelected_params.EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
[bl,al] = butter(3, EMGSelected_params.EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params

ii = 1; 
while ii<length(emgch2use)+1
    tempEMG1 = double(SelectedEMGChannels(:,ii));  
    tempEMG = filtfilt(bh,ah,tempEMG1); %highpass filter
    tempEMG = abs(tempEMG); %rectify     
%     figure();plot(tempEMG);
%     title(strcat('Original EMG of selected channel: ',EMGChLabels(emgch2use(ii))));

    
    NSDVal(ii) = input('Enter the threshold multiple for this EMG chanel: '); 
    sd = std(tempEMG);
    thresholdVal(ii) = NSDVal(ii)*sd; 

    removedTimes = find(tempEMG > (NSDVal(ii)*sd));
    % Plot the markers on the removedTimes
    marker = horzcat(removedTimes,2*ones(length(removedTimes),1));
%     plot(tempEMG);
%     title(strcat('Removed times of Selected EMG Channel: ',EMGChLabels(emgch2use(ii))));
%     hold on; scatter(marker(:,1),marker(:,2),'r','*');
    tempEMG1(removedTimes) = mean(tempEMG1);
    filteredEMG = tempEMG1;
%     hold on; plot(tempEMG1);
%     title(strcat('Filtered Selected EMG Channel: ',EMGChLabels(emgch2use(ii))));
   
    SelectedFilteredEMGData.data(:,ii) = filteredEMG; %low;
%     hold on; plot(SelectedFilteredEMGData.data(:,ii));% Plot low pass filtered data
    
    ii = ii+1;
       
end
SelectedFilteredEMGData.freq = emgdata.freq;
SelectedFilteredEMGData.timeframe = emgdata.timeframe;
SelectedFilteredEMGData.channel = 1:length(emgch2use);
SelectedEMGBinnedData = bin_plexon_EMG(SelectedFilteredEMGData, EMGSelected_params);
SelectedEMGData.ch2Use = emgch2use;
SelectedEMGData.NSD = NSDVal;
SelectedEMGData.removedArtifactTimes = removedTimes;
SelectedEMGData.dataOri = SelectedEMGBinnedData.binned.data;
SelectedEMGData.timeframeOri = SelectedEMGBinnedData.binned.timeframe;


%%%% to synchronize
SelectedEMGData.data = SelectedEMGData.dataOri;
SelectedEMGData.timeframe = SelectedEMGData.timeframeOri;
req_times = timeframe';
if length(req_times > 2)
    req_times = [req_times(1) req_times(end)];
end
outdata = SelectedEMGData.data;
outtimes = SelectedEMGData.timeframe; 

% % % %%
% % % %%%%%%% filter the binned emg data
% % % thresholdmul = 5*std(outdata); 
% % % for z = 1:size(outdata,2)
% % %     tempoutdata = outdata(:,z);
% % %     removedTimes = find(tempoutdata > thresholdmul(z));
% % %     outdata(removedTimes,z) = mean(tempoutdata);
% % % end


%%%%%%% to synchronize continued
ind = find((outtimes >= req_times(1)) & (outtimes <= req_times(2)));
SelectedEMGData.data = outdata(ind,:);
SelectedEMGData.timeframe = outtimes(ind);   
%%%%%%%%%
%%
%%Field Channels

%%%% look at the field data
%%%%%%%%    1. Determine artifact times to be removed
%%%%%%%%    2. Determine bad field channels

%Plot Field Channels
% ts = mytimeseries;
% ts.Time = fielddata.timeframe;
% ts.Data = fielddata.data';
% nchan = size(ts.Data,2);
% initialize_ts_gui(ts);
% nchannels = size(fielddata.data',2);
% set_labels(cellstr(num2str((1:nchan)')));
% set_scales(.5*ones(nchan,1));
%enter bad field channels
[badchan] = input('Select the bad field channels as [1,2..]: ');
FieldCh2Use = setdiff(1:32,badchan); %idenify good channels
LFPParams.data_ch = 1:length(FieldCh2Use);
% fieldArtifactTimes = input('Field Artifact Times (start1 end1; start2 end2): ');

%remove common average from good field channels
fielddata.data = fielddata.data(FieldCh2Use,:);
fielddata = do_LFPanalysis_funct_v2(fielddata, LFPParams);
[FIELDdata, FIELDtimes] = get_CHN_data(fielddata,'binned CAR',timeframe');
binnedFieldData = FIELDdata;

[fielddata.data,fielddata.oridata, removedFieldBins, nsd] = remove_field_artifacts1(binnedFieldData,10,3); 
% [fielddata.data,fielddata.oridata] = remove_synch_fields(binnedFieldData,timeframe,fieldArtifactTimes); %change remove_synch_spikes to get rid of finalDataSelection variable

SelectedFieldData = fielddata.data;

SelectedFieldDatastruct.oriData = fielddata.oridata;
SelectedFieldDatastruct.timeframe = FIELDtimes;
SelectedFieldDatastruct.artifactTimesRemoved = removedFieldBins;
SelectedFieldDatastruct.FieldCh2Use = FieldCh2Use;

%% Spike Data
[APdat, APtimes] = get_CHN_data(spikedata,'binned',timeframe');
[filtered_data,ori_spikedata, removedSpikeBins, nsd] = filter_spikes(APdat); % specify nsd value as input if required
SelectedSpikeDataStruct.cleanData = filtered_data;
SelectedSpikeDataStruct.NSD = nsd;
SelectedSpikeDataStruct.removedSpikeBins = removedSpikeBins;
SelectedSpikeData = filtered_data(:,FieldCh2Use);% remove spike channels for which fields are not good

% to plot the data before and after filtering
removed_bins_are = round(removedSpikeBins/20);
nchan = size(APdat,2);
% ts = mytimeseries;
% ts.Time = timeframe';
% ts.Data = ori_spikedata;
% initialize_ts_gui(ts);title('Original data');
% marker = horzcat(removed_bins_are,ones(length(removedSpikeBins),1));
% hold on; scatter(marker(:,1),marker(:,2),'r','*');
% set_labels(cellstr(num2str((1:nchan)')));



% spikeArtifactTimes = input('Field Artifact Times (start1 end1; start2 end2): ');
% binnedSpikeDataClean = remove_synch_fields(binnedSpikeData,timeframe,fieldArtifactTimes); %change remove_synch_spikes to get rid of finalDataSelection variable

%%
cd('/Users/ambikasatish/Desktop/Miller Lab/matlab codes and data /rat_bmi-master/SelectedDataAll');
save(strcat(standardFilename,'_s1','.mat'),'SelectedEMGData','SelectedEMGChannelLabels','SelectedFieldData','SelectedFieldDatastruct','SelectedSpikeData','SelectedKinematicData','timeframe','standardFilename');
% save(strcat(standardFilename,'_s','.mat'),'SelectedFieldData','SelectedKinematicData','timeframe','standardFilename');
% close all;

