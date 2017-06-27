
pathName = '/Volumes/fsmresfiles/Basic_Sciences/Phys/L_MillerLab/data/Rats/kinematics/E1/'; 
fileName = '17-05-2602_no_obstacle_speed9';
path     = [pathName fileName '.csv'];

%if you get a "Marker not found" error check that the names below all match
%the names in the first row of the csv file, which are formatted as
%"tdmName:tdmMk" and "ratName:ratMk"
tdmName = 'treadmill';
tdmMks  = {'treadmill1', 'treadmill2', 'treadmill3', 'treadmill4'};

ratName = 'rat'; 
ratMks  = {'hip_top', 'hip_middle', 'hip_bottom', ...
    'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe'};

%this line does the importing
[events,rat,treadmill] = ...
    importViconData(path,ratName,tdmName,ratMks,tdmMks);

rlocs.names = {}; 
rlocs.x = []; rlocs.y = []; rlocs.z = [];
for i=1:length(ratMks)
    mk = rat.(ratMks{i});
    rlocs.names{end+1} = ratMks{i};
    rlocs.x(:, end+1) = mk(:, 1);
    rlocs.y(:, end+1) = mk(:, 2);
    rlocs.z(:, end+1) = mk(:, 3);
end

save([pathName fileName '.mat'], 'rlocs', 'rat');

