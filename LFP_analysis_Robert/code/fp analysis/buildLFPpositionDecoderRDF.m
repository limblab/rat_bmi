function [vaf,H,bestf,bestc]=buildLFPpositionDecoderRDF(varargin)

% syntax [vaf,H,bestf,bestc]=buildLFPpositionDecoderRDF(PathName,skipBadChannelsAssignment,nfeat,featShift);
%
% inputs are optional, but must be supplied in order. i.e., in order to
% input featShift, must also input PathName, skipBadChannelsAssignment and nfeat.
% featShift is ZERO-BASED; i.e., to calculate feature 9, input 1,8 for
% nfeat & featShift.

numlags=10;
wsz=256;
nfeat=150; featShift=0;
PolynomialOrder=0;
smoothfeats=0;
binsize=0.05;
folds=10;
skipBadChannelsAssignment=1;
PathName='';

if nargin >= 1
    wholePath=varargin{1};
    [PathName,FileName,ext]=fileparts(wholePath);
    FileName=[FileName,ext];
end
if nargin >= 2
    skipBadChannelsAssignment=varargin{2};
end
if nargin >= 3
    nfeat=varargin{3};
    featShift=varargin{4};
end

%% Identify the file for loading
% if being called by something else, use the PathName that already exists.
% Assume FileName also exists.
if isempty(PathName)
	[FileName,PathName,~] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.plx file','*.*');	
end
if exist(PathName,'file')~=0
    cd(PathName)
else
    disp('cancelled.')
    vaf=[]; H=[]; bestf=[]; bestc=[];
    return
end
fullfile(PathName,FileName)
if isequal(get(0,'Diary'),'off')
    diary(fullfile(PathName,'decoderOutput.txt'))
end
%% load the file 
%  (skip this cell entirely if you've just loaded in a .mat file instead of
%  the .plx)
switch FileName(end-3:end)
    case '.mat'
        disp(['loading BDF structure from ',FileName])
        load(fullfile(PathName,FileName))
    case '.plx'
        out_struct=get_plexon_data(FileName);
        save([regexp(FileName,'.*(?=\.plx)','match','once'),'.mat'],'out_struct')
end
fnam=FileName(1:end-4);
disp(sprintf('\n\n\n\n\n=====================\nFILE LOADED\n===================='))
%% input parameters - Do not Change, just run.
disp('assigning static variables')

% behavior
signal='vel';
sig=out_struct.(signal);
analog_times=sig(:,1);

% assign FPs, offloaded to script so it can be used in other places.
fpAssignScript2

numfp=size(fp,1);
numsides=1;
Use_Thresh=0; words=[]; emgsamplerate=[]; lambda=1;
disp('done')
bandsToUse=2:7;
powerOrPhase='power';

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CROSS-FOLD TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%
[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y, ...
    featMat,ytnew,xtnew,predtbase,P,featind,sr] = ...
    predictionsfromfp6(sig,signal,numfp,binsize,folds,numlags,numsides, ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,words,emgsamplerate,lambda,smoothfeats,bandsToUse,featShift,powerOrPhase);
close
warning('on','MATLAB:polyfit:RepeatedPointsOrRescale')
warning('on','MATLAB:nearlySingularMatrix')

% examine vaf
fprintf(1,'file %s\n',fnam)
fprintf(1,'decoding %s\n',signal)
fprintf(1,'numlags=%d\n',numlags)
fprintf(1,'wsz=%d\n',wsz)
fprintf(1,'nfeat=%d\n',nfeat)
fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
fprintf(1,'smoothfeats=%d\n',smoothfeats)
fprintf(1,'binsize=%.2f\n',binsize)
fprintf(1,'bands used: '); fprintf('%d',bandsToUse); fprintf(1,'\n');

vaf

formatstr='vaf mean across folds: ';
for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
formatstr=[formatstr, '\n'];

fprintf(1,formatstr,mean(vaf,1))
fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))

diary off