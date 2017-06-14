close all; clear all;

%name of the directory where your data is stored
data_dir = '/Volumes/fsmresfiles/Basic_Sciences/Phys/L_MillerLab/data/Rats/plexon_data/';

%name of the file to import
filename = 'E1_170519_noobstacle_1';
channels = [17 18 32:48]; %channels to import
%full set of channels is Analog side 2 1:16, Vicon 17:18 Analog side 1 32:47, EMG 48:63

%TODO: update graphing things with channel labels based correctly on the
%channels graphed (if I change channels up here I end up with an incorrect
%y axis)

%if the data has already been converted, load
if exist([data_dir 'mat_files/' filename '.mat'])
    disp('loading data');
    load([data_dir 'mat_files/' filename '.mat']);
%otherwise import and save it
else
    disp('importing data');
    an_data = import_plexon_analog(data_dir, filename, channels);
end

%if you want to see the raw data...
plot_raw_data = true;
data_ch = 32:47;
%get indices of channels with good data
idx = find(ismember(an_data.channel, data_ch));

%TODO: this is kind of messy, deal with it
if plot_raw_data
    sep_fact = 10;
    xvals = [1:size(an_data.data, 1)]/an_data.freq(1);
    data_plot = an_data.data(:, idx) + sep_fact*[1:size(an_data.data(:, idx), 2)];
    plot(xvals, data_plot)
    xlabel('Seconds');
    ylabel('Channel');
    yticks(([1:length(data_ch)])*sep_fact);
    yticklabels(an_data.channel(:, idx));
    ylim([0 (length(data_ch)+1)*sep_fact]);
    set(gca, 'FontSize', 20);
end

%here's a quick wonky way of subtracting common average
common_av = mean(an_data.data(:, idx)');
new_data = (an_data.data(:, idx)'-common_av)';
figure;
data_plot = new_data + sep_fact*[1:size(an_data.data(:, idx), 2)];
plot(xvals, data_plot)
xlabel('Seconds');
ylabel('Channel');
yticks(([1:length(data_ch)])*sep_fact);
yticklabels(an_data.channel(:, idx));
ylim([0 (length(data_ch)+1)*sep_fact]);
set(gca, 'FontSize', 20);
%TODO - add correct scaling for amplitude of LFPs
yyaxis right;


%TODO: spectrogram with and without common av subtracted
figure(10); title('Subtracted Common Avg'); 
figure(11); title('Raw Data');
for i=1:size(new_data, 2)
    figure(10); 
    subplot(4, 4, i);
    spectrogram(new_data(:, i)); 
    title(['Channel ' num2str(channels(idx(i)))]);
    figure(11); 
    subplot(4, 4, i); 
    spectrogram(an_data.data(:, idx(i))); 
    title(['Channel ' num2str(channels(idx(i)))]); 
end
 

%TODO: bandpass filter at diff freqs



