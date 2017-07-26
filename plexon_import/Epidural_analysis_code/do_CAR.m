
function CARsignals = do_CAR(epiduralData)

% Common Average Referencing (CAR) is done to reduce common artifact.
% 
% !!! HOWEVER, bear in mind that electrodes with significant artifact should be
% visually rejected prior to common average and omitted from further
% analysis !!!
%
% Especially with this time of CAR, in which:
% 
% sh' = sh - 1/H sum(sq), where sh is the CARed sample of a given channel (h)
% and sq refers to that same time sample of all remaining channels. (It can
% be done w.r.t all remaining channels, or all channels including onself)
%
% This approach presents two problems, as explained in 
% (Using a Common Average Reference to Improve Cortical Neuron Recordings From Microelectrode Arrays, 2009)
%
%  -First, each of the 16 sites would have a unique reference, 
%    instead of a global reference shared by all sites. 
%  -Second, individual sites on a microelectrode array occasionally fail 
%    to function properly. Consequently, these bad sites must be identified 
%    and removed from the dataset before generating a CAR.
% 
% Read the paper cited above for a fancier approach involving referrencing
% only with respect to good channels. The approach to find 'good channels'
% must be implemented.

% CAR type 1 : each channel referenced with respect to all channels (including oneself)
% CAR type 2 : each channel referenced with respect to remaining channels (excluding oneself)


%CAR 1 type
    CommonAverage = mean(epiduralData,1);
    CARsignals.CAR1 = epiduralData - CommonAverage;
    clear CommonAverage;
    
%CAR 2 type
    CommonAverage = mean(epiduralData(2:end,:),1);
    for i = 2: size(epiduralData,1) %Any clever way to avoid this for loop?
        CommonAverage = [ CommonAverage; mean(epiduralData([1:i-1 i+1:end],:),1) ];
    end
    CARsignals.CAR2 = epiduralData - CommonAverage;

end


