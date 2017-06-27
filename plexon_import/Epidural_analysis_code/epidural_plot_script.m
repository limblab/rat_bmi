clear all;

%name of the directory where your data is stored - I do it this way because
%my computer mounts fsmresfiles with an arbitrary integer after it
temp = dir('/Volumes/'); 
di = find(~cellfun(@isempty, (strfind({temp.name}, 'fsm')))); 
data_dir = ['/Volumes/' temp(di).name '/Basic_Sciences/Phys/L_MillerLab/data/Rats/plexon_data/'];

figpath = '/Users/mariajantz/Documents/Work/figures/epidural/'; 
dosave = true; 

%name of the file(s) to import
filenames = {'E2_170519_noobstacle_1'};
channels = [16 17 32:47]; %channels to import
%E2_170519_noobstacle_1.plx, also 5-26 t2
%full set of channels is Analog side 2 1:16, Vicon 17:18 Analog side 1 32:47, EMG 48:63

for f=1:length(filenames)
    close all;
    filename = filenames{f};
    %if the data has already been converted, load
    if exist([data_dir 'mat_files/' filename '.mat'])
        disp('loading data');
        load([data_dir 'mat_files/' filename '.mat']);
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
    %plot the Vicon sync channels
    sep_fact = 10;
    sync_ch = 1:2; 
    xvals = [1:size(an_data.data, 1)]/an_data.freq(1);
    data_plot = an_data.data(:, sync_ch) + sep_fact*[1:size(an_data.data(:, sync_ch), 2)];
    plot(xvals, data_plot)
    xlabel('Seconds');
    xlim([0 xvals(end)]); 
    ylabel('Channel');
    yticks(([1:length(sync_ch)])*sep_fact);
    yticklabels(an_data.channel(:, sync_ch));
    ylim([0 (length(sync_ch)+1)*sep_fact]);
    set(gca, 'FontSize', 20);
    
    %to see power spectrum
    
    
    data_ch = 32:47;
    exclude_ch = [39:47]; %channels to exclude from common average calculation
    data_range = 10000:15000;
    
    %build filter for 60 hz and 100 hz noise
    d1 = designfilt('bandstopiir', 'FilterOrder', 2, 'HalfPowerFrequency1', 59, 'HalfPowerFrequency2', 61, ...
        'DesignMethod', 'butter', 'SampleRate', 1000); 
    d2 = designfilt('bandstopiir', 'FilterOrder', 2, 'HalfPowerFrequency1', 99, 'HalfPowerFrequency2', 101, ...
        'DesignMethod', 'butter', 'SampleRate', 1000); 
    
    f_data1 = filtfilt(d1, an_data.data); 
    f_data2 = filtfilt(d2, an_data.data); 
    f_data12 = filtfilt(d1, filtfilt(d2, an_data.data)); 
    
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
    end
end
