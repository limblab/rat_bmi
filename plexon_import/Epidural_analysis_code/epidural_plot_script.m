clear all;

%name of the directory where your data is stored - I do it this way because
%my computer mounts fsmresfiles with an arbitrary integer after it
temp = dir('/Volumes/');
di = find(~cellfun(@isempty, (strfind({temp.name}, 'fsm'))));
%data_dir = ['/Volumes/' temp(di(8)).name '/Basic_Sciences/Phys/L_MillerLab/data/Rats/plexon_data/'];
data_dir = ['/Volumes/fsmresfiles-1/Basic_Sciences/Phys/L_MillerLab/data/Rats/Data_Analysis/Epidural/E1/17-07-06/'];

figpath = '/Users/mariajantz/Documents/Work/figures/epidural/';
dosave = false;

%name of the file(s) to import
filenames = {'E1_170706_noobstacle_1'};
channels = [16 17 32:47]; %channels to import
%E2_170519_noobstacle_1.plx, also 5-26 t2
%full set of channels is Analog side 2 1:16, Vicon 17:18 Analog side 1 32:47, EMG 48:63

for f=1:length(filenames)
    %close all;
    filename = filenames{f};
    %if the data has already been converted, load
    if exist([data_dir filename '.mat'])
        disp('loading data');
        load([data_dir filename '.mat']);
        ch = setdiff(channels, an_data.channel);
        if ~isempty(ch)
            disp(mat2str(ch));
            rl = input('This file is missing channels; reload? y/n ', 's');
            if rl=='y'
                disp('importing data');
                an_data = import_plexon_analog(data_dir, filename, channels);
            end
        end
        %otherwise import and save it
    else
        disp('importing data');
        an_data = import_plexon_analog(data_dir, filename, channels);
    end
    
    %if you want to see the raw data...
    %choose the start/stop from Vicon sync channels
    sep_fact = 10;
    sync_ch = 1:2;
    sync_on = find(an_data.data(:, sync_ch(1))>1); 
    an_data.data_vic = an_data.data(sync_on(1):sync_on(end), :);
    
    data_ch = 32:47;
    exclude_ch = [1, 13, 16]; %channels to exclude from common average calculation
    data_range = 30000:40000; %window begins 30 seconds into collection of vicon
    
    %build filter for 60 hz and 100 hz noise
    d1 = designfilt('bandstopiir', 'FilterOrder', 2, 'HalfPowerFrequency1', 59, 'HalfPowerFrequency2', 61, ...
        'DesignMethod', 'butter', 'SampleRate', 1000);
    d2 = designfilt('bandstopiir', 'FilterOrder', 2, 'HalfPowerFrequency1', 99, 'HalfPowerFrequency2', 101, ...
        'DesignMethod', 'butter', 'SampleRate', 1000);
    
    f_data1 = filtfilt(d1, an_data.data_vic);
    f_data2 = filtfilt(d2, an_data.data_vic);
    f_data12 = filtfilt(d1, filtfilt(d2, an_data.data_vic));
    
    %to see power spectrum for each channel
    figure(20);
    pl_idx = [13:16 12 11 9 10 5 6 8 7 3 4 1 2];
    for i=1:16
        subplot(4, 4, pl_idx(i));
        pwelch(an_data.data_vic(data_range, i+2), 1000)
        title(['Channel ' num2str(data_ch(i))]);
    end
    set(gcf, 'Position', [400 80 1120 850]);
    
    %to see the vicon sync channels
    figure(21);
    for i=1:2
        sh(i) = subplot(2, 1, i);
        plot(an_data.data_vic(:, i));
    end
    linkaxes(sh, 'x');
    
    
    data_visual(an_data, data_ch, exclude_ch, data_range)
    
    if dosave
        %save the figures as both fig and pdf
        figure(1);
        savefig([figpath filename '_raw_trace']);
        figure(2);
        savefig([figpath filename '_ca_trace']);
        figure(10);
        savefig([figpath filename '_ca_spec']);
        figure(11);
        savefig([figpath filename '_raw_spec']);
        close(1, 2, 10, 11);
    end
end
