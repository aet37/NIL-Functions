function [cmap] = light_qual(Inds)
%VIBRANT_QUAL qualitative color scheme
%   Optional argument Inds to return a subset or re-ordering of the output

cmap0=[ 0.4667    0.6667    0.8667
        0.9333    0.5333    0.4000
        0.9333    0.8667    0.5333
        1.0000    0.6667    0.7333
        0.6000    0.8667    1.0000
        0.2667    0.7333    0.6000
        0.7333    0.8000    0.2000
        0.6667    0.6667         0];

if ~exist('Inds','var') || isempty(Inds)
    Inds=1:length(cmap0);
end

cmap=cmap0(Inds,:);

% original hex colors from paper
clrs=['#77AADD'; '#EE8866'; '#EEDD88'; '#FFAABB'; '#99DDFF';
                    '#44BB99'; '#BBCC33'; '#AAAA00'];
end