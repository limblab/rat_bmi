% function [raw, jump_times] = get_raw_plx(filename, opts)

% plx_ad(filename, channel): read all a/d data for the specified channel from a .plx or .pl2 file
%              returns raw a/d values
%
% [adfreq, n, ts, fn, ad] = plx_ad(filename, channel)
% [adfreq, n, ts, fn, ad] = plx_ad(filename, 0)
% [adfreq, n, ts, fn, ad] = plx_ad(filename, 'FP01')
%
% INPUT:
%   filename - if empty string, will use File Open dialog
%   channel - 0-based channel number or channel name
%
%           a/d data come in fragments. Each fragment has a timestamp
%           and a number of a/d data points. The timestamp corresponds to
%           the time of recording of the first a/d value in this fragment.
%           All the data values stored in the vector ad.
%
% OUTPUT:
%   adfreq - digitization frequency for this channel
%   n - total number of data points
%   ts - array of fragment timestamps (one timestamp per fragment, in seconds)
%   fn - number of data points in each fragment
%   ad - array of raw a/d values

%
% for channel = 1:32
%         [adfreq, n, ts, fn, ad] = plx_ad(filename, channel);
%
%     figure;plot(ad(1:10000))
%
%
% end
close all;
a=lines(10);
peakbin = 8;
for channel = 1%:32
    
    [n, npw, ts, waveforms] = plx_waves(filename, 1, 0);
    shifted_waveforms = NaN(length(waveforms(:,1)),32);
    
    for waveind = 1:length(wave(:,1))
        waveform = waveforms(waveind,:);
        [peaks(waveind),ind] = max(abs(waveform(5:15)));
        peakind(waveind) = ind+4;
        shift = peakind(waveind) - peakbin;
      
        if shift > 0
            shifted_waveforms(waveind,1:(32-abs(shift))) = waveform((shift+1):32);
                   elseif shift == 0
            shifted_waveforms(waveind,:) = waveform;
        end
        clear waveform; 
    end
end

