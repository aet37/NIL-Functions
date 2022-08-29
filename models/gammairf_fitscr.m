function yy=gammairf_fit(y,u,t,x0,tr,xb)
% Usage ... ys=gammairf_fit(y,u,t,x0,tr,xb)
%
% x0 is parameter guess [tau b amp t0]
% xb is parameter range for xlb and xub

y=double(y);
u=double(u);
t=double(t);

xopt=optimset('lsqnonlin');
xopt.TolxFun=1e-10;
xopt.TolX=1e-8;

if ~exist('x0','var'), x0=[1.25 2.0 1 0 0 0]; end;
if ~exist('tr','var'), tr=[]; end;
if ~exist('xb','var'), 
  xlb=[0 0 -1e3 0];
  xub=[100 1000 1e6 4];
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

%torig=t;
%yorig=y;
%y=y(i1:i2)-mean(y(i0));
%t=t(i1:i2);

y0=gammairf_wrap(x0,t);
plot(t,y,t,myconv(u,y0)), drawnow, 
%pause, disp('press enter...'); 

xx1=lsqnonlin(@gammairf,x0,xlb,xub,xopt,t,y,u);

% get fitted curve
y1=gammairf_wrap(xx1,t);
plot(t,y,t,myconv(u,y1)), drawnow, 
%pause, disp('press enter...');

tn=[t(1):(t(2)-t(1))/1000:t(end)];
yn=gammairf_wrap(xx1,tn);
[tmpmax,tmpmaxi]=max(yn);
ttp=tn(tmpmaxi);
tmpi=find((yn/tmpmax)>=0.5);
fwhm=tn(tmpi(end))-tn(tmpi(1));

yy.t=t;
yy.u=u;
yy.y=y;
yy.xx=xx1;
yy.gfit=y1;
yy.yfit=myconv(u,y1);
yy.ee=mean((y-yy.yfit).^2);
yy.ttp=ttp;
yy.fwhm=fwhm;

if nargout==0,
  clf,
  subplot(211), plot(t,y1),
  subplot(212), plot(t,y,t,myconv(u,y1)),
  drawnow,
end;


%%%%
function y=gammairf_wrap(xx,tt)
  y=gammafun(tt,xx(4),xx(1),xx(2),xx(3));
return,

