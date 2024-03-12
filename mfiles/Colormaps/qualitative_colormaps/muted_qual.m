function [cmap] = muted_qual(Inds)
%MUTE_QUAL qualitative color scheme
%   Optional argument Inds to return a subset or re-ordering of the output

cmap0=[  0.8000    0.4000    0.4667
        0.2000    0.1333    0.5333
        0.8667    0.8000    0.4667
        0.0667    0.4667    0.2000
        0.5333    0.8000    0.9333
        0.5333    0.1333    0.3333
        0.2667    0.6667    0.6000
        0.6000    0.6000    0.2000
        0.6667    0.2667    0.6000];

if ~exist('Inds','var') || isempty(Inds)
    Inds=1:length(cmap0);
end

cmap=cmap0(Inds,:);

% original hex colors from paper
% clrs=['#CC6677'; '#332288'; '#DDCC77'; '#117733'; '#88CCEE';
%       '#882255'; '#44AA99'; '#999933'; '#AA4499'];
end