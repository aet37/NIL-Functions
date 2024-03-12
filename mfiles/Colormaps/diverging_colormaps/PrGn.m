function [cmap] = PrGn(N)
%PRGn diverging colour scheme that also works in colour-blind vision.
%   Outputs colormap with length specified by N, default length is 256
%   Developed by Paul Tol, more information at https://personal.sron.nl/~pault/data/colourschemes.pdf

if ~exist('N','var') || isempty(N)
    N=256;
end

cmap0=[ 0.4627    0.1647    0.5137
        0.6000    0.4392    0.6706
        0.7608    0.6471    0.8118
        0.9059    0.8314    0.9098
        0.9686    0.9686    0.9686
        0.8510    0.9412    0.8275
        0.6745    0.8275    0.6196
        0.3529    0.6824    0.3804
        0.1059    0.4706    0.2157];

cmap=interp1(linspace(0,1,length(cmap0)),cmap0,linspace(0,1,N),'pchip');

% original hex colors from paper
% clrs = ['#762A83'; '#9970AB'; '#C2A5CF'; '#E7D4E8'; '#F7F7F7';
%         '#D9F0D3'; '#ACD39E'; '#5AAE61'; '#1B7837'];
end