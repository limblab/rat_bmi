close all; clear all; home;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Wrapper script to convert one or several .plx files to a 
%   .mat file of binned data.
%
% PARAMETERS:
%   directory.rawdata     : Directory with .plx files
%   directory.database    : Directory where .mat binned files will be saved
%   binSize               : Bin Size desired
%   sorted                : Whether we have sorted spikes on a .plx
%
% OUTPUTS:
%   nameoffile_binned.mat : the binned file! Yessss!
%
% TIPS:
%
% Written by Pablo Tostado & Maria Jantz. Updated May 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add directories to path
myPath = 'C:\Users\Pablo_Tostado\Desktop\Northwestern_University\MyWorkFolder\Analysis';

% In case the plexon routines are not already in the Path:
plexonRoutinesPath = [myPath '\rat_bmi\plexon_import'];
addpath(genpath(plexonRoutinesPath));

% Set the directories' paths:
directory = [myPath '\rat_bmi\'];
directories.rawdata = [directory 'Rawdata'];
directories.database = [directory 'Database'];
cd(directories.rawdata)

%% Set params

% PARAMS: Specify desired bin size and if file is sorted
binSize = 0.05;
sorted = 0; % Change to 1 if you're using sorted.plx file, if unsorted, set to 0

%FILENAME : Be specific if you only want one certain file
SPIKEtargetfile = 'A15_170512_noobstacle_1.plx';        % !Different from original file if sorted
EMGtargetfile = 'A15_170512_noobstacle_1.plx';          % EMGs are not saved in the sorted file after offline sorting

filenames = dir(SPIKEtargetfile);

for fileind = 1:length(filenames)
    filename = filenames(fileind).name;
    
    indsUnderscore = strfind(filename,'_');
    indsPoint = strfind(filename,'.');
    
    animal = filename(1:indsUnderscore(1)-1);
    date   = filename(indsUnderscore(1)+1:indsPoint(1)-1);
    
    [num2str(fileind) '  ' num2str(length(filenames)) '  ' animal '  ' date];
    
    cd(directories.rawdata)
    
    %Load neural data and bin it.
    plexondata = load_plexondata_spikes(filename, binSize, sorted);
    plexondata = create_spikeratedata_matrix (plexondata);
    
    %Add timeframe
    numBins = length(plexondata.channels(1).clusters.binneddata.spikeratedata);
    plexondata.timeframe = (0:binSize:numBins*binSize-binSize)';
    
    filenames = dir(EMGtargetfile);
    filename = filenames(fileind).name;
    
    try
        %Load EMG data and bin it.
        EMG_params.binsize = binSize; EMG_params.EMG_lp = 5; EMG_params.EMG_hp = 50;
        [emgdatabin, emgdata] = load_plexondata_EMG(filename, EMG_params); 
        plexondata.emgdatabin = emgdatabin; plexondata.emgdata = emgdata;
        %Name of channels. Change this line if there are actual names        
        plexondata.emgguide = cellstr(num2str(plexondata.emgdata.channel'))'; 
        
        %if you want to see the data...
        figure; plot(plexondata.emgdata.data(:,2:end) + [1:size(plexondata.emgdata.data, 2)-1]); title('Raw EMGs');
        figure; plot(plexondata.emgdatabin + [1:size(plexondata.emgdatabin, 2)]); title('Binned EMGs');
    catch 
        disp('Unable to load EMG data')
    end
    % ADD CALL TO VICON DATA. !!! This functionality has not been fixed, might not work.
    % plexondata.viconsync = load_plexon_vicondata(animal,date);
 
    %Create folder in Database to store animal info
    animalDir = [directories.database '\' animal '_' date];
    if ~exist(animalDir, 'dir')
        mkdir(animalDir)
    end
    
    cd(animalDir)
    save([animal '_' date '_binned.mat'],'plexondata')    
end


%clear; clc;