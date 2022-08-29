function yim=im_crop(xim,coords)
% Usage ... y=im_crop(x,coords)

if (nargin<2),
  [a,b]=find(abs(xim)>0);
  coords=[min(a) max(a) min(b) max(b)];
end;

yim=xim(coords(1):coords(2),coords(3):coords(4));
 
