 function [viconsync] = load_plexon_vicondata(animal,date)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get all analog channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analogfilename = [animal '_' date '.plx'];

% Vicon data on plexon
tic
[~,~,~,~,viconsync.trialdur] =  plx_ad_v(analogfilename, 17-1);
[ad_freq,~,starttime_sec,~,viconsync.frames] =  plx_ad_v(analogfilename, 18-1);
toc

numsamples = length(viconsync.frames);

viconsync.plexon_times = starttime_sec+ (0:(1/ad_freq):(1/ad_freq)*(numsamples-1));



