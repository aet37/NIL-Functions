function [yfit,xx]=fpfit(x,t,range)
% Usage ... y=fpfit(x,t,range)

if (nargin<3),
  range=[1 length(t)];
end;

opt2=optimset('lsqnonlin');
opt2.TolFun=1e-10;
opt2.TolX=1e-10;
opt2.MaxIter=1000;
opt2.Display='iter';

dt=t(2)-t(1);

t1=0.008;
t2=0.004;

a1=-0.5; g1=0.010; h1=2.0;
a2=+1.0; g2=0.001; h2=2.0;

xg=[t1 a1 g1 h1 t2 a2 g2 h2];
xl=[0 -10 0  0  0.0 -10  0  0];
xu=[1 +10 10 10 0.1 +10 10 10];

parms2fit=[1 2 3 4 5 6 7 8];

yfit=zeros(size(x));
disp(sprintf('Fitting %d FPs...',size(x,2)));
for mm=1:size(x,2),
  xx(mm,:)=lsqnonlin(@fpfun,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,xg,parms2fit,t,x(:,mm),range);
  %xx=xg;
  yfit(:,mm)=fpfun(xx(mm,:),xg,parms2fit,t(:));
end;

if (nargout==0),
  plot(t,x,t,yfit)
end;


