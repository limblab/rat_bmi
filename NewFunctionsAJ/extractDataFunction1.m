% close all; clear all; home;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Wrapper script to convert one or several .plx files to a 
%   .mat file of binned data.
%
% PARAMETERS:
%   directory.rawdata     : Directory with .plx files
%   directory.database    : Directory where .mat binned files will be saved
%   binSize               : Bin Size desired
%   sorted                : Whether we have sorted spikes on a .plx
%
% OUTPUTS:
%   nameoffile_binned.mat : the binned file! Yessss!
%
% TIPS:
%
% Written by Pablo Tostado & Maria Jantz. Updated May 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%  updating the way that time is handled in here 9/17
%  Start by identifying a common set of bin edge definitions for all Plexon
%  data.  These bins are defined with respect to the Vicon onset, so time =
%  0 is when Vicon acquisition begins.
%
%  The bin edges are defined to go past the beginning and the end of the
%  timeframe, so that those bins take up the remnants of the data.
%
%  For each data stream, a single number is used to define the value of
%  that data for the range of times spanned by the bins.  
%
%  The time for that bin was taken as the right edge of each binedge
%  (rather than the center of the bin).  This is a choice so that there is
%  a sample at t=0.
%
%  For the field data, I took each bin then found the field data that
%  relates to those bin times. I.e. for the bin going from time -binsize to
%  time zero, I pulled the data from field from -LFPwindowsize to time
%  zero.  This maintains causality.  The time for this bin was labelled as
%  the right edge, i.e. time zero.
%
%  I could probably do the same thing, but define everything as the bin
%  centers.  It would work out to be the same thing.

%% Find the offset between the Vicon and the Plexon acquisition files

filenames = dir(SPIKEtargetfile);
filename = strtok(filenames(1).name,'.');  % get rid of the extension for the next file    
Vicon_sync = import_plexon_analog([pwd '/'], filename, viconCh); %Import the Vicon synchronizing channel

% Keep only data the data when Vicon was recording:
viconChannel = find(Vicon_sync.channel == viconCh);

plxVicon = Vicon_sync.data(viconChannel,:) > 1;
plxFreq = Vicon_sync.freq(1);
ind = find(plxVicon);  % find the samples when Vicon is collecting data

useind = ind(1);
if length(find(diff(plxVicon) > .5)) > 1
    disp('maybe more than one segment of Vicon acquisition in this file')
    plot(Vicon_sync.data)    
    ind2 = find(diff(ind)>1);
    indices = [1 ind2+1];
    title(ind(indices))
    resp = inputdlg('which index do you want?');
    useind = ind(indices(str2num(resp{1})));
end

ViconSync.OnsetSample = useind;  % the Plexon sample where Vicon starts  - assuming only a single period of collection in each file
ViconSync.OnsetTime = Vicon_sync.timeframe(useind);  % the time in the Plexon file when Vicon starts
% ViconSync.OffsetSample = ind(end);   % the sample where the Vicon stops
% ViconSync.OffsetTime = ViconSync.OffsetSample/plxFreq;  % the time where the Vicon stops
disp(['vicon starts ' num2str(ViconSync.OnsetTime) ' seconds in Plexon file'])

ViconSync.timeframe_plexon = Vicon_sync.timeframe;
ViconSync.timeframe_aligned = Vicon_sync.timeframe - ViconSync.OnsetTime;  % this has the times of plexon analog signals, such that t = 0 is when Vicon starts

%% define bins in Plexon time

mintime = ViconSync.timeframe_aligned(1)-binSize;
maxtime = ViconSync.timeframe_aligned(end) + 2*binSize;

part1 = -(0:binSize:(-mintime));  % these are the bins to the left of zero
part1 = fliplr(part1);

part2 = binSize:binSize:maxtime;  %these are the bins to the right
ViconSync.binedges = [part1 part2];

%% Read in the spike data and bin their rates

filenames = dir(SPIKEtargetfile);
fileind = 1;  % vestigial?
filename = filenames(fileind).name;

%Load neural data and bin it.
spikedata = load_plexondata_spikes_v2(filename, binSize, sorted, spikeCh);
% spikedata = remove_synch_spikes(spikedata); %%% the cleaned spike data is stored as spikedata.channels
spikedata = align_plexon_spikes(spikedata,ViconSync);  % uses the info in ViconSync to modify the spike data in plexondata so the streams are aligned
spikedata.datatype = 'spike';

%% read in EMG data and bin them
filenames = dir(EMGtargetfile);
fileind = 1;
filename = filenames(fileind).name;

%Load EMG data and bin it.
EMG_params.binsize = binSize; EMG_params.EMG_lp = 20; EMG_params.EMG_hp = 50;  EMG_params.bins = ViconSync.binedges;
EMG_params.channels = EMGCh;
[emgdatabin, emgdata] = load_plexondata_EMG_v2(filename, EMG_params);
emgdata = align_plexon_analog(emgdata,ViconSync);
emgdata = bin_plexon_EMG(emgdata, EMG_params);
emgdata.datatype = 'emg';

% Get EMG channel names
emgChannelNames = containers.Map('KeyType','double','ValueType','char');
[n,allChannelNames] = plx_adchan_names(SPIKEtargetfile);
for i = 1:length(emgdata.channel)
    emgChannelNames(emgdata.channel(i)) = deblank(allChannelNames(emgdata.channel(i),:));
end
emgdata.channelNames = emgChannelNames;
emgdata.channelNames2 = EMGCh_labels;
emgdata.params = EMG_params;
%%  Read in kinematic data, express relative to hip, and bin them

kinematicData = importVicon([filenameKin]);  %Import kinematics

Kinparams.viconScalingFactor = viconScalingFactor; Kinparams.referenceMarker = referenceMarker; Kinparams.ViconFreq = kinematicData.freq;
kinematicData = zero_kinematic_data(kinematicData,Kinparams);

temp = kinematicData.timeframe;
ind = find((ViconSync.binedges >= temp(1)) & (ViconSync.binedges <= temp(end)));
% ind = [ind ind(end)+1];
ind = [ind(1)-1 ind];
viconbinedges = ViconSync.binedges(ind);

LFPParams.bins = ViconSync.binedges;

kinematicData = bin_kinematic_data(kinematicData,viconbinedges); 
kinematicData.datatype = 'kinematic';

%% read in FIELD data
filenames = dir(SPIKEtargetfile);
filename = strtok(filenames(1).name,'.');
fielddata = import_plexon_analog([pwd '/'], filename, fieldCh); %Import LFPs
% fielddata = add_timeframe(fielddata);
fielddata = align_plexon_analog(fielddata,ViconSync);
fielddata.datatype = 'field';


%% wrap up - save data into file, create emg, spike, and field plots

cd('/Users/ambikasatish/Desktop/Miller Lab/matlab codes and data /rat_bmi-master/Extracted Data');
save(strcat(standardFilename,'_e','.mat'),'emgdata','spikedata','fielddata','kinematicData','LFPParams','standardFilename');






