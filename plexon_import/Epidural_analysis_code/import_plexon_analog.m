function an_data = import_plexon_analog(data_dir, filename, channels)
%set up the EMG data structure
an_data = struct(); 
an_data.channel = []; %array of channel numbers
an_data.timestamps = []; %time stamps
an_data.data = []; %a/d values for those channels
an_data.freq = []; %save frequency of channels

cd(data_dir);
for channel = channels
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

an_data.data = an_data.data'; %We want the data in a CHANNELS x TIMESTAMPS format

if exist([data_dir 'mat_files/'], 'dir') ~= 7 %If mat_files folder doesn't exist:
    mkdir ([data_dir 'mat_files/']);
end
%now save the Epidural data as a .mat file in the mat_files folder
save([data_dir 'mat_files/' filename], 'an_data'); 

