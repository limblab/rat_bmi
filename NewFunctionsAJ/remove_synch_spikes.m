function [spikedata] = remove_synch_spikes(spikedata,varargin)
%function [spikedata] = remove_synch_spikes(spikedata,  binsize, NSD, DISPLAY)
%   Function to identify and reject times with too many synchronous spikes.
%   Combines all spike recorded across all channels, bins them according to
%   BINSIZE (default .0005s), then identifies bins that have unexpectedly
%   large numbers of events within them.  NSD is the multiple of the
%   standard deviation of the bin count to use to detect 'unexpectedly'
%   more events.  NSD defaults to 20. If DISPLAY is 1 (default 1),
%   it will display a window showing the bin counts before and after the
%   rejection criterion is applied.
%
%   Returns the updated spikedata structure.

binsize = 0.0005;
NSD = 20;
DISPLAY = 1;
if nargin == 2
    binsize = varargin{1};
elseif nargin == 3
    binsize = varargin{1};
    NSD = varargin{2};
elseif nargin == 4
    binsize = varargin{1};
    NSD = varargin{2};
    DISPLAY = varargin{3};
end

rawdata = spikedata.channels;
nchan = length(rawdata);
allsptimes = [];
for ii = 1:nchan
    nclust = length(rawdata(ii).clusters);
    for jj = 1:nclust
        allsptimes = [allsptimes; rawdata(ii).clusters(jj).spiketimes];
    end
end

binedges = [0:binsize:max(allsptimes)];
% [N,binedges] = histcounts(allsptimes,'BinWidth',binsize);
[N,binedges] = histcounts(allsptimes,binedges);
bin_mid = binedges(1:end-1) + binsize/2; %these are the times for the center of the bin
sd = std(N);
ind = find(N > (NSD*sd + mean(N)));  % the indices into the bins where there are more spikes than expected
rawdata2 = rawdata;
for nn = 1:length(ind)  % go through each of the bad bins
    badtime = bin_mid(ind(nn));
    t1 = badtime - binsize;  t2 = badtime + binsize;
%     t1 = binedges(ind(nn));  t2 = binedges(ind(nn) + 1);
    for ii = 1:nchan
        nclust = length(rawdata(ii).clusters);
        for jj = 1:nclust
            sptimes = rawdata2(ii).clusters(jj).spiketimes;
            useind = find((sptimes < t1) | (sptimes > t2)); % keep all spikes outside of the bad window
            rawdata2(ii).clusters(jj).spiketimes = sptimes(useind);
%             disp(length(useind)-length(sptimes));
        end
    end
    
end

spikedata.rawchannels = rawdata;  % keep the raw data around
spikedata.channels = rawdata2;  % assign the 'cleaned data' into the channels field

nchan = length(rawdata2);
allsptimes2 = [];
for ii = 1:nchan
    nclust = length(rawdata2(ii).clusters);
    for jj = 1:nclust
        allsptimes2 = [allsptimes2; rawdata2(ii).clusters(jj).spiketimes];
    end
end

[N2,binedges] = histcounts(allsptimes2,binedges);

if DISPLAY
    figure
    subplot(2,1,1)
    plot(N,'.')
    a = axis;
    subplot(2,1,2)
    plot(N2,'.')
    axis(a);
end
