close all;
home;
clear all;

% directories.rawdata = 'C:\Users\aak600\Dropbox\motorcortex_database\plexondata\';
% directories.figure   = 'C:\Users\aak600\Dropbox\motorcortex_database\figures';
% directories.database = 'C:\Users\aak600\Dropbox\motorcortex_database\';
%
directories.rawdata = '/Users/amina/Dropbox/motorcortex_database/plexondata/';
directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
directories.database = '/Users/amina/Dropbox/motorcortex_database/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

animal = 'A10';
date  = '20160802';

cd(directories.database)
load([animal '_' date '_plexondata.mat'])
load([animal '_' date '_vicondata.mat'])

% function plexondata = get_viconsync_timing(plexondata)

viconsync_trialdur = plexondata.viconsync_trialdur;
viconsync_frames   = plexondata.viconsync_frames;
viconsynctimes     = plexondata.viconsynctimes;

viconsync_trialdur(viconsync_trialdur>1) = 1;
viconsync_trialdur(viconsync_trialdur<1) = 0;

trialstarts_viconsynci = find(diff(viconsync_trialdur)==1)+1;
trialends_viconsynci   = find(diff(viconsync_trialdur)==-1);
numtrials = length(trialstarts_viconsynci);

for trialind = 4%1:numtrials
    
    trialframes    = viconsync_frames(trialstarts_viconsynci(trialind):trialends_viconsynci(trialind));
    trialtimes     = viconsynctimes(trialstarts_viconsynci(trialind):trialends_viconsynci(trialind));
    trialstarttime = viconsynctimes(trialstarts_viconsynci(trialind));
    trialendtime   = viconsynctimes(trialends_viconsynci(trialind));
    trialduration  = trialendtime - trialstarttime;
    
    numframes = ceil(length(trialframes)/5);
    resampling = 10; % From 1 kHz
    squarewavesignal = (1+square(0:((2*pi)/5)/resampling:2*pi*(numframes+2),50))*4.5/2;
    
    for shift = 1:55
        shiftinds = shift:resampling:(resampling*length(trialtimes)+shift-1);
        corrs(shift) = corr(trialframes,squarewavesignal(shiftinds)');
    end
    maxinds = find(corrs >= .8);
    
    if length(maxinds)>5
        clear corrs;
        for shift = 1:40
            shiftinds = shift:resampling:(resampling*length(trialtimes)+shift-1);
            corrs(shift) = corr(trialframes,squarewavesignal(shiftinds)');
        end
        maxinds = find(corrs >= .8);
    end
    trialshift = mean(maxinds);
    figure; hold on;
    plot(corrs,'ko')
    line([trialshift trialshift],[0 1],'Color','r')
    clear corrs
    
    viconframetimes = (trialstarttime+trialshift/2000) + (-1:1/200:trialduration);
    viconframetimes(viconframetimes<trialstarttime) = [];
    viconframetimes(viconframetimes>trialendtime) = [];
    
    figure;hold on;
    plot(trialtimes,trialframes,'k.')
    plot(viconframetimes,5*ones(size(viconframetimes)),'ro')
    plexondata.trials(trialind).viconframetimes = viconframetimes;
    plexondata.trials(trialind).framesignal = trialframes;
    plexondata.trials(trialind).times       = trialtimes;
    plexondata.trials(trialind).starttime   = trialstarttime;
    plexondata.trials(trialind).endtime     = trialendtime;
    plexondata.trials(trialind).duration    = trialduration;
    
    clear viconframetimes;
end

[trialind  length(plexondata.trials(trialind).viconframetimes) length(plexondata.trials(trialind).times)/5  length(vicondata.trials(trialind).foot_updown)]

