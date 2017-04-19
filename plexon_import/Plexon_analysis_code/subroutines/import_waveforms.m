% function [raw, jump_times] = import_waveforms(filename)

%  plx_waves(filename, channel, unit): read waveform data from a .plx or .pl2 file
%
% [n, npw, ts, wave] = plx_waves(filename, channel, unit)
%
% INPUT:
%   filename - if empty string, will use File Open dialog
%   channel - 1-based channel number or channel name
%   unit  - unit number (0- unsorted, 1-4 units a-d)
%
% OUTPUT:
%   n - number of waveforms
%   npw - number of points in each waveform
%   ts - array of timestamps (in seconds)
%   wave - array of waveforms [npw, n], raw a/d values

dt_sec = 1/40000;

close all;
a=lines(10);
peakbin = 8;
for channel = 1%:32
    
    [n, npw, ts, waveforms] = plx_waves(filename, 1, 0);
    shifted_waveforms = NaN(length(waveforms(:,1)),32);
    
    for waveind = 1:length(wave(:,1))
        waveform = waveforms(waveind,:);
        [peaks(waveind),ind] = max(abs(waveform(5:15)));
        peakind(waveind)     = ind+4;
        shift = peakind(waveind) - peakbin;
    end
    
    shifted_peaktimes = ts+dt_sec*shift;
    
    binwidth = 1;
    timebinedges = 0:binwidth:recording_length_sec;
    timebincenters = 0.5*binwidth+timebinedges(1:end-1);
    firingrate = histc(shifted_peaktimes,timebinedges); firingrate(end) = [];
    [smoothedfiringrate] = smooth_gaussian(firingrate,5);
    
    figure;
    plot(timebincenters/60,firingrate)
    
    figure;
    plot(timebincenters/60,smoothedfiringrate)
    channels(channel).shifted_peaktimes = shifted_peaktimes;
    channels(channel).firingrate = firingrate;
    channels(channel).smoothedfiringrate = smoothedfiringrate;
    clear shift ind shifted_peaktimes
end


%         if shift > 0
%             shifted_waveforms(waveind,1:(32-abs(shift))) = waveform((shift+1):32);
%                    elseif shift == 0
%             shifted_waveforms(waveind,:) = waveform;
%         end
%         clear waveform;