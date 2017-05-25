function rowVector=rowBoat(inputVector)

% syntax rowVector=rowBoat(inputVector);
%
% makes inputVector into a row vector regardless
% of what its dimensionality was before.  
% Intended for use with 1D vectors.

if size(inputVector,2)>size(inputVector,1)
    rowVector=inputVector';
else
    rowVector=inputVector;
end