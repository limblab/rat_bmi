 function [analogchannels] = load_plexon_analogdata(animal,date)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get all analog channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analogfilename = [animal '_' date '.plx'];

for channelind = 1:length(clusterchannels)
    channel = clusterchannels(channelind);
    tic
    [ad_freq,~,starttime_sec,~,clusterdata.analogchannels(channel).v] =  plx_ad_v(analogfilename, channel-1);
    toc

%     figure(channel);
%     plot(clusterdata.analogchannels(channel).v(1:10^5))

    if ~isempty(clusterdata.analogchannels(channel).v)
        numsamples = length(clusterdata.analogchannels(channel).v);
    end
end

% Vicon data on plexon
tic
[ad_freq,~,starttime_sec,~,analogchannels.viconsync.trialdur] =  plx_ad_v(analogfilename, 17-1);
[ad_freq,~,starttime_sec,~,analogchannels.viconsync.frames] =  plx_ad_v(analogfilename, 18-1);
toc

numsamples = length(clusterdata.viconsync_frames);

analogchannels.viconsync.times = starttime_sec+ (0:(1/ad_freq):(1/ad_freq)*(numsamples-1));



