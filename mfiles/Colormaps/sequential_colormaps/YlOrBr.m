function [cmap] = YlOrBr(N)
%YlOrBr sequential colour scheme that also works in colour-blind vision.
%   Outputs colormap with length specified by N, default length is 256
%   Developed by Paul Tol, more information at https://personal.sron.nl/~pault/data/colourschemes.pdf

if ~exist('N','var') || isempty(N)
    N=256;
end

cmap0=[ 1.0000    1.0000    0.8980
        1.0000    0.9686    0.7373
        0.9961    0.8902    0.5686
        0.9961    0.7686    0.3098
        0.9843    0.6039    0.1608
        0.9255    0.4392    0.0784
        0.8000    0.2980    0.0078
        0.6000    0.2039    0.0157
        0.4000    0.1451    0.0235];

cmap=interp1(linspace(0,1,length(cmap0)),cmap0,linspace(0,1,N),'pchip');

% original hex colors from paper
% clrs = ['#FFFFE5'; '#FFF7BC'; '#FEE391'; '#FEC44F'; '#FB9A29';
%         '#EC7014'; '#CC4C02'; '#993404'; '#662506'];
end