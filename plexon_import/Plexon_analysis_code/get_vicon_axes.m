function [ output_args ] = get_vicon_axes( input_args )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 % function [trialdata_vicon] = load_vicon_data(animal,date,directories,updownaxis)
close all;
updownaxis = 'x';

cd([directories.rawdata 'vicon/' animal '/' date])

viconfiles = dir('*.csv');

for trialind = 1%:length(viconfiles)
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
    
    %     figure; hold on;
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
            hip_center.x = data(:,3*(markerind-1)+3);
            hip_center.y = data(:,3*(markerind-1)+4);
            hip_center.z = data(:,3*(markerind-1)+5);
        elseif ~isempty(strfind(name,'hip_bottom'))
            hip_center.x = data(:,3*(markerind-1)+3);
            hip_center.y = data(:,3*(markerind-1)+4);
            hip_center.z = data(:,3*(markerind-1)+5);
        end
        
        
        
        %         if ~isempty(strfind(name,'treadmill'))
        %
        %             markerind
        %             treadmarker(treadind).x = (data(:,3*(markerind-1)+3));
        %             treadmarker(treadind).y = (data(:,3*(markerind-1)+4));
        %             treadmarker(treadind).z = (data(:,3*(markerind-1)+5));
        %
        %             meanx = mean(treadmarker(treadind).x(~isnan(treadmarker(treadind).x)));
        %             meany = mean(treadmarker(treadind).y(~isnan(treadmarker(treadind).y)));
        %             meanz = mean(treadmarker(treadind).z(~isnan(treadmarker(treadind).z)));
        %
        %             plot3(meanx,meany,meanz,'ko')
        %             treadind = treadind+1;
        %
        %         end
    end
    
    %     figure;
    %     subplot(3,2,1)
    %     plot(toe_x,'.');
    %     subplot(3,2,3)
    %     plot(toe_y,'.');
    %     subplot(3,2,5)
    %     plot(toe_z,'.');
    %     subplot(3,2,2)
    %     plot(diff(toe_x),'.');
    %     subplot(3,2,4)
    %     plot(diff(toe_y),'.');
    %     subplot(3,2,6)
    %     plot(diff(toe_z),'.');
    toe_updown = toe.(updownaxis);
    goodinds   = find(~isnan(toe_updown));
    toe_updown_interp = interp1(goodinds,toe_updown(goodinds),1:length(toe_updown));
    clear goodinds;
    
    %     [steps] = smooth_gaussian(toe_updown_interp,10);
    [~,swing_peakbins,w,p] = findpeaks(toe_updown_interp,'MinPeakProminence',14) ;
    %         [~,stanceswing_peakbins,stancewidth,p] = findpeaks(-1*steps,'MinPeakProminence',14);
    
    figure; hold on;
    plot(toe_updown_interp,'k')
    
    plot(swing_peakbins,toe_updown_interp(swing_peakbins),'ro')
    %     plot(swing_peakbins+10,toe_updown_interp(swing_peakbins+10),'bo')
    %     plot(swing_peakbins-10,toe_updown_interp(swing_peakbins-10),'go')
    %
    %     %     plot(stanceswing_peakbins,toe_y_interp(stanceswing_peakbins),'b+')
    %     %
    %     %     plot(steps,'r')
    %
    %     % stancebins = [];
    %     % for stepind = 1:(length(swing_peakbins)-1)
    %     %
    %     %     currentstancebins = floor(stanceswing_peakbins(stepind)-0.5*stancewidth(stepind)):ceil(stanceswing_peakbins(stepind)+0.5*stancewidth(stepind));
    %     %     if stepind == length(stanceswing_peakbins)
    %     %         badinds = find((currentstancebins-swing_peakbins(stepind))<10);
    %     %     else
    %     %         badinds = unique([find((currentstancebins-swing_peakbins(stepind))<10) find((swing_peakbins(stepind+1)-currentstancebins)<10)]);
    %     %     end
    %     %     currentstancebins(badinds) = [];
    %     %
    %     % stancebins = [stancebins currentstancebins];
    %     %     clear currentstancebins;
    %     % end
    %     %     stancebins(stancebins<=0)=[];
    %     %
    %     % swingbins = setdiff(stancebins(1):stancebins(end),stancebins);
    %     % figure; hold on;
    %     %     plot(steps,'k.-')
    %     %     plot(swingbins,steps(swingbins),'c+')
    %     %     plot(stancebins, steps(stancebins),'r+')
    %     %
    %     % trialdata_vicon(trialind).swingframes = swingbins;
    %     % trialdata_vicon(trialind).stanceframes = stancebins;
    %     trialdata_vicon(trialind).toe_updown_interp =  toe_y_interp;
    trialdata_vicon(trialind).step_startbins = 0;%stanceswing_peakbins;
    %
end


end

