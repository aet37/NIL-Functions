function y=calcPO2tc(data,dt,i0)
% Usage ... y=calcPO2tc(data,dt,i0s)
%
% Fits single-exponential decays to PO2 data to determine the PO2
% sensor time constant. If the last term is not included, the initial
% points for fitting will be selecting from a plot of the data

tw=3;

data=data(:);

if ~exist('i0'),
  found=0;
  mm=0;
  while(~found),
    disp('prepare figure for selection...')
    figure(1)
    if mm>0,
      plot([1:length(data)],data,round(pos(:,1)),data(round(pos(:,1))),'rx'),
    else,
      plot(data),
    end;
    pause,
    good_loc=0;
    while(~good_loc),
      disp(sprintf('select onset position #%d',mm+1));
      tmppos=ginput(1);
      tmpax=axis;
      plot([1:length(data)],data,[tmppos(1) round(tmppos(1))],[tmppos(2) data(round(tmppos(1)))],'rx'),
      axis(tmpax);
      drawnow,
      good_loc=input('location ok? [1=yes, 9=yes+done, 0=no]: ');
    end;
    mm=mm+1;
    pos(mm,:)=tmppos;
    if good_loc==9,
      found=1;
    end;
  end;
end;

figure(1)
plot([1:length(data)],data,round(pos(:,1)),data(round(pos(:,1))),'rx'),

i0=round(pos(:,1));
nw=round(tw/dt);

for mm=1:length(i0)
  yy(:,mm)=data([0:nw-1]+i0(mm));
end;
tt=[0:nw-1]*dt;
tt=tt(:);

y.i0=i0;
y.tt=tt;
y.yy=yy;


xopt=optimset('lsqnonlin');
xopt.TolX=1e-8;
xopt.TolPCG=1e-2;
xopt.TolFun=1e-8;
xopt.DiffMinChange=1e-10;

% tau amp base
xg=[1 0.1 0.2];
xl=[1e-3 -2 -2];
xu=[10 2 2];

% fit individually
for mm=1:length(i0),
  tmpyy=yy(:,mm);
  xg(1)=1.0;
  xg(2)=tmpyy(1)-tmpyy(end);
  xg(3)=mean(tmpyy(end-4:end));
  xx(mm,:)=lsqnonlin(@myfun,xg,xl,xu,xopt,tt,tmpyy);
  xxy(:,mm)=myfun(xx(mm,:),tt);
end;
y.xx=xx;
y.xxfit=xxy;

% fit all
tmpyy=mean(yy,2);
xg(1)=1.0; xg(2)=tmpyy(1)-tmpyy(end); xg(3)=mean(tmpyy(end-4:end));
x=lsqnonlin(@myfun,xg,xl,xu,xopt,tt,tmpyy);
xy=myfun(x,tt);

y.y_avg=tmpyy;
y.x_avg=x;
y.tau_avg=mean(xx(:,1));
y.x_fit=xy;

figure(1)
plot(tt,[tmpyy(:) xy(:)])
title(sprintf('average fit:  tau=%.3f  amp= %.4f  offset= %.4f',x(1),x(2),x(3))),
xlabel('time'), ylabel('amplitude'),
drawnow,

return;




function F=myfun(x,tt,xdata)
% x=[tau amp baseline]
F=x(2)*exp(-tt/x(1))+x(3);
if nargin==3, F=F-xdata; end;
return;

