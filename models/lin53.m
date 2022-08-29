function [yy,uu,uu2]=lin53(x,parms,parms2fit,t,data,ww)
% [y,u]=lin53(x,parms,parms2fit,t,data,ww)
%
% Fit a 2nd order linear model to the data
% 1 zero 2 pole model
% parms = [wid ramp amp del zero1 pole1 pole2]
%
% Ex. lin53([],[0.5 0.5 1.0 0 1 0.5 0.4 1],[],tmptt1,tmpyy1)



if (length(x)>0),
  parms(parms2fit)=x;
end;

wid=parms(1);
ramp=parms(2);
amp=parms(3);
del=parms(4);
z1=parms(5);
p1=parms(6);
p2=parms(7);
dur=parms(8);

t=t(:);
tlen=length(t);
dt=t(2)-t(1);

% actual input
uu=mytrapezoid3(t,del,dur,dt);

% broadening function
uu1=mytrapezoid3(t,t(1),wid,ramp);

% model input
uu2=myconv(uu,uu1);
uu2=uu2/max(uu2);

% model output
yy=mysol([1 z1],[1 p1 p2],uu2,t);
yy=amp*yy;
% yy=myconv(yy,mytrapezoid3(t,t(1),wid,ramp));


if (nargin>4),
  yy1=yy;
  ee=yy(:)-data(:);
  disp(sprintf('  mse=%.3e, p1=%.3f, p2=%.3f, p3=%.3f, p4=%.3f, p5=, p6=, p7=',mean(ee.^2),parms(1),parms(2),parms(3),parms(4)));
  if (nargout==0),
    clf,
    plot(tt(:),[uu(:) yy(:)],tt(:),data(:))
    axis tight, grid on,
    fatlines(1.5);
  end;
  %keyboard,
  if nargin>5,
    yy=ee(find(ww));
  else,
    yy=ee;
  end;
end;

