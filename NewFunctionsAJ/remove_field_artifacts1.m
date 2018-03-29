function [rawdata, rawdata2, actualbinsremoved,artbins, NSD] = remove_field_artifacts1(fielddata,varargin)
%

NSD = 5;
windowsize = 3;
if nargin == 3
    NSD = varargin{1};
    windowsize = varargin{2};
end

rawdata = fielddata';
ndata = length(rawdata);
nchan = size(rawdata,1);


rawdata2 = rawdata;
for iv = 1:nchan
    [rawdata, durationsall,ind,numart, NSD] = remove_field_artifactshere(rawdata,NSD,iv,windowsize);
    durationsallchan(iv,1:size(durationsall,2)) = durationsall;  
    artbins.indices(iv,1:size(ind,2)) = ind;
    artbins.lengthofindices(iv,1) = length(ind);
    artbins.numberofartifacts(iv,1) = numart;
end
actualbinsremoved = durationsallchan;

function [rawdata,durationsall,ind,numart, NSD] = remove_field_artifactshere(rawdata,NSD,channum,w)

for iii = channum
    durations = [];
    N = abs(rawdata(iii,:));
    sd = std(N);
    ind = find(N > (NSD*sd));  % the indices into the bins where there are more spikes than expected
    ind2 = setdiff(1:length(rawdata),ind);
    if isempty(ind)
        durationsall = 0;
        numart = 0;
        break;
    end
    ind(end+1) = ind(end)+100;
%     rawdata(iii,ind) = mean(rawdata(iii,ind2));
%     amp(iii,1:size(ind,2)) =  abs(rawdata2(iii,ind)) - abs(rawdata(iii,ind));
    
    starttime = ind(1);
    for ai = 1:size(ind,2)-1
        if  (ind(ai+1) - ind(ai))>1
           endtime = ind(ai);
        
%            duration = endtime - starttime + 1;
%            durations = horzcat(durations,duration);

           %%% replace the duration + windowsize on either direction by
           %%% mean of the signal without artifacts
           if endtime > size(rawdata,2)-w
               endtime = endtime-w;
           end
           if starttime < w+1
               starttime = starttime+w;
           end
           rawdata(iii,starttime-w:endtime+w) = mean(rawdata(iii,ind2));
           
           duration = endtime - starttime + 1;
           durations = horzcat(durations,duration);
           numart = length(durations);
           starttime = ind(ai+1);
        end
    end
    durationsall = length(ind)+2*w*numart;
end


