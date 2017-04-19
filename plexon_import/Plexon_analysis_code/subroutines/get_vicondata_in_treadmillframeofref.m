function vicondata = get_vicondata_in_treadmillframeofref(vicondata)

for trialind = 1:length(vicondata.trials)
    
    if ~isempty(vicondata.trials(trialind).treadmill)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute treadmill Frame of Reference (FoR)
    
    [~, RT_t2g] = computeTreadmillFoR(vicondata.trials(trialind).treadmill.markerpos); %changed from above line..
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Transformation onto treadmill frame of ref
    
    % Treadmill
    treadmillmarkerpos.tdmref   = (RT_t2g*[vicondata.trials(trialind).treadmill.markerpos ones(4,1)]')';
    vicondata.trials(trialind).treadmill.tdmref.markerpos = treadmillmarkerpos.tdmref(:,1:3);
    
    % Rat
    numframes = length(vicondata.trials(trialind).rat.(vicondata.trials(trialind).rat.markernames{1})(:,1));
    
    for markerind=1:length(vicondata.trials(trialind).rat.markernames)
        markername = vicondata.trials(trialind).rat.markernames{markerind};
        vicondata.trials(trialind).rat.tdmref.(markername) = (RT_t2g * [vicondata.trials(trialind).rat.(markername) ones(numframes,1)]')';
        vicondata.trials(trialind).rat.tdmref.(markername) = vicondata.trials(trialind).rat.tdmref.(markername)(:,1:3);
    end
    
    % Obstacles
    for markerind=1:length(vicondata.trials(trialind).obstacle.markernames)
        markername = vicondata.trials(trialind).obstacle.markernames{markerind};
        vicondata.trials(trialind).obstacle.tdmref.(markername) = (RT_t2g * [vicondata.trials(trialind).obstacle.(markername) ones(numframes,1)]')';
        vicondata.trials(trialind).obstacle.tdmref.(markername) = vicondata.trials(trialind).obstacle.tdmref.(markername)(:,1:3);
    end
%     
%     
%     if isfield(vicondata.trials(trialind).rat,'hip_top') && isfield(vicondata.trials(trialind).rat,'foot')
%         rat.angles.limb = computeAngle(vicondata.trials(trialind).rat.hip_top, vicondata.trials(trialind).rat.hip_center, vicondata.trials(trialind).rat.foot);
%     disp('hi limb angle')
%     end
%     if isfield(vicondata.trials(trialind).rat,'hip_top') && isfield(vicondata.trials(trialind).rat,'foot')
%         rat.angles.hip  = computeAngle(vicondata.trials(trialind).rat.hip_top, vicondata.trials(trialind).rat.hip_center, vicondata.trials(trialind).rat.knee);
%         disp('hi hip angle')
% end
%     if isfield(vicondata.trials(trialind).rat,'hip_top') && isfield(vicondata.trials(trialind).rat,'foot')
%         
%         rat.angles.knee = computeAngle(vicondata.trials(trialind).rat.hip_center, vicondata.trials(trialind).rat.knee, vicondata.trials(trialind).rat.heel);
%         disp('hi knee angle')
% end
%     if isfield(vicondata.trials(trialind).rat,'hip_top') && isfield(vicondata.trials(trialind).rat,'foot')
%         rat.angles.ankle = computeAngle(vicondata.trials(trialind).rat.knee, vicondata.trials(trialind).rat.heel, vicondata.trials(trialind).rat.foot);
%         disp('hi ankle angle')
% end

    end
end