
function processedEpiduralData = do_SpatialFiltering(LFP_struct, params)

%% Variables

%Make defaults in case not specified by user
binSize = params.binSize;
LFPwindowSize = params.LFPwindowSize;   % Size of the window used to bin the data. Trade off between freq resolution & window overlapping
FFTwindowSize = params.FFTwindowSize;
nFFT = params.nFFT;            % Size of the FFT window (make it power of 2 for faster processing). A window larger than the window of data (LFPwindowSize) will result in zero-padding the data.
freqBands = params.freqBands;

sampleFreq = LFP_struct.freq(1);     % Plexon sampling frew
SampsPerBin = binSize*sampleFreq;    % This assumes binsize is in seconds.
numChannels = size(LFP_struct.rawEpiduralData.rawEpidural,1);
numLFPSamples = size(LFP_struct.rawEpiduralData.rawEpidural,2);
numBands = size(freqBands,1);

% LFP_struct.timestamps contains the time at which each channel recorded the
% first sample. If they all started at the same time, we can create a
% common vector of time stamps: 
if range(LFP_struct.timestamps) == 0
    LFPtimes = LFP_struct.timestamps(1) : 1/sampleFreq : numLFPSamples/sampleFreq + LFP_struct.timestamps(1);
else 
    disp('Not every channel  has the same starting timestamp. Consider looking into the data and aligning it.');
end

% Do I need this for anything?
binSampRate = floor(1/binSize);   %sample rate due to binning (for MIMO input)

%% Actual signal binning and processing:

% We need to readjust #bins because we are going to be sliding the 
% window over the length of the file, so if the window is bigger than
% the binsize we will surpass the end of the file. Or if the #of samples is
% not a multiple of Samples Per Bin. 

numBins = floor( ((length(LFPtimes)-LFPwindowSize) / SampsPerBin + 1) );

