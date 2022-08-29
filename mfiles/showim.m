function showim(x,wlevel,cmap)
% Usage ... showim(x,wlevel,cmap)
%
% Opens a new figure in true pixel dimensions
%

[m,n]=size(x);

if (nargin<3), cmap=gray(256); end;
if (nargin<2), wlevel=[min(min(x)) max(max(x))]; end;

figure('Units','pixels','Position',[100 100 m n])
show(x,wlevel)
title(''), axis('off'), grid('off'), axis('image'),
colormap(cmap);
set(gca,'Position',[0 0 1 1]);


