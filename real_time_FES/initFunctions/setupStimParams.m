function StimParams = setupStimParams(StimParams)
%% StimParams = setupStimParams([StimParams])
%
% checks the stimulation paramater structure to make sure that everything's
% in the clear for online FES, and fills in paramaters as necessary. If no
% input structure is provided, the output will be entirely the default 
% settings. This is a semi-blatant ripoff of the previous StimParams 
% structure, with a few changes to keep up with the times.
%
% --- StimParams ---
% 