function [cmap] = BuRd(N)
%BuRd diverging colour scheme that also works in colour-blind vision.
%   Outputs colormap with length specified by N, default length is 256
%   Developed by Paul Tol, more information at https://personal.sron.nl/~pault/data/colourschemes.pdf

if ~exist('N','var') || isempty(N)
    N=256;
end

cmap0=[ 0.1294    0.4000    0.6745
        0.2627    0.5765    0.7647
        0.5725    0.7725    0.8706
        0.8196    0.8980    0.9412
        0.9686    0.9686    0.9686
        0.9922    0.8588    0.7804
        0.9569    0.6471    0.5098
        0.8392    0.3765    0.3020
        0.6980    0.0941    0.1686];

cmap=interp1(linspace(0,1,length(cmap0)),cmap0,linspace(0,1,N),'pchip');

% original hex colors from paper
% clrs = ['#2166AC'; '#4393C3'; '#92C5DE'; '#D1E5F0'; '#F7F7F7';
%         '#FDDBC7'; '#F4A582'; '#D6604D'; '#B2182B'];
end