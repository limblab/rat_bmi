function [neuronDecoder,predData] = plexon_Build_Model(varargin)
% function neuronDecoder = plexon_Build_Model({filename},{params})
%
% Builds a neural to EMG decoder from recorded plexon data. If no file name
% is input, the function opens a user interface. Also allows the user to
% input a structure with parameters. Otherwise, it bins and builds the
% function according to default parameters.
%   
% -- Optional Inputs --
% filename          : Character array with filename
% params            : Struct with parameters inside
%       binSize     : Binsize in seconds    [.05]
%       filLen      : Filter length in seconds   [.5]
%       filtType    : Allows the function to build different types of
%                          filters, to be implemented [Wiener]
%       polynomial  : Add a static nonlinearity to the Wiener filter? [0]
%       chans       : Channel names



% open uiget as needed, error check
params = struct('binSize',.05,'filLen',.5,'polynomial',0,'chans',[([1:16 33:48])',zeros(32,1)]);
for ii = 1:nargin
    switch class(varargin{ii})
        case 'char'
            fileName = varargin{ii};
        case 'struct'
            flds = fieldnames(varargin{ii});
            for jj = 1:length(flds)
                params.(flds{jj}) = varargin{ii}.(flds{jj}); % load in any and all parameters
            end
        otherwise
            error('%s is not a valid parameter. Read the help and try again',varargin{ii})
    end
end

if ~exist('fileName','var') % load a file if one wasn't given
    [fileName, pathName] = uigetfile({...
        '*.plx','Plexon Recorded';...
        '*.mat','Saved neuronDecoder structure'},...
        'MultiSelect','off');
    fileName = fullfile(pathName,fileName);
end

fileExt = strsplit(fileName,'.');
fileExt = fileExt{end};



if strcmp(fileExt,'plx')
    binParams = struct('NormData',true,'binsize',params.binSize);
    [emgDataBin,emgData,binTimestamps] = load_plexondata_EMG(fileName,binParams);
    spikes = {};
    binnedFiring = zeros(size(emgDataBin,1),32);
    for ii = 1:size(params.chans,1)
        [~,spikes{ii}] = plx_ts(fileName,params.chans(ii,1),params.chans(ii,2));
        binnedFiring(:,ii) = histcounts(spikes{ii},'BinEdges',[binTimestamps(:);binTimestamps(end)+params.binSize])/params.binSize;
    end
    
    binnedData = struct('emgdatabin',emgDataBin,'spikeratedata',binnedFiring,...
        'neuronIDs',params.chans,'timeframe',binTimestamps,'emgguide',emgData.channel);
    buildModelParams = struct('UseAllInputs',true,'PredEMGs',true,'plotflag',...
        true,'fillen',params.filLen,'PolynomialOrder',params.polynomial);
    
    [neuronDecoder,predData] = BuildModel(binnedData,buildModelParams);
    neuronDecoder.fileName = fileName; % remember, this is for posterity's sake.
    
    
elseif strcmp(fileExt,'mat')
    load(fileName);
    if ~exist('neuronDecoder','var')
        error('A variable named neuronDecoder does not exist in the supplied file')
    end
else
    error('That file name is not valid for this function.')
end


end