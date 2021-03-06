function ME = realtime_Wrapper2(fes_params)
% Works mostly the same as realtime_Wrapper, but uses a simple classifier
% to recreate stepping motion instead of a linear decoder
%
% --- realtime_Wrapper(fes_params) ---
%
% A single function that will take care of running all of code necessary
% for real-time stimulation in the rat, using the Plexon map server system
% and the Ripple wireless stimulator. 
%
% This function will take a prebuilt decoder (currently only accepts
% filters using a combination of FilMIMO4 and polyval. Refer to each
% respective function for more information) then apply it to real-time
% recordings from the plexon, then send those to the stimulator. It
% requires an input of StimParams, which can either be a matlab structure
% or a mat file containing the correct structure
%
% Once recording has finished the function will collect all of the relevant
% files into a single .mat file in the directory defined in StimParams
%
%
% -- Inputs -- 
% fes_params        structure or name for file with stimulation params. 
%
% -- Outputs --
% Spits out the error stack if you want it
%
% 
% Authors: Bryan Yoder, Kevin Bodkin



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -- Final goal --
% Wrapper script to import live Plexon data, bin it, decode EMG from
% LFPs and spike timestamps, and stimulate.
%
% Comments: 
%   I've set up the closing function to open all of the binary files and
%   re-store the data and parameters as .mat file. Should we delete the
%   binary files afterwards?
%   
%
% TIPS:
%
%
% TODO:
%   - Start external plexon recording automatically, or synch
%   - stim_elect_mapping_wireless -- write for amplitude modulation
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Load StimParams
% load StimParams, use defaults if not specified
try
    if ~exist('fes_params','var')
        fes_params = struct(); % set up an empty structure to pass in
    end
    
    fes_params = fes_params_defaults(fes_params);
catch ME
    error(ME) % kick us out if necessary
end

%% Set up stim and plexon/Blackrock
% handles for cortical connection and Ripple objects
try
    if strcmp(fes_params.cort_source,'Plexon')
        [wStim,pRead] = setupCommunication(fes_params);
    elseif strcmp(fes_params.cort_source,'Blackrock')
%         [wStim,cbus] = setupCommunication(fes_params);
        error('The cerebus is not yet supported. Sorry bruv');
    end
catch ME
    close_realtime_Wrapper(pRead,wStim)
    rethrow(ME)
end


%% initialize visualization

keepRunning = msgbox('Press ''ok'' to quit'); % handle to end stimulation

if fes_params.display_plots
    stimFig.fh = figure('Name','FES Commands'); % setup visualization of stimulation
    stimFig = stim_fig(stimFig,[],[],fes_params.fes_stim_params,'init'); % using the old stim fig code
end



