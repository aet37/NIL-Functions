function [r,lags] = xcorr_sub(x,varargin)
% XCORR_SUB it's literally just xcorr with mean-subtraction of inputs
%   Should handle all arguments the same as xcorr. If issues, contact
%   cmr167@pitt.edu

[ySupplied,maxlagInput,scale] = matlab.internal.math.parseXcorrOptions(varargin{:});
if ySupplied
    y = varargin{1}(:);
    if ~isempty(maxlagInput)
        [r,lags]=xcorr(x-mean(x),y-mean(y),maxlagInput,scale);
    else
        [r,lags]=xcorr(x-mean(x),y-mean(y),scale);
    end
else

    if ~isempty(maxlagInput)
        [r,lags]=xcorr(x-mean(x),maxlagInput,scale);
    else
       [r,lags]=xcorr(x-mean(x),scale); 
    end
end

end