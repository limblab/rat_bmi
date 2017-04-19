close all;
clear all;
home;

fontsize = 12;

dt_sec = 1/40000;
peakbin = 8;

% directories.database = '/Users/amina/Dropbox/millerlab (1)/data';
% directories.figure = '/Users/amina/Dropbox/millerlab (1)/labmeeting_20160314';

directories.database = 'C:\Users\akinkhab\Dropbox\millerlab (1)\data';
directories.figure = 'C:\Users\akinkhab\Dropbox\millerlab (1)\labmeeting_20160314';

filename = 'A1_20160312_001.plx';

cd(directories.database)
[~,~,~,~,~,waveformsize, PreThresh, SpikePeakV, ~, SlowPeakV, ~, recording_length_sec, datestring] = plx_information(filename);

close all;
peakbin = 8;
for channel = 1%:32
    
    cd(directories.database)
    [numwaveforms, npw, ts, waveforms] = plx_waves(filename, 1, 0);
    shifted_waveforms = NaN(length(waveforms(:,1)),32);
    
    for waveind = 1:numwaveforms
        waveform = waveforms(waveind,:);
        [peaks(waveind),ind] = min((waveform(5:15)));
        peakind(waveind)     = ind+4;
        shift = peakind(waveind) - peakbin;
    
    
    if shift > 0
        shifted_waveforms(waveind,1:(32-abs(shift))) = waveform((shift+1):32);
    elseif shift == 0
        shifted_waveforms(waveind,:) = waveform;
    end
    end
    clear waveform;
    shifted_peaktimes = ts+dt_sec*shift;
    
    figure; set(gcf,'Units','Inches','Position',[5 4 6 2.25],'Renderer','zbuffer');
    set(gcf,'PaperPositionMode','auto','InvertHardcopy','off','PaperSize',[10 10],'Color',[1 1 1]); hold on;
    
    subplot('Position',[.125 .2 0.85 .6]); hold on;
    %     text(.5*recording_length_sec/60,1.1*max(firingrate),['Channel ' num2str(channel)],'HorizontalAlignment','Center','FontSize',fontsize);
    
    plot(shifted_waveforms')
    maxpeak = max(max(abs(shifted_waveforms)));
    axis([0 32 -1*maxpeak maxpeak])
    %     xlabel('Time (minutes)','FontSize',fontsize); ylabel('Firing rate (Hz)','FontSize',fontsize);
    %     set(gca,'FontSize',fontsize)
    %     cd(directories.figure); print(['channel' num2str(channel) '_waveforms'],'-r300','-dtiff','-f1'); close all;
    %
    
    
end
