function [plexondata] = load_plexondata_spikes(filename, binSize)

%name of the file to import

%set up the EMG data structure
emg_data = struct(); 
emg_data.channel = []; %array of channel numbers
emg_data.timestamps = []; %time stamps
emg_data.data = []; %a/d values for those channels
emg_data.freq = [];

for channel = 49:64 %I think this is really just 48:64 but I'm hedging my bets
    %import data
    [adfreq, ~, ts, ~, ad] = plx_ad_v([filename '.plx'], channel);
    %if there is data on a channel, add it to the data structure
    if ad~=-1
        disp(['channel ' num2str(channel) ' has actual values so save them'])
        emg_data.data(:, end+1) = ad; 
        emg_data.timestamps(end+1) = ts; 
        emg_data.channel(end+1) = channel; 
        emg_data.freq = adfreq; %It will be overwritten, but all channels will have been collected at same freq
    end 
end

emgsamplerate = emg_data.freq;   %Rate at which emg data were actually acquired.
emg_times = single(0:1/emgsamplerate:(size(emg_data.data,1)-1)/emgsamplerate);
emg_data.data = [emg_times' emg_data.data]; %Add times to matrix

%if you want to see the data...
plot(emg_data.data + [1:size(emg_data.data, 2)])

% bin EMGs
params.binsize = binSize;
emgdatabin = bin_plexon_EMG(emg_data, params);

%now save the EMG data as a .mat file in the same folder as the other data
save(filename, 'emg_data'); 


