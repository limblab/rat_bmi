function [emgDataBin, emgData, timestamps] = load_plexondata_EMG(filename,varargin)
% [emgDataBin, emgData] = load_plexondata_EMG(filename,varargin)
%
%  --- load_plexondata_EMG ---
% Loads EMG data from a plexon file into a matlab structure and a binned
% matlab structure.
%
% - Input -
% filename          Name of the file
% params            struct with EMG binning parameters
%    binsize            bin size in seconds     [.05]
%    EMG_hp             EMG high pass filter corner in Hz [50]
%    EMG_lp             EMG low pass filter corner in Hz [10]
%    NormData           normalize the EMGs? [false]
%
% - Output -
% emgdatabin        Matrix containing binned EMG data       
% emgdata           Structure containing raw EMG data
% timestamps        timestamps of binned EMG data


% -- Changelog --
%   
% added channel names field, using plx_adchan_names. Added comments for help
% documentation, changed  the display and warnings a little -- KLB 2018.01.22


if nargin>1
    params = varargin{1};
    if ~isstruct(params)
        error('Input parameters must be formatted in a structure');
    end
end


emgDataBin = [];

%set up the EMG data structure
emgData = struct(); 
emgData.channel = []; %array of channel numbers
emgData.name = {}; % Cell array of channel names -- this will check that these are EMG channels
emgData.timestamps = []; %time stamps of full freq EMG data
emgData.data = []; %a/d values for those channels
emgData.freq = [];

% list of channels named 'EMG-xxx'
[~,names] = plx_adchan_names(filename); % character array of channel names
EMGList = {}; % EMG names
chanNums = []; % channel number -- 0 based (gotta match that plexon!)
for ii = 1:size(names,1) % there's gotta be a better way!
    if any(strfind(names(ii,:),'EMG-'))&& ~any(strfind(names(ii,:),'EMG-GND1'))

        EMGList{end+1} = names(ii,[names(ii,:)~=char(0)]); % save it into the list of EMGs
        chanNums(end+1) = ii-1;
    end
end

    
for channel = 1:length(EMGList) % for each channel labeled 'EMG-'
    %import data
    [adfreq, ~, ts, ~, ad] = plx_ad_v(filename, EMGList{channel});
    %if there is data on a channel, add it to the data structure
    if ad~=-1
        disp([EMGList{channel} ' contains data, saving to structure'])
        emgData.data(:, end+1) = ad; 
        emgData.timestamps(end+1) = ts; 
        emgData.channel(end+1) = chanNums(channel); % Analog channel name
        emgData.freq = adfreq; %It will be overwritten, but all channels will have been collected at same freq
        emgData.name(end+1) = EMGList(channel); % EMG channel name
        
    else
    warning([EMGList{channel} ' doesn''t have any data, skipping...'])    
    end
end

if ~isempty(emgData.channel)    
    emgsamplerate = emgData.freq;   %Rate at which emg data were actually acquired.
    emg_times = single(0:1/emgsamplerate:(size(emgData.data,1)-1)/emgsamplerate);
    emgData.data = [emg_times' emgData.data]; %Add times to matrix
    
    try
        if exist('params')
            [emgDataBin,timestamps] = bin_plexon_EMG(emgData, params);
        else
            [emgDataBin,timestamps] = bin_plexon_EMG(emgData);
        end
    catch
        emgDataBin = [];
        timestamps = [];
        warning('Could not bin EMGs');
        return;
    end
else
    fprintf('No EMG data was found\n');       
    
end



end
