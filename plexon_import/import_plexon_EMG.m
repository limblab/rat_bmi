%name of the directory where your data is stored
data_dir = '/Users/mariajantz/Documents/Work/data/plexon_data/';

%name of the file to import
filename = 'E1_170519_noobstacle_1';

%set up the EMG data structure
emg_data = struct(); 
emg_data.channel = []; %array of channel numbers
emg_data.timestamps = []; %time stamps
emg_data.data = []; %a/d values for those channels
emg_data.freq = []; %save frequency of channels
channels = [17 33:48]; %full set of channels is 48:63

cd([data_dir 'plx_files/']);
for channel=channels
    %import data
    [adfreq, ~, ts, ~, ad] = plx_ad_v([filename '.plx'], channel);
    %if there is data on a channel, add it to the data structure
    if ad~=-1
        disp(['channel ' num2str(channel) ' has actual values so save them'])
        emg_data.data(:, end+1) = ad; 
        emg_data.timestamps(end+1) = ts; 
        emg_data.channel(end+1) = channel; 
        emg_data.freq(end+1) = adfreq; 
        %figure; plot(ad, '.-')
    end 
end

%if you want to see the data...
sep_fact = 10; 
xvals = [1:size(emg_data.data, 1)]/emg_data.freq(1); 
data_plot = emg_data.data + sep_fact*[1:size(emg_data.data, 2)]; 
plot(xvals, data_plot)
xlabel('Seconds'); 
ylabel('Channel'); 
yticks(([1:length(channels)])*sep_fact); 
yticklabels(channels); 
ylim([0 (length(channels)+1)*sep_fact]);
set(gca, 'FontSize', 20); 


%now save the EMG data as a .mat file in the same folder as the other data
save([data_dir 'mat_files/' filename], 'emg_data'); 


