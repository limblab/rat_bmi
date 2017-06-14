function an_data = import_plexon_analog(data_dir, filename, channels)
%set up the EMG data structure
an_data = struct(); 
an_data.channel = []; %array of channel numbers
an_data.timestamps = []; %time stamps
an_data.data = []; %a/d values for those channels
an_data.freq = []; %save frequency of channels


cd([data_dir 'plx_files/']);
for channel=channels
    %import data
    [adfreq, ~, ts, ~, ad] = plx_ad_v([filename '.plx'], channel);
    %if there is data on a channel, add it to the data structure
    if ad~=-1
        disp(['channel ' num2str(channel) ' has actual values so save them'])
        an_data.data(:, end+1) = ad; 
        an_data.timestamps(end+1) = ts; 
        an_data.channel(end+1) = channel; 
        an_data.freq(end+1) = adfreq; 
        %figure; plot(ad, '.-')
    end 
end

%now save the EMG data as a .mat file in the same folder as the other data
save([data_dir 'mat_files/' filename], 'an_data'); 

