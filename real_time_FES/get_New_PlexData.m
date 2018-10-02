function new_spikes = get_New_PlexData(s, params, tsPointer)

new_spikes = zeros(1,size(params.neuronIDs,1));
% get data
[n, ts_new] = PL_GetTS(s);
fwrite(tsPointer,ts_new','double'); % make it so that the array is stored by row, rather than by column.

% check if data makes sense

if n > 0
    % If it covers too much time
    if (ts_new(end,4) - ts_new(1,4) >= 0.0525)   % talk about this number later
       warning('Recieved spikes exceed bin time; interval: %f',ts_new(end,4) - ts_new(1,4))    
    end

    % remove stim artifacts
    ts_new = remove_Artifacts(ts_new, params);
end

% want to worry about sorted neurons? will have to change this...
for i = params.neuronIDs(:,1)'
%     if i(2) % Get multi-unit activity
        new_spikes(params.neuronIDs(:,1) == i) = sum(i == ts_new(:,2))/params.binsize; % this won't actually be a proper bin size if time elapsed > 50 ms
%     else    % Get individual units
%         
%     end
end


% remove any high frequency noise
if any(new_spikes > 400)
    new_spikes(new_spikes>400) = 400;
    warning('Noise detected, FR capped at 400 Hz');
end