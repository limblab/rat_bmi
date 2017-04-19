function vicondata = get_vicondata_from_plexondata(plexondata,vicondata)

viconsync_trialdur = plexondata.viconsync.trialdur;
viconsync_frames   = plexondata.viconsync.frames;

viconsync_trialdur(viconsync_trialdur<=2.5) = 0;
viconsync_trialdur(viconsync_trialdur>2.5) = 1;

viconsync_frames(viconsync_frames<=2.5) = 0;
viconsync_frames(viconsync_frames>2.5)  = 1;

trialstarts_viconsynci = find(diff(viconsync_trialdur)==1)+1;
trialends_viconsynci   = find(diff(viconsync_trialdur)==-1);

framestarts_viconsynci = find(diff(viconsync_frames)==1)+1;
frameends_viconsynci   = find(diff(viconsync_frames)==-1);

if framestarts_viconsynci(1)>frameends_viconsynci(1)
    frameends_viconsynci(1) = [];
end
if framestarts_viconsynci(end)>frameends_viconsynci(end)
    framestarts_viconsynci(end) = [];
end
% for plexon_trialind = 1:length(trialstarts_viconsynci)
%         trialframes_viconsynci = frameends_viconsynci(find(frameends_viconsynci<=trialends_viconsynci(plexon_trialind) & frameends_viconsynci>=trialstarts_viconsynci(plexon_trialind)));
%         [plexon_trialind length(trialframes_viconsynci)]
% end
vicontriallengths =[];
for vicon_trialind = 1:length(vicondata.trials)
    [vicon_trialind length(vicondata.trials(vicon_trialind).frames)]
    vicontriallengths =[vicontriallengths length(vicondata.trials(vicon_trialind).frames)];
end
if length(unique(vicontriallengths))<length(vicondata.trials)
    for trialind = 1:length(trialstarts_viconsynci)
        trialframes_viconsynci = frameends_viconsynci(find(frameends_viconsynci<=trialends_viconsynci(trialind) & frameends_viconsynci>=trialstarts_viconsynci(trialind)));
        %         [vicon_trialind plexon_trialind length(trialframes_viconsynci) length(vicondata.trials(vicon_trialind).frames)]
        vicondata.trials(trialind).plexontimes.trialstart = plexondata.viconsync.plexon_times(trialstarts_viconsynci(trialind));
        vicondata.trials(trialind).plexontimes.trialend = plexondata.viconsync.plexon_times(trialends_viconsynci(trialind));
        vicondata.trials(trialind).plexontimes.frames = plexondata.viconsync.plexon_times(trialframes_viconsynci);
    end
else
    for vicon_trialind = 1:length(vicondata.trials)
        for plexon_trialind = 1:length(trialstarts_viconsynci)
            trialframes_viconsynci = frameends_viconsynci(find(frameends_viconsynci<=trialends_viconsynci(plexon_trialind) & frameends_viconsynci>=trialstarts_viconsynci(plexon_trialind)));
            %         [vicon_trialind plexon_trialind length(trialframes_viconsynci) length(vicondata.trials(vicon_trialind).frames)]
            if length(trialframes_viconsynci) == length(vicondata.trials(vicon_trialind).frames)
                vicondata.trials(vicon_trialind).plexontimes.trialstart = plexondata.viconsync.plexon_times(trialstarts_viconsynci(plexon_trialind));
                vicondata.trials(vicon_trialind).plexontimes.trialend = plexondata.viconsync.plexon_times(trialends_viconsynci(plexon_trialind));
                vicondata.trials(vicon_trialind).plexontimes.frames = plexondata.viconsync.plexon_times(trialframes_viconsynci);
            end
        end
    end
end