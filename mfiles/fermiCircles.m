function ff=fermiCircles(imsize,pos,co,wid,amp)
% Usage ... y=fermiCircles(imsize,pos,radius,transition,amplitude)

% we can do ellipses by compressing the space and rotating the axis

if length(imsize)>2, imsize=size(imsize); end;
if nargin<5, amp=ones(size(co)); end;
if nargin<4, wid=ones(size(co)); end;

if length(co)==1, co=co*ones(size(pos,1),1); end;
if length(wid)==1, wid=wid*ones(size(pos,1),1); end;
if length(amp)==1, amp=amp*ones(size(pos,1),1); end;

[xx,yy]=meshgrid([1:imsize(1)],[1:imsize(2)]);

ff=zeros(size(xx));
for mm=1:length(co),
  ff0=amp(mm)./(1+exp((sqrt((xx-pos(mm,1)).^2+(yy-pos(mm,2)).^2)-co(mm))/wid(mm)));
  if mm==1, ff=ff0; else, ff=ff+ff0;end;
end;

if nargout==0,
  show(ff),
  clear ff
end;

