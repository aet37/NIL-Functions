function showim2(x,wlevel)
% Usage ... showim2(x,wlevel)
%
% Opens a new figure in true pixel dimensions
%

[m,n]=size(x);

if (nargin<2), wlevel=[min(x(:)) max(x(:))]; end;

set(gcf,'Units','pixels','Position',[100 100 m n])
imagesc(x,wlevel), axis image,
title(''), axis('off'), grid('off'), axis('image'),
set(gca,'Position',[0 0 1 1]);


