function ff=fermi2d_obj(imsize,loc,co,wid,amp,xy_scale,rot)
% Usage ... y=fermi2d_obj(im_or_imsize,loc,co,wid,amp,xy_scale,rot)

if ~exist('rot','var'), rot=[]; end;
if ~exist('xy_scale','var'), xy_scale=[]; end;

do_rot=1;
if isempty(rot), do_rot=0; end;
if isempty(xy_scale), xy_scale=[1 1]; end;
if length(xy_scale)==1, xy_scale(2)=1; end;

if length(imsize)>3,
  im=imsize;
  imsize=size(im);
end;

if length(co)==1, co=co*ones(size(loc,1),1); end;
if length(wid)==1, wid=wid*ones(size(loc,1),1); end;
if length(amp)==1, amp=amp*ones(size(loc,1),1); end;
if do_rot, if length(rot)==1, rot=rot*ones(size(loc,1),1); end; end;

[xx,yy]=meshgrid([1:imsize(1)]/xy_scale(1),[1:imsize(2)]/xy_scale(2));
%[xx,yy]=meshgrid([-imsize(1)/2:imsize(1)/2-1],[-imsize(2)/2:imsize(2)/2-1]);

ff=zeros(size(xx));
for mm=1:size(loc,1),
  xloc=loc(mm,1)/xy_scale(1);
  yloc=loc(mm,2)/xy_scale(2);
  if do_rot,
    xloc0=imsize(1)/xy_scale(1)/2;
    yloc0=imsize(2)/xy_scale(2)/2;
    xloc1=xloc-xloc0;
    yloc1=yloc-yloc0;
    xloc=xloc0;
    yloc=yloc0;
  end;
  ff1=zeros(size(xx));
  ff1=amp(mm)./(1+exp((sqrt((xx-xloc).^2+(yy-yloc).^2)-co(mm))/wid(mm)));
  if do_rot, 
    ff1=rot2d_f(ff1,rot(mm));
    ff1=imshift2(ff1,yloc1,xloc1);
  end;
  ff=ff+ff1;
end;

if nargout==0,
  show(ff),
  clear ff
end;


