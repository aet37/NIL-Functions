function [] = imagesc_mask(img,map,c_lims,sym_flag,mask,mask_color,x,y)
% IMAGESC_MASK plots scaled image with NaN values displayed a different color
% 
%   NaN values in the image display in mask color (default gray),
%   optionally supply separate binary mask for additional mask color
%   pixels. (NaN pixels are mask color with or without additional mask.)
% 
%   img: 2D image to display
%   map (optional): colormap, default "parula"
%   c_lims (optional): color axis limits, default to min and max of img
%   sym_flag (optional): 1 = makes c_lims centered on zero, off by default
%   mask (optional): binary mask, pixels true in mask display in background color
%   mask_color (optional): color of NaN/mask pixels, default [0.7 0.7 0.7] 
%   x and y (optional): vectors to change the x and y position/scale of the image plot
%
% Contact cmr167@pitt.edu with issues

% missing params set to defaults
if ~exist('map','var') || isempty(map)
    map=parula(601);
end
if ~exist('sym_flag','var') || isempty(sym_flag)
    sym_flag=0;
end
if ~exist('mask_color','var') || isempty(mask_color)
    mask_color=[0.7 0.7 0.7];
end
if ~exist('mask','var') || isempty(mask)
    mask=false(size(img));
end
if ~exist('c_lims','var')|| isempty(c_lims)
    c_lims=[min(img(~mask)) max(img(~mask))];
end

if ~exist('x','var') ||  isempty(x)
    x_flag=0;
else
    x_flag=1;
end

if ~exist('y','var') ||  isempty(y)
    y_flag=0;
else
    y_flag=1;
end

if y_flag==0 && x_flag==0
    scale_flag=0;
elseif y_flag==1 && x_flag==1
    scale_flag=1;
else
    scale_flag=0;
    warning('To use custom scale, scale vectors for both x and y must be provided')
end

% interpolates color map to 601 extries and adds back_color to either side
% large colormap means back_color shouldn't show in colorbar
map_size0=size(map,1);
if map_size0>=601
    map_final=map;
else
    map_final=interp1(1:map_size0,map,linspace(1,map_size0,601),'pchip');
end
map_final=[mask_color; map_final; mask_color];

% if mask given, set mask pixels to NaN;
mask=logical(mask);
img(mask)=NaN;

% makes c_lims zero-centered
if sym_flag==1
    c_lims=max(abs(c_lims))*[-1 1];
end

% set values out of range to the ends of c_lims
img(img<c_lims(1))=c_lims(1);
img(img>c_lims(2))=c_lims(2);

% c_lims expanded slightly because of back_color entry at top and bottom of map
factor=1+(1.001)/((size(map_final,1)-3)/2);
mean_c=mean(c_lims);
c_lims_new=((c_lims-mean_c)*factor)+mean_c;

% plots in current axes
if scale_flag==0
    imagesc(img)
elseif scale_flag==1
    imagesc(x,y,img)
end
colormap(map_final)
clim(c_lims_new) 
axis image
colorbar

end