function y=yfp_fit1(x,parms,x1,parms2fit,data)
% Usage ... y=yfp_fit1(x,parms,x1,parms2fit,data)
%
% parms = [xdim ydim wrap_factor]
% x0 = [x0 y0 ang ww amp xscale yscale]

if ~exist('parms2fit','var'), parms2fit=[]; end

if ~isempty(parms2fit),
  x0(parms2fit)=x;
end

if length(parms)==1)&(nargin==5),
    parms=[size(data) parms];
end

xdim=parms(1);
ydim=parms(2);
if length(parms)==2, parms(3)=0; end;
wrapf=parms(3);

x0=x1(1);
y0=x1(2);
ang=x1(3);
ww=x1(4);
amp=x1(5);
xscale=x1(6);
yscale=x1(7);

xx=[0:xdim-1]-floor(xdim/2);
yy=[0:ydim-1]-floor(ydim/2);
xx=xx*xscale;
yy=yy*yscale;

[xg,yg]=meshgrid(xx,yy');
im=amp*exp(-(xg.^2+yg.^2)/(ww*ww));
if abs(ang)>100*eps,
    im=imrotate(im,ang,'crop');
end
im=interp2(xg,yg,im,xg-x0,yg-y0);
im(find(isnan(im)))=0;

if wrapf>100*eps,
    imw=angle(exp(j*im*pi*(amp/wrapf)))*(wrapf/pi);
else
    imw=im;
end

if nargin>4,
    y=data-imw;
else
    y=imw;
end

if nargout==0,
  if nargin>4,
      clf,
      subplot(221), show(imw),
      subplot(222), show(data),
      subplot(223), show(y),
  else
      clf,
      show(imw),
  end
  clear y
end

