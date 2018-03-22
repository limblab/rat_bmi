function [rawdata, rawdata2, ind, NSD] = remove_field_artifacts(fielddata,varargin)
%

NSD = 5;
DISPLAY = 1;
if nargin == 2
    NSD = varargin{1};
end

rawdata = fielddata';
ndata = length(rawdata);
nchan = size(rawdata,1);


% allsptimes = zeros(ndata,1);
% for ii = 1:nchan
%     allsptimes = allsptimes + rawdata(:,ii);
% end

% N = allsptimes;
% sd = std(N);
% ind = find(N > (NSD*sd));  % the indices into the bins where there are more spikes than expected
% ind2 = setdiff(1:length(fielddata),ind);
rawdata2 = rawdata;
for iii = 1:nchan
    for iter = 1:1
    N = abs(rawdata(iii,:));
    sd = std(N);
    ind = find(N > (NSD*sd));  % the indices into the bins where there are more spikes than expected
    ind2 = setdiff(1:length(fielddata),ind);
    rawdata(iii,ind) = mean(rawdata(iii,ind2));
%     rawdata(ind,iii) = 0;
    end

end
rawdata = rawdata';



