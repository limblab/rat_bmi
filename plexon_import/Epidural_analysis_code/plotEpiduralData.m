% close all;

%Delete this once we make this a function and just pass the path variable
% myPath = 'C:\Users\Pablo_Tostado\Desktop\Northwestern_University\MyWorkFolder\Analysis';
% data_dir = [myPath '\rat_bmi\Data_Epidural\E1\17-07-11\'];
rat_name = 'E1_17-07-06';

% Script to plot Epidural Data

% This script is meant to be run after importing the plexon file containing
% Epidural Data (Epidural_WrapScript.)

data_ch = 32:47;   %get indices of channels with Epidural data
%viconScalingFactor = 4.7243; %Factor to divide kinematics

%% Plot Raw Data

rawEpiduralTypes = fieldnames(an_data.rawEpiduralData);
for rawEpiduralLoop = 1:length(rawEpiduralTypes)
    
    data = an_data.rawEpiduralData.(rawEpiduralTypes{rawEpiduralLoop});
    xvals = [1:size(data, 2)]/an_data.freq(1); % Convert samples to seconds
    
    sep_fact = 10;  %This is just the separation between plots in the y-dimension
    data_plot = data + (sep_fact*(1:size(data, 1)))';
    
    figure; plot(xvals, data_plot)

    xlabel('Seconds'); ylabel('Channel'); xlim([0 size(data, 2)/an_data.freq(1)]);
    yticks(([1:length(data_ch)])*sep_fact);
    yticklabels(data_ch); ylim([0 (length(data_ch)+1)*sep_fact]);
    set(gca, 'FontSize', 20); set(gcf, 'color', 'white');
    title (rawEpiduralTypes{rawEpiduralLoop});

end

%% Plot Spectrograms

rawEpiduralTypes = fieldnames(an_data.rawEpiduralData);
for rawEpiduralLoop = 1:length(rawEpiduralTypes)
    
    data = an_data.rawEpiduralData.(rawEpiduralTypes{rawEpiduralLoop});
    figure; suptitle(rawEpiduralTypes{rawEpiduralLoop})
    set(gcf, 'color', 'white');
    
    for i = 1 : (size(data,1)-1)
    sh(i) = subplot(5, 4, i); 
    %S = spectrogram(X,WINDOW,NOVERLAP,NFFT,Fs)
    spectrogram(data(i, :), 10, 0, [], 1000, 'yaxis'); %Windows of 10 samples, 0 overlap, [default NFFT]
    title(['Channel ' num2str(data_ch(i))]); 
    end
    
    sh(17) = subplot(5, 4, 17); 
    plot(an_data.kinematicData.x(:,9))
    title(['Toe X']); set(gca, 'box', 'off');
    xlim([0 length(an_data.kinematicData.x)]);
    
    sh(18) = subplot(5, 4, 18); 
    plot(an_data.kinematicData.y(:,9))
    title(['Toe Y']); set(gca, 'box', 'off');
    xlim([0 length(an_data.kinematicData.y)]);
    
    sh(19) = subplot(5, 4, 19); 
    plot(an_data.kinematicData.z(:,9))
    title(['Toe Z']); set(gca, 'box', 'off');
    xlim([0 length(an_data.kinematicData.z)]);
    
    set(gcf, 'Position', get(0, 'Screensize')); %Maximize figure
    %linkaxes(sh, 'x');
end

%% Plot Power Spectrum

rawEpiduralTypes = fieldnames(an_data.rawEpiduralData);
for rawEpiduralLoop = 1:length(rawEpiduralTypes)
    
    data = an_data.rawEpiduralData.(rawEpiduralTypes{rawEpiduralLoop});
    figure; suptitle(rawEpiduralTypes{rawEpiduralLoop})
    set(gcf, 'color', 'white');
    
    for i = 1 : (size(data,1)-1)
    sh(i) = subplot(4, 4, i); 
    [Pxx, F] = pwelch(data(i, :), [], [], [], 1000);
    loglog(F,Pxx); title(['Channel ' num2str(data_ch(i))]); xlim([0 500])
    end   
    
    linkaxes(sh, 'x');
end

%% Plot behavioral Spectrogram
%Params
data = an_data.rawEpiduralData.rawEpidural;

channel = 2:3;                     % Channel we want to plot
range = [10000 90000];           % Range to plot
numSamples = abs(range(1) - range(2));              % 10 seconds (at 1000Hz)
freqPlx = an_data.freq(1); freqVicon = 200; % Acquisition frequencies
ratio = freqPlx/freqVicon;       % plx freq / vicon freq
marker = 26;                     % Target market: 26 - Toe-y
dimension = 'y';                 % Target dimension (x-longitudinal, y-height z-depth)
normalizFactor = 20;            % Indicate here the maximum freq of the spectrogram, to normalize the kinematics amplitude accordingly
% FFTwindow = length(range(1):range(2)) -1;
FFTwindow = 256;
nFFT = 512;

for i = 1:length(channel)
    %Target kinematics:
    kinem = an_data.rawKinematicData.rawKinematics(:,marker);
    peakKinematics = max(kinem);
    kinem = kinem * (normalizFactor/peakKinematics); %Normalize to make it easy to look at modulations

    figure; 
    %Plot spectrogram
    set(gcf, 'color', 'white'); 
    spectrogram(data(channel(i), range(1):range(2)), FFTwindow, 0, nFFT, freqPlx, 'yaxis'); 
    title(['Channel ' num2str(data_ch(channel(i))) '  ' num2str(FFTwindow) '  ' num2str(nFFT)]); 

    %Plot kinematics on top
    hold on;%figure
    x = linspace(0,numSamples/freqPlx, numSamples/ratio);
    plot(x, kinem(1:numSamples/ratio), 'k', 'LineWidth', 2)
    title(['Channel: ' num2str(channel(i)) ', Toe ' dimension num2str(FFTwindow) num2str(nFFT)]); set(gca, 'box', 'off');
end

%% Save all figures
% Uncomment to save all open figures into a PDF. REALLY SLOW!!
% 
% resultsFolder = [data_dir 'Results\'];
% if exist(resultsFolder, 'dir') ~= 7 %If results folder doesn't exist:
%     mkdir (resultsFolder);
% end
% 
% % Get handles to all figures;
% figHandles = get(groot, 'Children');
% for i = 1:length(figHandles)
%     figureName {i} = [resultsFolder rat_name '_' num2str(i) '.pdf'];
%     saveas(figHandles(i), [resultsFolder rat_name '_' num2str(i)], 'png');
%     saveas(figHandles(i), figureName{i}, 'pdf');
% end
% 
% append_pdfs([resultsFolder rat_name '_resultsSummary.pdf'], figureName {:})
% 
% % Delete pdfs after having appended them:
% for i = 1:length(figureName)
%     delete(figureName {i});
% end

