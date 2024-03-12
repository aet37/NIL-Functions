function [lims] = set_clims(img,prcts,sym_flag,ax)
% SET_CLIMS Sets clim of given axis to desired percentiles of input image
%   img: image to derive limits from
%   prcts (optional): percentiles of image, defaults to [0.5 99.5]
%   sym_flag (optional): symmetry flag, sym_flag=1 --> clim symmetric around 0,
%       for use with diverging colormaps such as blue-white-red
%   ax (optional): axis to apply change, default to currently selected axis
%
% Contact cmr167@pitt.edu with issues

% set standard parameters
if ~exist('sym_flag','var') || isempty(sym_flag)
    sym_flag=0;
end
if ~exist('prcts','var') || isempty(prcts)
    prcts=[0.5 99.5];
end
if ~exist('ax','var') || isempty(prcts)
    ax=gca;
end

lims=[prctile(reshape(img,1,[]),prcts(1)) prctile(reshape(img,1,[]),prcts(2))];
if sym_flag==1
    lims=max(abs(lims))*[-1 1];
end
clim(ax,lims)
end