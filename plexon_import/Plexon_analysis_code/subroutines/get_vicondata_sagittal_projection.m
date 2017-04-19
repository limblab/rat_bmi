function vicondata = get_vicondata_sagittal_projection(vicondata)

% y is in direction of motion, x is side to side and z is up down. sagittal
% projection takes out x, so it is two dimensions: (y,z)

for trialind = 1:length(vicondata.trials)
    if ~isempty(vicondata.trials(trialind).rat)
        vicondata.trials(trialind).rat.sg   = structfun(@(x)x(:,2:3), vicondata.trials(trialind).rat.tdmref, 'UniformOutput', false);
        for markerind=1:length(vicondata.trials(trialind).rat.markernames)
            markername = vicondata.trials(trialind).rat.markernames{markerind};
            vicondata.trials(trialind).rat.sg.markername = vicondata.trials(trialind).rat.tdmref.(markername)(:,2:3);
        end
        
        if ~isempty(vicondata.trials(trialind).obstacle.markernames)
            vicondata.trials(trialind).obstacle.sg   = structfun(@(x)x(:,2:3), vicondata.trials(trialind).obstacle.tdmref, 'UniformOutput', false);
            for markerind=1:length(vicondata.trials(trialind).obstacle.markernames)
                markername = vicondata.trials(trialind).obstacle.markernames{markerind};
                vicondata.trials(trialind).obstacle.sg.markername = vicondata.trials(trialind).obstacle.tdmref.(markername)(:,2:3);
            end
        end
    end
end