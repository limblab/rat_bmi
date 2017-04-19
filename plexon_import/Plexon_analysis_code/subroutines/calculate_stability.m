function stability = calculate_stability(vicondata,minstepduration_sec,maxstepduration_sec,stepphase_numbins)

            if ~isempty(goodinds)
                
                marker_yinterp = interp1(vicondata.trials(trialind).plexontimes.frames(goodinds),marker_y(goodinds),vicondata.trials(trialind).plexontimes.frames,'nearest');
                
                minstepduration_numbins = ceil(minstepduration_sec/mean(diff(vicondata.trials(trialind).plexontimes.frames))); % IS THIS OK? had to add 'ceil' for one case of A2/518
                if length(vicondata.trials(trialind).plexontimes.frames)>10*minstepduration_numbins
                    [~,allsteps_marker_yi] = findpeaks(marker_yinterp,'MinPeakDistance',minstepduration_numbins,'MinPeakHeight',1.3*mean(marker_y(~isnan(marker_y))));
                    
                    allsteps_duration = diff(vicondata.trials(trialind).plexontimes.frames(allsteps_marker_yi));
                    goodsteps.stepsi = find(allsteps_duration < maxstepduration_sec);
                    numsteps = length(goodsteps.stepsi);
                    
                    if length(goodsteps.stepsi>20)
                        disp('hi')
                        figure; hold on;
                        plot(vicondata.trials(trialind).plexontimes.frames,marker_yinterp,'g')
                        plot(vicondata.trials(trialind).plexontimes.frames,marker_y,'b')
                        plot(vicondata.trials(trialind).plexontimes.frames(allsteps_marker_yi),marker_y(allsteps_marker_yi),'ko')
                        plot(vicondata.trials(trialind).plexontimes.frames(allsteps_marker_yi(goodsteps.stepsi)),marker_y(allsteps_marker_yi(goodsteps.stepsi)),'ro')
                        
                        goodstepsmatrix = zeros(length(goodsteps.stepsi),stepphase_numbins);
                        for stepind = 1:length(goodsteps.stepsi)
                            goodsteps.starttime(stepind) = vicondata.trials(trialind).plexontimes.frames(allsteps_marker_yi(goodsteps.stepsi(stepind)));
                            goodsteps.endtime(stepind)   = vicondata.trials(trialind).plexontimes.frames(allsteps_marker_yi(goodsteps.stepsi(stepind)+1));
                            goodsteps.timebinwidth(stepind) = (goodsteps.endtime(stepind)-goodsteps.starttime(stepind))/stepphase_numbins;
                            stepphase_timebincenters = (goodsteps.starttime(stepind)+.5*goodsteps.timebinwidth(stepind)):goodsteps.timebinwidth(stepind):(goodsteps.endtime(stepind)-.5*goodsteps.timebinwidth(stepind));
                            goodstepsmatrix(stepind,:) = interp1(vicondata.trials(trialind).plexontimes.frames(~isnan(marker_y)),marker_y(~isnan(marker_y)),stepphase_timebincenters);
                        end
                        
                        vicondata.trials(trialind).goodsteps.starttimes   = goodsteps.starttime;
                        vicondata.trials(trialind).goodsteps.endtimes     = goodsteps.endtime;
                        vicondata.trials(trialind).goodsteps.timebinwidth = goodsteps.timebinwidth;
                        
                        vicondata.trials(trialind).goodsteps.mean_step = mean(goodstepsmatrix);
                        vicondata.trials(trialind).goodsteps.std_step = std(goodstepsmatrix)/(length(goodsteps.stepsi)^.5);
                        clear goodsteps*
                    end
                    
                end
            else
                vicondata.trials(trialind).goodsteps = [];
            end
        end
    end
    end


    
    
    vicondata.trials(trialind).goodsteps.starttimes   = goodsteps.starttime;
                        vicondata.trials(trialind).goodsteps.endtimes     = goodsteps.endtime;
                     
                        
                        