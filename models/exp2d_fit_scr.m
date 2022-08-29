function [xx1,yy1,yd1]=exp2d_fit_scr(xx0,im1,mask,ythr)
% Usage ... [x,y]=exp2d_fit_scr(x0,im1,mask)
% 
% mask if included only considers fitting where mask==1

%load example_data_for_2d_fit
%im1=m4_d1_pc2_50ua;

xopt=optimset('lsqnonlin');
xopt.TolxFun=1e-10;
xopt.TolX=1e-8;

%xx0=[60 24 3 1 0];
xxlb=[xx0(1)-10 xx0(2)-10 1e-2 0    -200];
xxub=[xx0(1)+10 xx0(2)+10 1e+2 1000 +200];

y0=exp2d_fit(xx0,size(im1));
if nargin==3,
  xx1=lsqnonlin(@exp2d_fit,xx0,xxlb,xxub,xopt,im1,mask);
else,
  xx1=lsqnonlin(@exp2d_fit,xx0,xxlb,xxub,xopt,im1);
end;
yy1=exp2d_fit(xx1,size(im1));

yf1=[im1(round(xx1(1)),:)' yy1(round(xx1(1)),:)' im1(:,round(xx1(2))) yy1(:,round(xx1(2)))];
if nargin<5, ythr=2; end;
yd1=-xx(3)*log(ythr/xx(4));

if nargout==0,
  clf,
  subplot(211), plot([1:size(im1,1)],[im1(round(xx1(1)),:)' yy1(round(xx1(1)),:)']),
  axis tight, grid on,
  subplot(212), plot([1:size(im1,2)],[im1(:,round(xx1(2)))  yy1(:,round(xx1(2)))]),
  axis tight, grid on,
end;


function yy=exp2d_fit(xx,imsz,mask)
  % xx parameters are [x0 y0 sig1]
  r0=round(xx(1));
  c0=round(xx(2));
  sig0=xx(3);
  amp=xx(4);
  if length(xx)==5, base=xx(5); else, base=0; end;
  if length(imsz)==2,
    yy=zeros(imsz);
  else,
    yy=zeros(size(imsz));
  end;
  yy=double(yy);
  dd=zeros(size(yy));
  dd(r0,c0)=1;
  dd=bwdist(dd);
  yy=amp*exp(-double(dd)/sig0)+base;
  if length(imsz)>2,
    yy=yy-double(imsz);
  end;
  if nargin==3,
    yy=yy(find(mask));
  end;
end

