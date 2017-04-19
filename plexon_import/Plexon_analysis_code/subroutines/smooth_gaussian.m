function [fsmoothed] = smooth_gaussian(f,width)


fsmoothed = conv(f,gausswin(width,1),'same')/sum(gausswin(width,1));


end

