nameoffile_binned = function EMG_WrapScript(plxDirectory,saveDirectory,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nameoffile_binned = function EMG_WrapScript(plxDirectory,saveDirectory,{filename},{binSize},{sorted})
%   Wrapper funciton to convert one or several .plx files to a 
%   .mat file of binned data.
%
% Inputs [default]:
%   plxDirectory          : Directory with .plx files
%   saveDirectory         : Directory where .mat binned files will be saved
%   fileName              : fileName of desired converted file [whole directory]
%   binSize               : Bin Size desired [50 ms]
%   sorted                : Whether we have sorted spikes on a .plx [no]
%
% Outputs:
%   nameoffile_binned.mat : the binned file! Yessss!
%
% TIPS:
%
% Written by Pablo Tostado & Maria Jantz. Updated May 2017
% 
% Changelog:
% * Changed to function, generalized some of the internal settings
%     -- KLB 2018.01.22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add directories to path
% Removed when changed to a function. All dependencies will need to be
% added by the user. This is to make everything more generalized, so
% everyone can use this.

% myPath = 'C:\Users\Pablo_Tostado\Desktop\Northwestern_University\MyWorkFolder\Analysis';

% In case the plexon routines are not already in the Path:
% plexonRoutinesPath = [myPath '\rat_bmi\plexon_import'];
% addpath(genpath(plexonRoutinesPath));

% Set the directories' paths:
% directory = [myPath '\rat_bmi\'];
% directories.rawdata = [directory 'Rawdata'];
% directories.database = [directory 'Database'];
% cd(directories.rawdata)

%% Set params

% PARAMS: Specify desired bin size and if file is sorted
switch nargin
    case 2
        binSize = 0.05;
        sorted = 0; % Change to 1 if you're using sorted.plx file, if unsorted, set to 0
    case 3
        binSize = varargin{1};
        sorted = 0;
    case 4
        binSize = varargin{1};
        sorted = varargin{2};
    otherwise
        error('Wrong number of inputs. Try again!')
end

% %FILENAME : Be specific if you only want one certain file
% SPIKEtargetfile = 'A15_170512_noobstacle_1.plx';        % !Different from original file if sorted
% EMGtargetfile = 'A15_170512_noobstacle_1.plx';          % EMGs are not saved in the sorted file after offline sorting

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

end