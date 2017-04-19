close all;
% clear all;
% home;
%
% directories.rawdata = '/Volumes/fsmresfiles/data/rats/AK/vicon/';
% directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
% directories.database = '/Users/amina/Dropbox/motorcortex_database/';
%
% cd(directories.rawdata)
%
% cd 'A3/20160421/'
%
% filename = '2016042101.csv';
%
%
%
% fid = fopen(filename);
% filestring = textscan(fid,'%s', 'Delimiter',',','EmptyValue',NaN);
% filestrings = filestring{1};
% fclose all;
%
% fid = fopen(filename);
% data = dlmread(filename,',',5,0);
% data(data == 0) = NaN;
% fclose all;
%
% nummarkers = (length(data(1,:))-2)/3;
%
% % z = up and down (vicon x)
% % x = forward and back (vicon y)
% % y = side to side in treadmill (vicon z)

for markerind = 1:nummarkers
    name = filestrings{3*(markerind-1)+5}
    
    if ~isempty(strfind(name,'toe'))
        markerind
        toe_z = data(:,3*(markerind-1)+5);
    end
end
figure; plot(toe_z,'.')

% goodinds   = find(~isnan(toe_z));
% toe_z_interp = interp1(goodinds,toe_z(goodinds),1:length(toe_z));
% clear goodinds;
% [steps] = smooth_gaussian(toe_z_interp,10);
% [pks,peakbins,w,p] = findpeaks(steps,'MinPeakProminence',14) ;
% [pks,stancepeakbins,stancewidth,p] = findpeaks(-1*steps,'MinPeakProminence',14) ;
% 
% figure; hold on;
% plot(toe_z_interp,'k')
% plot(steps,'r')
% 
% stancebins = [];
% for stepind = 1:length(stancepeakbins)
%     
%     currentstancebins = floor(stancepeakbins(stepind)-0.5*stancewidth(stepind)):ceil(stancepeakbins(stepind)+0.5*stancewidth(stepind));
%     if stepind == length(stancepeakbins)
%         badinds = find((currentstancebins-peakbins(stepind))<10);
%     else
%         badinds = unique([find((currentstancebins-peakbins(stepind))<10) find((peakbins(stepind+1)-currentstancebins)<10)]);
%     end
%     
%     currentstancebins(badinds) = [];
%     stancebins = [stancebins currentstancebins];
%     clear currentstancebins;    
% end
%     
%     %badinds = find(abs(diff(steps(stancebins)))>1);
% %     stancebins(badinds) = [];
%     stancebins(stancebins<=0)=[];
%     figure;
%     plot(diff(stancebins),'.')
%     
%     
%     d2step = abs(diff(diff(steps)));
%     figure; hold on;
%     plot(steps,'k.-')
%     plot(peakbins,steps(peakbins),'c+')
%     plot(stancebins, steps(stancebins),'r+')
%   
%     