function [plexondata] = create_spikeratedata_matrix(plexondata)

% This function is meant to be executed after the spike info has been
% loaded from a .plx file and binned. The spike info is stored in a struct containing
% channels that have recorded spikes. 

% This function reads the channels and reorganizes the spike info into a 'spikeratedata' matrix  
% for further analisys (decoding etc.).

% !!!!!!!!MODIFY FOR WHEN WE HAVE MORE THAN 1 UNIT IN A CHANNEL

plexondata.spikeratedata = [];

if ~isfield(plexondata, 'channels')
    warning('Field plexondata.channels not found. The struct does not contain any spike info, or it is not stored in the appropriate format.')
else
    % Eliminate empty channels in the plexondata struct:
    plexondata.channels = plexondata.channels(~cellfun(@isempty, {plexondata.channels.clusters}));
    % Organize channel info into a matrix in the field plexondata.spikeratedata
    for i = 1:length(plexondata.channels)
        plexondata.spikeratedata = [plexondata.spikeratedata plexondata.channels(i).clusters.binneddata.spikeratedata];
    end
    % In case you are using the limblab Wiener filter mfxval for decoding:
    plexondata.neuronIDs = [ [1:size(plexondata.spikeratedata,2)]' zeros(size(plexondata.spikeratedata,2) ,1) ];
    
end