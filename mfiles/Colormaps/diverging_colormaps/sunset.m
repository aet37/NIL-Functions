function [cmap] = sunset(N)
%SUNSET diverging colour scheme that also works in colour-blind vision.
%   Outputs colormap with length specified by N, default length is 256
%   Developed by Paul Tol, more information at https://personal.sron.nl/~pault/data/colourschemes.pdf

if ~exist('N','var') || isempty(N)
    N=256;
end

cmap0=[0.2118    0.2941    0.6039
        0.2902    0.4824    0.7176
        0.4314    0.6510    0.8039
        0.5961    0.7922    0.8824
        0.7608    0.8941    0.9373
        0.9176    0.9255    0.8000
        0.9961    0.8549    0.5451
        0.9922    0.7020    0.4000
        0.9647    0.4941    0.2941
        0.8667    0.2392    0.1765
        0.6471         0    0.1490];

cmap=interp1(linspace(0,1,length(cmap0)),cmap0,linspace(0,1,N),'pchip');

% original hex colors from paper
% clrs = ['#364B9A'; '#4A7BB7'; '#6EA6CD'; '#98CAE1'; '#C2E4EF';
%         '#EAECCC'; '#FEDA8B'; '#FDB366'; '#F67E4B'; '#DD3D2D';
%         '#A50026'];
end