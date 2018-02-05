function neuronDecoder = plexon_Build_Model(varargin)
% function neuronDecoder = plexon_Build_Model(varargin)
%
% Builds a neural to EMG decoder from recorded plexon data. If there is no input,
% the function will open a ui for the user to chose a file. If a plexon filename
% is input, the function will load the neural and EMG data from the
% respective file, bin it, and build the model. If it's a .mat file, it
% will try to load a neuronDecoder. 
%
%


% open uiget as needed, error check
if nargin == 0
    [fileName, pathName] = uigetfile({...
        '*.mat','Saved neuronDecoder structure';...
        '*.plx','Plexon Recorded'},...
        'MultiSelect','off');
    fileName = fullfile(pathName,fileName);
elseif nargin > 1
        error('Wrong number of inputs')
end

fileExt = strsplit(fileName,'.');
fileExt = fileExt{end};

if strcmp(fileExt,'plx')
    binParams = struct('NormData',true);
    [emgDataBin,emgData] = load_plexondata_EMG(fileName,binParams);
    chans = [1:16,33:48];
    spikes = {};
    binnedFiring = zeros(size(emgDataBin,1),32);
    for ii = 1:length(chans)
        [~,spikes{ii}] = plx_ts(fileName,chans(ii),0);
        binnedFiring(:,ii) = histcounts(spikes{ii},'BinEdges',[emgDataBin(:,1);emgDataBin(end,1)+.05])*20;
    end
    
    binnedData = struct('emgdatabin',emgDataBin(:,2:end),'spikeratedata',binnedFiring,...
        'neuronIDs',chans','timeframe',emgDataBin(:,1),'emgguide',emgData.channel);
    buildModelParams = struct('UseAllInputs',true,'PredEMGs',true,'plotflag',true);
    neuronDecoder = BuildModel(binnedData,buildModelParams);
    
    
elseif strcmp(fileExt,'mat')
    load(fileName);
    if ~exist('neuronDecoder','var')
        error('A variable named neuronDecoder does not exist in the supplied file')
    end
else
    error('That file name is not valid for this function.')
end
    
    