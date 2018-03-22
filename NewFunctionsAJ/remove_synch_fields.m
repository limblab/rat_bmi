function [binnedFieldDataClean, binnedFieldData] = remove_synch_fields(binnedFieldData,timeframe, fieldArtifactTimes)
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
%   Returns the updated fielddata structure.


originalData = binnedFieldData;
nchan = size(originalData,2);


%start times and end times of artifact
%artifactTimes = [12 12.3;22.75 22.95];
artifactTimes = fieldArtifactTimes;


cleanData = [];
    for i = 1:nchan
        fddata = originalData(:,i);
        for j = 1:size(artifactTimes,1)
            artifactBegin = artifactTimes(j,1);
            artifactEnd = artifactTimes(j,2);
            useind = find((timeframe > artifactBegin) & (timeframe < artifactEnd));
%             fddata(useind) = NaN;  
            fddata(useind) = 0;  
            fddata(useind) = mean(fddata);

        end
        cleanData = horzcat(cleanData,fddata);
    end

 binnedFieldDataClean = cleanData;
%fielddata.binnedEpiduralData.CAR3 = cleanData;
%fielddata.binnedEpiduralData.CAR3WithArtifacts = originalData; % keep the original data around

