
% Decoding function for epidural recordings:
function [OLPredData] = epidural_mfxval_decoding (binnedData, DecoderOptions)

    % Set default decoder options
    if ~exist('DecoderOptions')
        warning('No signal specified for prediction.')
    else 
        if ~isfield (DecoderOptions, 'PolynomialOrder')
            DecoderOptions.PolynomialOrder = 2; % 2nd order Wiener cascade
        end
        if ~isfield (DecoderOptions, 'foldlength')
            DecoderOptions.foldlength = 60;     % 2nd order Wiener cascade
        end
        if ~isfield (DecoderOptions, 'fillen')
            DecoderOptions.fillen = 0.5;        % 500 ms of history to decode
        end
        if ~isfield (DecoderOptions, 'UseAllInputs')
            DecoderOptions.UseAllInputs = 1;    % Use all neurons
        end
    end        

    % CREATE VECTOR OF TIMES WHILE BINNING.
    binsize = binnedData.timeframe(2)-binnedData.timeframe(1);
    
    disp(sprintf('Proceeding to multifold cross-validation using %g sec folds...', DecoderOptions.foldlength));
    plotflag = 1;
   
    [mfxval_R2, mfxval_vaf, mfxval_mse, OLPredData] = epidural_mfxval(binnedData, DecoderOptions);
    
    %put the results in the base workspace for easy access
    assignin('base','mfxval_R2',mfxval_R2);
    assignin('base','mfxval_vaf',mfxval_vaf);
    assignin('base','mfxval_mse',mfxval_mse);
    ave_R2 = mean(mfxval_R2);
    assignin('base','ave_R2',ave_R2);

    disp('Done.');
end