%This is the important part of the processing.
%{
% In the following code, we are calculating the Power Spectral Density
% (PSD) pf the LFP signals in windows of a target size. For instance, a
% window of 256 points at 1000Hz will allow us to look at frequencies
% between 4Hz - 500Hz. (The sample freq determines the upper freq
% resolution - Nyquist, the window size determines the lowest freq
% resolution, for windows of 1000 samples at 1000Hz it'd be 1s)
%}

% Remember our window size determines the lowest freq we can capture as
% follows:
lowestFreq = 1 / (LFPwindowSize/sampleFreq);
fprintf(1,'The lowest freq being captured with this window is %.3f Hz\n',lowestFreq)

%Run the analysis process for all the RawEpiduralData, with & without CAR:
rawEpiduralTypes = fieldnames(LFP_struct.rawEpiduralData);
for rawEpiduralLoop = 1:length(rawEpiduralTypes) 
        
    LFPs = LFP_struct.rawEpiduralData.(rawEpiduralTypes{rawEpiduralLoop});
    LFPs_bands = [];
    
    [b,a] = butter(2,[58 62]/(sampleFreq/2),'stop'); % Notch filter for 60 Hz noise
    LFPs = filtfilt(b,a,double(LFPs)')';  %LFPs is channels X samples    
    
    for i = 1:numBins

        %Take chunks of 'LFPwindowSize' samples from all channels, sliding the
        %window in 'SampsPerBin' samples steps. 
        tmp = LFPs(:,(SampsPerBin*(i-1)+1 : (SampsPerBin*(i-1)+LFPwindowSize)))';    

        % PWELCH HELP
        %{
        % Read PWELCH help:   [Pxx,F] = pwelch(X,WINDOW,NOVERLAP,NFFT,Fs)
        %
        % By default, PWELCH divides signal into longest possible sections to
        % get 8 segments of 50% overlapping, compute a different periodogram
        % per segment, and average all of them to compute the final spectral
        % density.
        %
        % X = signal: channels need to be columns. FFT is computed on columns.
        % WINDOW = divide signal into sections of length WINDOW. !! This is after
        %   our manual division, so if you specify a shorter window it will
        %   further limit the low freq resolution.
        % NOVERLAP = If you want to overlap sections of data. Default is
        %   Overlap 50%.
        % NFFT = number of FFT points used to calculate the PSD estimate.
        %   (Default 256). If longer than segment, data is zero-padded
        % Fs = Sampling frequency of the input signal

        % !! Default WINDOW will break signal in 8 longest possible segmentes with
        % 50% overlap. So the length of the segments will be: fix(length(SIGNAL)/4.5)
        % If you want the PSD over the whole segment at once, without average,
        % set WINDOW to be the length of your signal. 
        %}        
        
        %nFFT larger than window will zero-pad the signal. FFT is
        %calculated a lot faster if nFFT is a power of 2. Larger nFFT will
        %increase DFT density (freq resolution)
        [Pxx,F] = pwelch(tmp, FFTwindowSize, [], nFFT, sampleFreq);

        %Take target freq bands and calculate average power for each of them:
        for iBand = 1:size(freqBands,1)
            band(:,iBand) = (F >= freqBands(iBand,1)) & (F < freqBands(iBand,2)); %BAND is constant. Can be for sure taken out of the loop and make this a 1 step loop.
            tmpLFPs_bands(iBand,:) = mean( Pxx(band(:,iBand),:), 1);
        end
%         
%         interestBand = (F>=20) & (F<80);

%         delta = F < 4;
%         mu = (F>=4) & (F<20);
%         alphabeta = (F>=20) & (F<70);
%         gam1 = (F>70) & (F<115);
%         gam2 = (F>130) & (F<200);
%         gam3 = (F>200) & (F<300);
%          tmpLFPs_bands(1,:) = mean( Pxx(interestBand,:), 1);
%         tmpLFPs_bands(1,:) = mean( Pxx(delta,:), 1);
%         tmpLFPs_bands(2,:) = mean( Pxx(mu,:), 1);
%         tmpLFPs_bands(3,:) = mean( Pxx(alphabeta,:), 1);
%         tmpLFPs_bands(4,:) = mean( Pxx(gam1,:), 1);
%         tmpLFPs_bands(5,:) = mean( Pxx(gam2,:), 1);
%         tmpLFPs_bands(6,:) = mean( Pxx(gam3,:), 1);    

        % LMP(:,i) = mean(fpf(:,bs*(i-1)+1:bs*i),2); 
        % LMP(:,i) = mean(tmp',2); 
        % CHECK THIS, it is Local Motor Potential. Use as an extra
        % parameter?   

        %Reshape obtained power bands into a single column that will correspond
        %to the current bin.
        tmpLFPs_bands = reshape(tmpLFPs_bands, [ numChannels*numBands, 1 ]);   

        LFPs_bands = [LFPs_bands tmpLFPs_bands];
        clear tmpLFPs_bands;
    end

processedEpiduralData.(rawEpiduralTypes{rawEpiduralLoop}) = LFPs_bands;

end
end

%% Original Rob's code did the FFT processing manually:
% 
% % % Rob's code calculated the power spectrum doing the FFT manually
% % % following the next steps:
% 
% %Hann window  function of the width of our FFT window (256)
% %"Hann funct is used as a window function in digital signal processing to
% %select a subset of a series of samples in order to perform a Fourier
% %transform". It is meant to yield very low aliasing in exchange of resolution,
% %since it takes care of sharp edges in the target window.
% 
% HannWin = repmat(hanning(windSize),1,numChannels); 
% 
% % This is the important part of the processing.
% % In the following code, we are applying a FFT to chunks of (WindSize x Channels) 
% %(256 x 96) of data, separated by the bin length (50ms). So the result will
% % be a 3 dimensional matrix (WindSize x Channels x #bins) (256 x 96 x #bins)
% 
% fftLFPs = zeros(windSize,numChannels,numBins);
% for i = 1:numBins
%     
%     tmp = LFPs(:,(SampsPerBin*(i-1)+1 : (SampsPerBin*(i-1)+windSize)))';    %Take chunks of 256 samples from all channels
%     
%     %     LMP(:,i)=mean(fpf(:,bs*(i-1)+1:bs*i),2); CHECK THIS, is Local
%     %     Motor Potential the same as CAR? Read paper
%     LMP(:,i) = mean(tmp',2);    
%    
%     % tmp=detrend(tmp); %Remove a linear trend from a vector, usually for FFT processing.
%     tmp = HannWin.*tmp;
%     
%     %fft ([96x256], 256) is a 256-points Descrete FT applied on columns of matrix.
%     fftLFPs(:,:,i) = fft(tmp,windSize);       
%       
% end
% % (windSize/2 = 128)target frequencies taken in between 0 - (sampleFreq/2) 
% freqs = linspace(0,sampleFreq/2,windSize/2+1);
% freqs = freqs(2:end); %remove DC freq(c/w timefreq.m)
% fprintf(1,'first frequency bin at %.3f Hz\n',freqs(1))
% assignin('base','freqs',freqs)
% 
% % Calculate bandpower: ASK ROB about this part.
% % We are taking a conjugate of only 125 samples etc. What is this way to
% % compute power? Why not POWELCH?
% powerLFPs = fftLFPs(2:length(freqs)+1,:,:).*conj(fftLFPs(2:length(freqs)+1,:,:))*0.75;   %0.75 factor comes from newtimef (correction for hanning window)
% assignin('base','powerLFPs',powerLFPs)
%  
% %Again, WHAT IS PA?
% meanPowerLFPs = mean(powerLFPs,3); %take mean over all times
% 
% %Why do we substract mean power of all bins to each bin??
% PA = 10.*(log10(powerLFPs) - repmat(log10(meanPowerLFPs),[1,1,numBins]));
% assignin('base','PA',PA)
% clear Pmat
% 
% %Define freq bands
% delta = freqs<4;
% mu = ((freqs>7) & (freqs<20));
% alphabeta=(freqs>=20) & (freqs<70);
% gam1 = (freqs>70)&(freqs<115);
% gam2 = (freqs>130)&(freqs<200);
% gam3 = (freqs>200)&(freqs<300);
% 
% tmpLFPs_bands(1,:,:) = LMP;
% tmpLFPs_bands(2,:,:) = mean(PA(delta,:,:),1);
% tmpLFPs_bands(3,:,:) = mean(PA(mu,:,:),1);
% % % PB(4,:,:)=mean(PA(alphabeta,:,:),1);
% tmpLFPs_bands(4,:,:) = mean(PA(gam1,:,:),1);
% tmpLFPs_bands(5,:,:) = mean(PA(gam2,:,:),1);
% if sampleFreq>600
% tmpLFPs_bands(6,:,:) = mean(PA(gam3,:,:),1);
% end
% tmpLFPs_bands(7,:,:) = mean(PA(freqs>30 & freqs<50,:,:),1);
% 
% % isolate powerbands for individual-band analysis.  Most times this will
% % remain commented.
% % PB([2:6],:,:)=[];
% 
% % % temporary - to test a hypothesis 01/06
% % PB=[];
% % PB(1,:,:)=mean(PA(gam1,:,:),1);
% % PB(2,:,:)=mean(PA(gam2,:,:),1);
% % PB(3,:,:)=mean(PA(gam3,:,:),1);
% % % test a combined gamma band alone.
% % PB=[];
% % PB(1,:,:)=mean(PA(gam1 | gam2 | gam3,:,:),1);
% % assignin('base','PB',PB)
% 
% phaseMat = fftLFPs(2:length(freqs)+1,:,:);
% 
% PBphase(1,:,:) = LMP;
% PBphase(2,:,:) = angle(mean(phaseMat(delta,:,:),1));
% PBphase(3,:,:) = angle(mean(phaseMat(mu,:,:),1));
% PBphase(4,:,:) = angle(mean(phaseMat(gam1,:,:),1));
% PBphase(5,:,:) = angle(mean(phaseMat(gam2,:,:),1));
% if sampleFreq > 600
%     PBphase(6,:,:) = angle(mean(phaseMat(gam3,:,:),1));
% end
% PBphase(7,:,:) = angle(mean(phaseMat(freqs>30 & freqs<50,:,:),1));
% % % to use unwrapped phase:
% % [b,a]=butter(2,0.1/(bs/2),'high');
% % PBphase=double(PBphase);
% % for n=2:size(PBphase,1)
% %     for k=1:size(PBphase,2)
% %         PBphase(n,k,:)=filtfilt(b,a,unwrap(PBphase(n,k,:)));
% %     end, clear k
% % end, clear n b a
% 
% % if isequal(powerOrPhase,'phase')
% %     PB = PBphase;
% % end
% if exist('bandToUse','var')==1 && all(isfinite(bandToUse)) && all(bandToUse <= size(tmpLFPs_bands,1))
%     tmpLFPs_bands = tmpLFPs_bands(bandToUse,:,:);
% end
% 
