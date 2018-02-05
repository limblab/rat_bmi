function [n,bins] = bin_PlexNet(ts, cutoff)
%
% INPUTS:
%   -ts: n by 4 matrix of time sorted timestamps
%        column 2 contains channel number
%        column 4 contains timestamp
%   -cutoff: Ignore all timestamps later than this
% 
% OUPUTS:
%   -bins: Binned, sorted (num_channels by 1) matrix  
%   -n: Position of first unused timestamp (# of recorded + 1)
%
% TODO:
%

spike_channels = [1:16 33:48];
bins = zeros(length(spike_channels),1);


for n = 1:length(ts) 
    if ts(n,4) > cutoff
        break;
    end    
    ch = find(spike_channels == ts(n,2));
    bins(ch) = bins(ch) + 1;   
end