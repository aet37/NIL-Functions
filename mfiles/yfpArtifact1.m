function [y,y2]=yfpArtifact1(x,parms,x1,parms2fit,data)
% Usage ...  y=yfpArtifact1((x,parms,x1,parms2fit,data)
%
% Simulated object for that undergoes wrapping
% x is the parameters to fit, parms are the extra parameters necesssary to
% generate the object, x1 are the full parameters, parms2fit are those that
% will be optimized for. This is the generating function not the fit
% function.
%
% Ex. yfpArtifact1([],[size(im1) 3 130 130],[0 0 -30 20 3 1 2])

if ~exist('parms2fit','var'), parms2fit=[]; end

x1_orig=x1;
if ~isempty(parms2fit),
    %[length(x1) length(parms2fit) length(x)],
    x1(parms2fit)=x;
end

if (length(parms)==1)&(nargin==5),
    parms=[size(data) parms];
end

xdim=parms(1);
ydim=parms(2);
wrapf=parms(3);
if length(parms)==2, parms(3:6)=[0 0 0 1]; elseif length(parms)==3, parms(4:6)=[0 0 1]; end;
x0off=parms(4);
y0off=parms(5);
fit_type=parms(6);

x0=x1(1)+x0off-xdim/2;
y0=x1(2)+y0off-ydim/2;
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
    im=imrotate(im,ang,'bilinear','crop');
end
im=interp2(xg,yg,im,xg-x0,yg-y0).';
im(find(isnan(im)))=0;

if wrapf>100*eps,
    imw=angle(exp(j*im*pi*(amp/wrapf)))*(wrapf/pi);
else
    imw=im;
end

if nargin>4,
    y_orig=y;
    if fit_type==2,
      y=1-corr(imw(:),data(:)).^2;
    else,
      y=data-imw;
      y=y(:);
    end
else,
    %x1_orig,
    y=imw;
    y2=im;
end

if nargout==0,
    if nargin>4,
        clf,
        subplot(222), show(im),
        subplot(221), show(imw),
        subplot(223), show(data),
        subplot(224), show(reshape(y,size(im))),
    else
        clf,
        sublot(121), show(imw),
        sublot(122), show(im),
    end
    clear y
end

