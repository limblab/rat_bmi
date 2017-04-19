 function [trialdata_vicon] = load_vicon_data(animal,date,directories,updownaxis)

cd([directories.rawdata 'vicon/' animal '/' date])

viconfiles = dir('*.csv');

for trialind = 1:length(viconfiles)
    filename = viconfiles(trialind).name;
    
    fid = fopen(filename);
    filestring = textscan(fid,'%s', 'Delimiter',',','EmptyValue',NaN);
    filestrings = filestring{1};
    fclose all;
    
    fid = fopen(filename);
    data = dlmread(filename,',',5,0);
    data(data == 0) = NaN;
    fclose all;
    
    nummarkers = (length(data(1,:))-2)/3;
    toe        = struct();
    heel       = struct();
    knee       = struct();
    hip_center = struct();
    hip_top    = struct();
    hip_bottom = struct();
    
    treadind = 1;
    for markerind = 1:nummarkers
        name = filestrings{3*(markerind-1)+5};
        if ~isempty([strfind(name,'toe') strfind(name,'Toe')] )
            toe.x = data(:,3*(markerind-1)+3);
            toe.y = data(:,3*(markerind-1)+4);
            toe.z = data(:,3*(markerind-1)+5);
        elseif ~isempty(strfind(name,'heel'))
            heel.x = data(:,3*(markerind-1)+3);
            heel.y = data(:,3*(markerind-1)+4);
            heel.z = data(:,3*(markerind-1)+5);
        elseif ~isempty(strfind(name,'knee'))
            knee.x = data(:,3*(markerind-1)+3);
            knee.y = data(:,3*(markerind-1)+4);
            knee.z = data(:,3*(markerind-1)+5);
        elseif ~isempty(strfind(name,'hip_center'))
            hip_center.x = data(:,3*(markerind-1)+3);
            hip_center.y = data(:,3*(markerind-1)+4);
            hip_center.z = data(:,3*(markerind-1)+5);
        elseif ~isempty(strfind(name,'hip_top'))
            hip_top.x = data(:,3*(markerind-1)+3);
            hip_top.y = data(:,3*(markerind-1)+4);
            hip_top.z = data(:,3*(markerind-1)+5);
        elseif ~isempty(strfind(name,'hip_bottom'))
            hip_bottom.x = data(:,3*(markerind-1)+3);
            hip_bottom.y = data(:,3*(markerind-1)+4);
            hip_bottom.z = data(:,3*(markerind-1)+5);
        end
    end
    
    trialdata_vicon(trialind).positions.toe = toe;
    trialdata_vicon(trialind).positions.heel = heel;
    trialdata_vicon(trialind).positions.knee = knee;
    trialdata_vicon(trialind).positions.hip_center = hip_center;
    trialdata_vicon(trialind).positions.hip_top = hip_top;
    trialdata_vicon(trialind).positions.hip_bottom = hip_bottom;
    
    toe_updown = toe.(updownaxis);
    goodinds   = find(~isnan(toe_updown));
    toe_updown_interp = interp1(goodinds,toe_updown(goodinds),1:length(toe_updown));
    clear goodinds;
    
    [~,swing_peakbins,swing_peakwidth,p] = findpeaks(toe_updown_interp,'MinPeakProminence',14) ;
    
    %     badinds = find(swing_peakwidth>25);
    %
    %     swing_peakbins(badinds)  = [];
    %     swing_peakwidth(badinds) = [];
    
    figure; hold on;
    plot(toe_updown_interp,'k')
    plot(swing_peakbins,toe_updown_interp(swing_peakbins),'ro')
    
    stepnum = 1;
    for stepind = 1:(length(swing_peakbins)-1)
        
        step_startbin  = swing_peakbins(stepind)+ceil(.5*swing_peakwidth(stepind));
        swing_startbin = swing_peakbins(stepind+1)-ceil(.5*swing_peakwidth(stepind+1));
        swing_endbin   = swing_peakbins(stepind+1)+ceil(.5*swing_peakwidth(stepind+1));
        
        stepbins   = step_startbin:swing_endbin;
        swingbins  = swing_startbin:swing_endbin;
        stancebins = stepbins(1):(swing_startbin-1);
        
        if length(stancebins)/length(swingbins)<15
            
            line([swing_startbin swing_startbin],[0 toe_updown_interp(swing_startbin)],'Color','k')
            line([swing_endbin   swing_endbin],  [0 toe_updown_interp(swing_startbin)],'Color','b')
            
            line([swingbins(1)  swingbins(end)],  [-2 -2],'Color','r')
            line([stancebins(1) stancebins(end)], [-4 -4],'Color','b')
            
            steps(stepnum).stepbins   = stepbins;
            steps(stepnum).swingbins  = swingbins;
            steps(stepnum).stancebins = stancebins;
            
            stepnum = stepnum+1;
        end
    end
    
    trialdata_vicon(trialind).steps = steps;
    trialdata_vicon(trialind).updownaxis = (updownaxis);
end