%% Create folder for saving, create .csv files
dd = datetime; % current date and time
dd.Format = 'dd-MMM-uuuu_HH:mm'; % change how it displays
dirName = [fes_params.save_dir,'\',fes_params.save_name,'_',datestr(dd,30)];
if ~exist(dirName)
    mkdir(dirName);
end

fes_params.save_dir = dirName;

spFile = [dirName '\Spikes.stm'];
tsFile = [dirName, '\TS.stm'];
predFile = [dirName, '\EMG_Preds.stm'];
stimFile = [dirName, '\Stim.stm'];

tsPointer = fopen(tsFile,'w');
spPointer = fopen(spFile,'w');
predPointer = fopen(predFile,'w');
stimPointer = fopen(stimFile,'w');

clear *Header dd dirName
%% start loop

loopCnt = 0; % loop counter for S&G -- might want to do some variety of catch later on.
% trialCnt = 0; % trial number for catch trials for the monkey. 
tStart = tic; % start timer
tLoopOld = toc(tStart); % initial loop timer 
neuronDecoder = fes_params.decoder;
clear model;
% catchTrialInd = randperm(100,fes_params.fes_stim_params.perc_catch_trials); % which trials are going to be catch
binsize = fes_params.binsize; % because I'm lazy and don't feel like always typing this.


drawnow; % take care of anything waiting to be executed, empty thread

stimAmp = zeros(length(fes_params.fes_stim_params.PW_min));
stimPW = zeros(length(fes_params.fes_stim_params.PW_min));

trial_time = tic;

NAVG = 120;
fRates = zeros(NAVG,1);

ME = -1;
profile on;

%params for auto step
state = 'waiting';
%chan = [10 20 22 24 27 31];
chan = setdiff(1:32,14);
NABOVE = 2;
NSWING = 5;
NSTANCE = 20;
flag = 0;

swing_Amp = [1.5,0,0,2,.75,0,0];
stance_Amp = [0,1,0,0,0,.75,.5];

try
while ishandle(keepRunning)
    %fprintf('.\n')
    
    %% wait necessary time for loop
    tLoopNew = toc(tStart);
    tLoop = tLoopNew - tLoopOld;
    
    if ((tLoop+.02) < binsize) && fes_params.display_plots % if we have more than 20 ms extra time, update the stim figure
        stimFig = stim_fig(stimFig,stimPW,stimAmp,fes_params.fes_stim_params,'exec');
        tWaitStart = tic; % Wait loop time
        while (toc(tWaitStart) + tLoop) < binsize
            drawnow;    % empty process
        end
    elseif tLoop < binsize 
        tWaitStart = tic;
        while toc(tWaitStart) < tLoop
            drawnow;    % empty process
        end
    elseif tLoop > binsize
        warning('Slow loop time: %f',tLoop) % throw a warning 
    end
    
    tLoopOld = toc(tStart); % reset timer count
    
    %% collect data from plexon, store in binary
    new_spikes = get_New_PlexData(pRead, fes_params,tsPointer);
    fRates = [sum(new_spikes(chan))/32; fRates(1:end-1,:)];
    
    tempdata = [tLoopOld,new_spikes];
    fwrite(spPointer,tempdata,'double');
    
    
    %% predict from plexon data, store
%     emgPreds = [1 fRates(:)']*neuronDecoder.H;
%     
%     % implement static non-linearity
%     if isfield(neuronDecoder,'P') && numel(neuronDecoder.P) > 1 % do we have non-static linearities
%         nonlinearity = zeros(1,length(emgPreds));
%         for ii = 1:length(emgPreds)
%             nonlinearity(ii) = polyval(neuronDecoder.P(:,ii),emgPreds(ii));
%         end
%         emgPreds = nonlinearity;
%     end
%     
%     % save these into data file
%     tempdata = [tLoopOld,emgPreds];
%     fwrite(predPointer,tempdata,'double');
    
    %% convert predictions to stimulus values, store
%     
%     % if we're going to do catch trials for the monkeys, we're gonna need
%     % to interact with the XPC. This will depend on whether we're using the
%     % same code base for both systems.
%     % -- insert here if needed --
%     
%     % Get the PW and amplitude
%     [stimPW, stimAmp] = EMG_to_stim(emgPreds, fes_params.fes_stim_params); % takes care of all of the mapping
% 
%         
%     if strcmp(fes_params.fes_stim_params.mode,'PW_modulation')
%         tempdata = [toc(tStart),stimPW];
%         fwrite(stimPointer,tempdata,'double');
%     elseif strcmp(fes_params.fes_stim_params.mode,'amplitude_modulation')
%         tempdata = [toc(tStart),stimAmp];
%         fwrite(stimPointer,tempdata,'double');
%     end
%     
    
    %% Convert Spike data to stimulus parameters
    signal = sum(new_spikes(chan))/32; %/length(chan);
    stimAmp = zeros(1,7);
    stimPW = zeros(1,7);
    
    AVG = mean(fRates);
    SD = std(fRates);
    THRESH = AVG + 1*SD;
    
    switch state
        case 'waiting'
            if signal > THRESH
                flag = flag + 1;
            else
                flag = 0;
            end
            
            if flag == NABOVE
                state = 'swing phase';
                count = 0;
            end
            stimAmp = zeros(1,7);
            stimPW = zeros(1,7);
        case 'swing phase'
            count = count + 1;
            if count > NSWING
                state = 'stance phase';
                count = 0;
            end
            stimAmp = stance_Amp;
            stimPW = 0.2*ones(1,7);
        case 'stance phase'
            count = count + 1;
            if count > NSTANCE
                state = 'waiting';
                count = 0;
            end
            stimAmp = swing_Amp;
            stimPW = 0.2*ones(1,7);
    end

    %% send stimulus params to wStim after 1 second of recording
    if loopCnt > 20
        [stimCmd, channelList]    = stim_elect_mapping_wireless( stimPW, ...
                                    stimAmp, fes_params.fes_stim_params );
        for whichCmd = 1:length(stimCmd)
            wStim.set_stim(stimCmd(whichCmd), channelList);
        end
    
    end
    
%% update loop count, 
    loopCnt = loopCnt + 1;
    msg = ['Press ''ok'' to quit' char(10) 'Time: ' int2str(loopCnt*binsize)];
    set(findobj(keepRunning,'Tag','MessageBox'),'String',msg);
    
end

catch ME
    display(ME)
    warning('Could not run stimulation loop, shutting down')
end

close_realtime_Wrapper(pRead,wStim,fes_params,stimFig,stimPointer,predPointer,spPointer,tsPointer);

end


%%
function close_realtime_Wrapper(pRead,wStim,fes_params,stimFig,stimPointer,predPointer,spPointer,tsPointer)

if ishandle(stimFig.fh)
    close(stimFig.fh)
end

if exist('stimPointer','var') & exist('predPointer','var') & exist('spPointer','var')
% get the filenames for the binary files, reopen them for reading, and
% store all of the data into a matlab structure, then save it.

    % get the names for the files, close the files
    [stimFile,~,~,~] = fopen(stimPointer);
    [predFile,~,~,~] = fopen(predPointer);
    [spFile,~,~,~] = fopen(spPointer);
    fclose(stimPointer);
    fclose(predPointer);
    fclose(spPointer);
    
    % all the information about the file size
    spFileInfo = dir(spFile);
    predFileInfo = dir(predFile);
    stimFileInfo = dir(stimFile);
    
    % reopen the files for reading
    stimPointer = fopen(stimFile,'r');
    predPointer = fopen(predFile,'r');
    spPointer = fopen(spFile,'r');
    
    % Organize all of the EMG data
    EMGs = struct('Name',[],'BinLength',[],'Preds',[],'ts',[]);
    EMGs.Name = fes_params.fes_stim_params.muscles;
    EMGs.BinLength = fes_params.decoder.binsize;
    EMGs.Preds = fread(predPointer,predFileInfo.bytes/8,'double');
    EMGs.Preds = reshape(EMGs.Preds,numel(fes_params.fes_stim_params.muscles)+1,predFileInfo.bytes/(8*(numel(fes_params.fes_stim_params.muscles)+1)));
    EMGs.ts = EMGs.Preds(1,:)';
    EMGs.Preds = EMGs.Preds(2:end,:)';
    
    % Organize all the Stim Params
    Stims = struct('Name',[],'Vals',[],'ts',[]);
    Stims.Name = fes_params.fes_stim_params.muscles;
    Stims.Vals = fread(stimPointer,stimFileInfo.bytes/8,'double');
    Stims.Vals = reshape(Stims.Vals,numel(fes_params.fes_stim_params.muscles)+1,stimFileInfo.bytes/(8*(numel(fes_params.fes_stim_params.muscles)+1)));
    Stims.ts = Stims.Vals(1,:)';
    Stims.Vals = Stims.Vals(2:end,:)';
    
    % And finally, spikes
    Spikes = struct('Electrode',[],'fRate',[],'ts',[]);
    Spikes.Electrode = fes_params.neuronIDs;
    Spikes.fRate = fread(spPointer,spFileInfo.bytes/8,'double');
    Spikes.fRate = reshape(Spikes.fRate,size(fes_params.neuronIDs,1)+1,spFileInfo.bytes/(8*(size(fes_params.neuronIDs,1)+1)));
    Spikes.ts = Spikes.fRate(1,:)';
    Spikes.fRate = Spikes.fRate(2:end,:)';
    
    % Save all the info in a file together, and the stimulation params

    storageFN = [fes_params.save_dir, filesep, fes_params.save_name, '_recordedData.mat'];
    paramsFN = [fes_params.save_dir, filesep, fes_params.save_name, '_params'];
    save(storageFN,'Spikes','Stims','EMGs');
    save(paramsFN,'fes_params');

        
    % close all of the files
    % (do we want to delete the binary files?)
    fclose(spPointer); fclose(stimPointer); fclose(predPointer);
    fclose(tsPointer);
    
end
    

%Close connection
PL_Close(pRead);
wStim.delete();
fclose(instrfind);
instrreset % this seems to work better at purging the list of connected serial ports



profile viewer
'Exited Properly'

end