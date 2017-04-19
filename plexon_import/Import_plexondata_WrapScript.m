close all; clear all; home;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Wrapper script to convert one or several .plx files to a 
%   .mat file of binned data.
%
% PARAMETERS:
%   directory.rawdata     : Directory with stored .plx files
%   directory.database    : Directory where .mat binned files will be saved
%   binSize               : Bin Size desired
%
% OUTPUTS:
%   nameoffile_binned.mat : the binned file! Yessss!
%
% TIPS:
%
% Written by Pablo Tostado & Maria Jantz. Updated April 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If the plexon routines are not already in the Path:
plexonRoutinesPath = 'YourPath\rat_bmi\plexon_import';
addpath(genpath(plexonRoutinesPath));

% Set the directories' paths:
directory = 'YourPath\rat_bmi\';
directories.rawdata = [directory 'Rawdata'];
directories.database = [directory 'Database'];
cd(directories.rawdata)

%FILENAME : Be specific if you only want one certain file
targetfile = '*21.plx'; 
filenames = dir(targetfile);

% BIN SIZE: Specify desired bin size
binSize = 0.05;

for fileind = 1:length(filenames)
    filename = filenames(fileind).name;
    
    indsUnderscore = strfind(filename,'_');
    indsPoint = strfind(filename,'.');
    
    animal = filename(1:indsUnderscore(1)-1);
    date   = filename(indsUnderscore(1)+1:indsPoint(1)-1);
    
    [num2str(fileind) '  ' num2str(length(filenames)) '  ' animal '  ' date];
    
    cd(directories.rawdata)
    plexondata = load_plexondata_spikes(filename, binSize);
    
    % ADD CALL TO VICON DATA. !!! This functionality has not been fixed, might not work.
    % plexondata.viconsync = load_plexon_vicondata(animal,date);
 
    % ADD CALL TO MARIA'S EMG FUNCTION
    % load_plexon_emgs(animal,date);

    cd(directories.database)
    save([animal '_' date '_plexondata.mat'],'plexondata')    
end


clear;