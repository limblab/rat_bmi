% function plexondata = get_viconframetimes(plexondata,vicondata)

viconsync_trialdur = plexondata.viconsync_trialdur;
viconsync_frames   = plexondata.viconsync_frames;
viconsynctimes     = plexondata.viconsynctimes;

viconsync_trialdur(viconsync_trialdur<=2.5) = 0;
viconsync_trialdur(viconsync_trialdur>2.5) = 1;

viconsync_frames(viconsync_frames<=2.5) = 0;
viconsync_frames(viconsync_frames>2.5)  = 1;

trialstarts_viconsynci = find(diff(viconsync_trialdur)==1)+1;
trialends_viconsynci   = find(diff(viconsync_trialdur)==-1);
numtrials = length(trialstarts_viconsynci);

framestarts_viconsynci = find(diff(viconsync_frames)==1)+1;
frameends_viconsynci   = find(diff(viconsync_frames)==-1);
%      figure;hold on;
%      plot(viconsynctimes,viconsync_trialdur,'k')
%      plot(viconsynctimes,viconsync_frames,'r.')
%      plot(viconsynctimes(trialstarts_viconsynci),viconsync_trialdur(trialstarts_viconsynci),'b+')
%      plot(viconsynctimes(trialends_viconsynci),viconsync_trialdur(trialends_viconsynci),'bo')
%      plot(viconsynctimes(framestarts_viconsynci),viconsync_frames(framestarts_viconsynci),'r+')
%      plot(viconsynctimes(frameends_viconsynci),viconsync_frames(frameends_viconsynci),'ro')

frames_viconsynci = frameends_viconsynci;

%      figure;hold on;
%      plot(viconsynctimes,viconsync_trialdur,'k')
%      plot(viconsynctimes,viconsync_frames,'r.')
%      plot(viconsynctimes(frames_viconsynci),viconsync_trialdur(frames_viconsynci),'b+')

for trialind = 1:numtrials
    
    trial_frames_viconsynci = frames_viconsynci;
    trial_frames_viconsynci(trial_frames_viconsynci>trialends_viconsynci(trialind)) = [];
    trial_frames_viconsynci(trial_frames_viconsynci<trialstarts_viconsynci(trialind)) = [];
    
    trial_times     = viconsynctimes(trialstarts_viconsynci(trialind):trialends_viconsynci(trialind));
    trial_starttime = viconsynctimes(trialstarts_viconsynci(trialind));
    trial_endtime   = viconsynctimes(trialends_viconsynci(trialind));
    trial_duration  = trial_endtime - trial_starttime;
    
    trial_frametimes = viconsynctimes(trial_frames_viconsynci);
    %[trialind length(trial_frametimes) length(vicondata.trials(trialind).frames)]
    %length(vicondata.trials(trialind).toe_updown) length(vicondata.trials(trialind).foot_updown) length(vicondata.trials(trialind).heel_updown)]
    %         figure;hold on;
    %         plot(trial_frametimes,ones(length(trial_frametimes),1),'k.')
    %     plot(trial_frametimes,viconsync_frames)
    
    if length(trial_frametimes) == length(vicondata.trials(trialind).heel_updown)
        
        plexondata.trials(trialind).frametimes  = trial_frametimes;
        plexondata.trials(trialind).times       = trial_times;
        plexondata.trials(trialind).starttime   = trial_starttime;
        plexondata.trials(trialind).endtime     = trial_endtime;
        plexondata.trials(trialind).duration    = trial_duration;
        
    else
        display(['Bad trial: Trial ' num2str(trialind)])
        [length(trial_frametimes)   length(vicondata.trials(trialind).heel_updown)]
        plexondata.trials(trialind).frametimes  = [];
        plexondata.trials(trialind).times       = [];
        plexondata.trials(trialind).starttime   = [];
        plexondata.trials(trialind).endtime     = [];
        plexondata.trials(trialind).duration    = [];
    end
end


