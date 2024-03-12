function [cmap] = iridescent(N)
%IRIDESCENT sequential colour scheme with a linearly varying luminance that also works in colour-blind vision.
%   Outputs colormap with length specified by N, default length is 256
%   Developed by Paul Tol, more information at https://personal.sron.nl/~pault/data/colourschemes.pdf

if ~exist('N','var') || isempty(N)
    N=256;
end

cmap0=[ 0.9961    0.9843    0.9137
        0.9882    0.9686    0.8353
        0.9608    0.9529    0.7569
        0.9176    0.9412    0.7098
        0.8667    0.9255    0.7490
        0.8157    0.9059    0.7922
        0.7608    0.8902    0.8235
        0.7098    0.8667    0.8471
        0.6588    0.8471    0.8627
        0.6078    0.8235    0.8824
        0.5529    0.7961    0.8941
        0.5059    0.7686    0.9059
        0.4824    0.7373    0.9059
        0.4941    0.6980    0.8941
        0.5333    0.6471    0.8667
        0.5765    0.5961    0.8235
        0.6078    0.5412    0.7686
        0.6157    0.4902    0.6980
        0.6039    0.4392    0.6196
        0.5647    0.3882    0.5333
        0.5020    0.3412    0.4392
        0.4078    0.2863    0.3412
        0.2745    0.2078    0.2275];

cmap=interp1(linspace(0,1,length(cmap0)),cmap0,linspace(0,1,N),'pchip');

% original hex colors from paper
% clrs = ['#FEFBE9'; '#FCF7D5'; '#F5F3C1'; '#EAF0B5'; '#DDECBF';
%         '#D0E7CA'; '#C2E3D2'; '#B5DDD8'; '#A8D8DC'; '#9BD2E1';
%         '#8DCBE4'; '#81C4E7'; '#7BBCE7'; '#7EB2E4'; '#88A5DD';
%         '#9398D2'; '#9B8AC4'; '#9D7DB2'; '#9A709E'; '#906388';
%         '#805770'; '#684957'; '#46353A'];
end