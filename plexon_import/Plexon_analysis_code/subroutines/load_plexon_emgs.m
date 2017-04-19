function [] = load_plexon_vicondata(animal,date)

analogfilename = [animal '_' date '.plx'];

% Emg data on plexon


emgchannels = 49:56;

for emgind = 1:length(emgchannels);
    channel = emgchannels(emgind);
    [~,~,~,~,v] =  plx_ad_v(analogfilename, channel-1);
    if length(v)>1
        disp('Emgs here')
    end
end

%
% numsamples = length(viconsync.frames);
%
% viconsync.plexon_times = starttime_sec+ (0:(1/ad_freq):(1/ad_freq)*(numsamples-1));
%





% % Vicon data on plexon
% tic
% [~,~,~,~,viconsync.trialdur] =  plx_ad_v(analogfilename, 17-1);
% [ad_freq,~,starttime_sec,~,viconsync.frames] =  plx_ad_v(analogfilename, 18-1);
% toc
%
% numsamples = length(viconsync.frames);
%
% viconsync.plexon_times = starttime_sec+ (0:(1/ad_freq):(1/ad_freq)*(numsamples-1));



