function [xx,y1]=lin53_scr(data,t,parms,parms2fit,tbias)
% Usage ... y=lin53_scr(data,t,parms,parms2fit,tbias)
%
% Fit 2nd-order model to data based on parameters parms (x0)
% parms(x0)=[wid ramp amp del zero1 pole1 pole2]

if ~exist('tbias','var'), 
  tbias=[t(1) t(end)];
  ibias=ones(size(data)); 
else, 
  ibias=zeros(size(data));
  ibias([find(t>=tbias(1),1) find(t>=tbias(2),1)])=1; 
end;
if ~exist('parms2fit','var'), parms2fit=[1:8]; end;
if ~exist('parms','var'), parms=[0.5 0.5 1.0 0 1 0.5 0.4 0.8]; end;

xopt=optimset('lsqnonlin');
xopt.TolxFun=1e-10;
xopt.TolX=1e-8;

xlb=[0   1e-10 -1e10  0  -1e4 -100 -100 0 ];
xub=[100 1e+2  +1e10  10 +1e4 +100 +100 100];

x0=parms(parms2fit);
xlb=xlb(parms2fit);
xub=xub(parms2fit);

%lin53([],[0.5 0.5 1.0 0 1 0.5 0.4 0.8],[],tmptt1,tmpyy1)
y0=lin53(x0,parms,parms2fit,t);

if nargout==0,
  clf,
  plot(t,data,t,y0)
  axis('tight'), grid('on'), fatlines(1.5),
  tmpax=axis; axis([tbias tmpax(3:4)]);
  parms2fit,
  disp('  press enter to continue...')
  pause,
end;

xx=lsqnonlin(@lin53,x0,xlb,xub,xopt,parms,parms2fit,t,data);
y1=lin53(xx,parms,parms2fit,t);

if nargout==0,
  clf,
  plot(t,data,t,y0,t,y1)
  axis('tight'), grid('on'), fatlines(1.5),
  tmpax=axis; axis([tbias tmpax(3:4)]);
end;
