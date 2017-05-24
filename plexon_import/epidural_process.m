close all; clear all; 

%name of the directory where your data is stored
data_dir = '/Users/mariajantz/Documents/Work/data/plexon_data/';
%name of the file to import
filename = 'E1_170519_noobstacle_1';
channels = [17 32:48]; %full set of channels is 48:63

%if the data has already been converted, load
if exist([data_dir 'mat_files/' filename '.mat'])
    disp('loading data'); 
    load([data_dir 'mat_files/' filename '.mat']);  
%otherwise import and save it
else
    disp('importing data'); 
    an_data = import_plexon_analog(data_dir, filename, channels);
end

%if you want to see the data...
sep_fact = 10; 
xvals = [1:size(an_data.data, 1)]/an_data.freq(1); 
data_plot = an_data.data + sep_fact*[1:size(an_data.data, 2)]; 
plot(xvals, data_plot)
xlabel('Seconds'); 
ylabel('Channel'); 
yticks(([1:length(channels)])*sep_fact); 
yticklabels(channels); 
ylim([0 (length(channels)+1)*sep_fact]);
set(gca, 'FontSize', 20); 




