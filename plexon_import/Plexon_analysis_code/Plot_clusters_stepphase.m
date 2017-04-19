close all;
% home;
% clear all;

% directories.rawdata = '/Volumes/L_MillerLab/data/rats/AK/';
% directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
% directories.database = '/Users/amina/Dropbox/motorcortex_database/';
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% experiments(1).animal = 'A1';
% experiments(1).date = '20160312';
% experiments(1).clusters(1).channel        = 2;
% experiments(1).clusters(1).channelcluster = 1;
%
% experiments(2).animal = 'A2';
% experiments(2).date = '20160408';
% experiments(2).clusters(1).channel        = 22;
% experiments(2).clusters(1).channelcluster = 1;
% experiments(2).clusters(2).channel        = 22;
% experiments(2).clusters(2).channelcluster = 2;
%
% % Empirical, choose x here
% experiments(3).animal = 'A2';
% experiments(3).date = '20160419';
% experiments(3).clusters(1).channel        = 1;
% experiments(3).clusters(1).channelcluster = 1;
% experiments(3).clusters(2).channel        = 7;
% experiments(3).clusters(2).channelcluster = 1;
%
% experiments(4).animal = 'A3';
% experiments(4).date = '20160414';
% experiments(4).clusters(1).channel        = 2;
% experiments(4).clusters(1).channelcluster = 1;
% experiments(4).clusters(2).channel        = 2;
% experiments(4).clusters(2).channelcluster = 2;
% experiments(4).clusters(3).channel        = 2;
% experiments(4).clusters(3).channelcluster = 3;
% experiments(4).clusters(4).channel        = 2;
% experiments(4).clusters(4).channelcluster = 4;
% experiments(4).clusters(5).channel        = 7;
% experiments(4).clusters(5).channelcluster = 1;
%
% % choose x here
% experiments(5).animal = 'A3';
% experiments(5).date = '20160419';
% experiments(5).clusters(1).channel        = 2;
% experiments(5).clusters(1).channelcluster = 1;
% experiments(5).clusters(2).channel        = 2;
% experiments(5).clusters(2).channelcluster = 2;
% experiments(5).clusters(3).channel        = 2;
% experiments(5).clusters(3).channelcluster = 3;
% experiments(5).clusters(4).channel        = 2;
% experiments(5).clusters(4).channelcluster = 4;
% experiments(5).clusters(5).channel        = 3;
% experiments(5).clusters(5).channelcluster = 1;
% experiments(5).clusters(6).channel        = 7;
% experiments(5).clusters(6).channelcluster = 1;
% experiments(5).clusters(7).channel        = 7;
% experiments(5).clusters(7).channelcluster = 2;
% experiments(5).clusters(8).channel        = 12;
% experiments(5).clusters(8).channelcluster = 1;
%
% % vicon reasonable, mostly up/down = y, front/back = x;
% experiments(6).animal = 'A3';
% experiments(6).date = '20160421';
% experiments(6).clusters(1).channel        = 2;
% experiments(6).clusters(1).channelcluster = 1;
% experiments(6).clusters(2).channel        = 2;
% experiments(6).clusters(2).channelcluster = 2;
% experiments(6).clusters(3).channel        = 7;
% experiments(6).clusters(3).channelcluster = 1;
% experiments(6).clusters(4).channel        = 7;
% experiments(6).clusters(4).channelcluster = 2;
% experiments(6).clusters(5).channel        = 12;
% experiments(6).clusters(5).channelcluster = 1;
%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updownaxis = {'';'';'x';'';'x';'y'};

for expind = 5%[3 5 6]
    animal = experiments(expind).animal;
    date = experiments(expind).date;

    [experiments(expind).trialdata_vicon]    = load_vicon_data(animal,date,directories,updownaxis{expind});
    [~,experiments(expind).trialdata_plexon] = load_plexon_data(animal,date,directories);

    % get only clusters of interest (load_plexon_data loads all of the clusters, just repeating that code here)

    cd([directories.rawdata '/plexon'])
    filename = [animal '_' date '_clusters.plx'];

    [~,~,frequency,~,~,~,~,~,~,~,~,recording_length_sec,~] = plx_information(filename);
    frate_timebinwidth = .05;
    frate_timebinedges   = 0:frate_timebinwidth:recording_length_sec;
    frate_timecenters = 0.5*frate_timebinwidth+frate_timebinedges(1:end-1);

for clusterind = 1:length(experiments(expind).clusters);%1:
    
    
    cd([directories.rawdata '/plexon'])
    [n, spiketimes]    = plx_ts(filename, experiments(expind).clusters(clusterind).channel, experiments(expind).clusters(clusterind).channelcluster);
    firingrate         = histc(spiketimes,frate_timebinedges); firingrate(end) = [];
    smoothedfiringrate = smooth_gaussian(firingrate,5);
    
    for trialind = length(experiments(expind).trialdata_vicon)% 1:
        
        frametimes = experiments(expind).trialdata_plexon(trialind).frametimes;
        steps      = experiments(expind).trialdata_vicon(trialind).steps;
        
        all_stance_spikesi = [];
        all_swing_spikesi  = [];
        
        stepphasematrix = zeros(length(steps),10);
        
        
        for stepind = 1:length(experiments(expind).trialdata_vicon(trialind).steps)
            
            step_timerange = [frametimes(steps(stepind).stancebins(1)) frametimes(steps(stepind).swingbins(end))];
            
            stepphase_timebinwidth = diff(step_timerange)/10;
            stepphase_timebinedges   = step_timerange(1):stepphase_timebinwidth:step_timerange(2);
            phasehist = histc(spiketimes,stepphase_timebinedges); phasehist(end) = [];
            stepphasematrix(stepind,:) = phasehist;
            stance_timerange = [frametimes(steps(stepind).stancebins(1)) frametimes(steps(stepind).stancebins(end))];
            swing_timerange  = [frametimes(steps(stepind).swingbins(1)) frametimes(steps(stepind).swingbins(end))];
            steps(stepind).stance_spikesi = find(spiketimes>=stance_timerange(1) & spiketimes<=stance_timerange(2));
            steps(stepind).swing_spikesi  = find(spiketimes>=swing_timerange(1) & spiketimes<=swing_timerange(2));
            
            all_stance_spikesi = [all_stance_spikesi steps(stepind).stance_spikesi'];
            all_swing_spikesi  = [all_swing_spikesi  steps(stepind).swing_spikesi'];
            
        end
        figure;
        subplot(2,2,1)
        imagesc(stepphasematrix)
        subplot(2,2,3)
        plot(sum(stepphasematrix))
        
        toey = experiments(expind).trialdata_vicon(trialind).positions.toe.y;
        toey = toey-min(toey);
        toey = toey/max(toey);
        subplot(2,2,2)
        plot(frate_timecenters,smoothedfiringrate,'k');
        hold on;
        plot(frametimes,toey,'r')
        
        frateforcorr = interp1(frate_timecenters, smoothedfiringrate, frametimes);
        subplot(2,2,4)
        crosscorr(toey,frateforcorr)
        
    end
end
 end













