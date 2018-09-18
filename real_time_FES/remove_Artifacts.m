function clean_ts = remove_Artifacts(spikes, params)
%remove_Artifacts 

%Params for artifact removal
max_nbr_spikes         = 10;
reject_bin_size     = 0.001; % if 10 channels fire in less than 1 ms

%Matrix is ordered by ts, independent of channel
%Roll over list with window size 'reject_bin_size' looking for at least
% 'max_nbr_spikes'
artifacts = [];

for i = 1:size(spikes,1)
    %Check if artifact already was recorded
    if ismember(i,artifacts)
        continue; 
    end    
    
    %check how many spikes occur in 'bin_size'
    num_events = length(find(spikes(i:end,4)-spikes(i,4) < reject_bin_size));
    if num_events >= max_nbr_spikes
        artifacts = [artifacts; [i:i+num_events-1]'];
    end
end



%Get rid of ts that are artifact
for i = length(artifacts):-1:1
    spikes(artifacts(i),:) = [];    
end

%Artifacts output
if length(artifacts) > 99
    disp([num2str(length(artifacts)) ' artifacts in bin'])    
end

clean_ts = spikes;