function new_spikes = get_New_PlexData(s, params, tsPointer)

new_spikes = zeros(length(params.n_neurons),1);
% get data
[n, ts_new] = PL_GetTS(s);
fwrite(tsPointer,ts_new,'double');

% check if data makes sense

if n > 0
    % If it covers too much time
    if (ts_new(end,4) - ts_new(1,4) >= 0.05)   % talk about this number later
       warning('Recieved spikes exceed bin time; interval: %f',ts_new(end,4) - ts_new(1,4))    
    end

    % remove stim artifacts
%     ts_new = remove_Artifacts(ts_new, params);
end

% want to worry about sorted neurons? will have to change this...
for i = params.neuronIDs(:,1).'
%     if i(2) % Get multi-unit activity
        new_spikes(params.neuronIDs(:,1) == i) = sum(i == ts_new(:,2))/params.binsize;
%     else    % Get individual units
%         
%     end
end


% firing_rates = [new_spikes'; data.spikes(1:end-1,:)];

% remove any high frequency noise
if any(new_spikes > 400)
    new_spikes(new_spikes>400) = 400;
    warning('Noise detected, FR capped at 400 Hz');
end