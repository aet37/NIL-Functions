function [cmap] = vibrant_qual(Inds)
%VIBRANT_QUAL qualitative color scheme
%   Optional argument Inds to return a subset or re-ordering of the output

cmap0=[ 0.9333    0.4667    0.2000
        0         0.4667    0.7333
        0.2000    0.7333    0.9333
        0.9333    0.2000    0.4667
        0.8000    0.2000    0.0667
        0         0.6000    0.5333];

if ~exist('Inds','var') || isempty(Inds)
    Inds=1:length(cmap0);
end

cmap=cmap0(Inds,:);

% original hex colors from paper
% clrs=['#EE7733'; '#0077BB'; '#33BBEE'; '#EE3377'; '#CC3311'; '#009988'];
end