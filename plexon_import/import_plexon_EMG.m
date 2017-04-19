%name of the directory where your data is stored
data_dir = '/Users/mariajantz/Documents/Work/data/plexon/';

%name of the file to import
filename = 'A16_20161027';

%set up the EMG data structure
emg_data = struct(); 
emg_data.channel = []; %array of channel numbers
emg_data.timestamps = []; %time stamps
emg_data.data = []; %a/d values for those channels

cd(data_dir);
for channel=49:64 %I think this is really just 48:64 but I'm hedging my bets
    %import data
    [adfreq, ~, ts, ~, ad] = plx_ad_v([filename '.plx'], channel);
    %if there is data on a channel, add it to the data structure
    if ad~=-1
        disp(['channel ' num2str(channel) ' has actual values so save them'])
        emg_data.data(:, end+1) = ad; 
        emg_data.timestamps(end+1) = ts; 
        emg_data.channel(end+1) = channel; 
        %figure; plot(ad, '.-')
    end 
end

%if you want to see the data...
plot(emg_data.data + [1:size(emg_data.data, 2)])

%now save the EMG data as a .mat file in the same folder as the other data
save(filename, 'emg_data'); 


