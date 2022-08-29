function yy=gammafun_fit(y,t,x0,tr,xb)
% Usage ... ys=gammafun_fit(y,t,x0,tr,xb)
%
% y = [art_data ven_data]
% x0 is parameter guess [tau b amp t0]
% xb is parameter range for xlb and xub
% this function requires artery and vein measurements and
% estimates the transfer function. MTT is the peak of the
% the gamma function estimate and CTH is the width of this
% function

xopt=optimset('lsqnonlin');
xopt.TolxFun=1e-10;
xopt.TolX=1e-8;

if ~exist('x0','var'), x0=[1.25 2.0 1 0]; end;
if ~exist('tr','var'), tr=[]; end;
if ~exist('xb','var'), 
  xlb=[0 0 -1e3 x0(4)-4];
  xub=[100 1000 1e6 x0(4)+4];
else,
  xlb=[0 0 -1*xb(3) x0(4)-xb(4)];
  xub=[xb(1) xb(2) xb(3) x0(4)+xb(4)];
  disp(sprintf('  lb limit= %.2f %.2f %.2f %.2f',xlb(1),xlb(2),xlb(3),xlb(4)));
  disp(sprintf('  ub limit= %.2f %.2f %.1f %.2f',xub(1),xub(2),xub(3),xub(4)));
end;

if isempty(tr),
  i1=1; i2=length(t);
  i0=[1:10];
else,
  i1=find(t>=tr(1),1);
  i2=find(t>tr(2),1);
  i0=find(t<tr(1));
end;
torig=t;
yorig=y;

for mm=1:size(y,2),
  y(:,mm)=y(i1:i2,mm)-mean(y(i0,mm));
end;
t=t(i1:i2);
th=t-t(1);


y0=gammafit_wrap(x0,t,y(:,1));
%plot(t,y,t,y0), drawnow,
%legend('art data','ven data','ven guess')
%disp('press enter...'); 

xx1=lsqnonlin(@gammafit_wrap2,x0,xlb,xub,xopt,th,y);

% get fitted curve
y1=gammafit_wrap(xx1,t);
%plot(t,y,t,y1), drawnow,

tn=[t(1):(t(2)-t(1))/1000:t(end)];
yn=gammafit_wrap(xx1,tn);
[tmpmax,tmpmaxi]=max(yn);
ttp=tn(tmpmaxi);
tmpi=find((yn/tmpmax)>=0.5);
fwhm=tn(tmpi(end))-tn(tmpi(1));

yy.t=torig;
yy.y=yorig-mean(yorig(i0));
yy.y0=mean(yorig(i0));
yy.t_range=tr;
yy.xx=xx1;
yy.ii=[i1 i2];
yy.i0=i0;
yy.tfit=t;
yy.yfit=y1;
yy.ttp=ttp;
yy.fwhm=fwhm;
yy.cth=[xx1(1)*xx1(2) sqrt(xx1(1))*xx1(2)];

if nargout==0,
  plot(t,y,t,y1), drawnow,
end;


%%%%
function y=gammafit_wrap(xx,tt)
  % xg=[t0 tau b amp]
  y=gammafun(tt,xx(4),xx(1),xx(2),xx(3));
return,

function ee=gammafit_wrap2(xx,tt,yy)
  hh=gammafun(tt,xx(4),xx(1),xx(2),xx(3));
  y2est=myconv(yy(:,1),hh);
  ee=yy(:,2)-y2est;
return,

