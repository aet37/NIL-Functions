function [yy,uu]=linf(x,parms,parms2fit,t,data,con)
% Usage ... f=linf(x,parms,parms2fit,t,data,con)
%
% parms = [tst tdur tramp amp z1 p1 p2]

if (~isempty(x)),
  parms(parms2fit)=x;
end;

ust=parms(1);
udur=parms(2);
uramp=parms(3);
uu=mytrapezoid(t,ust,udur,uramp);

amp=parms(4);
z1=parms(5);
p1=parms(6);
p2=parms(7);

num=amp*[1 z1];
den=conv([1 p1],[1 p2]);
yy=mysol(num,den,uu,t);


if (nargout==0),
  plot(t,yy)
end;

if (nargin>4),
  if (nargout==0),
    plot(t,data,t,yy)
  end;
  yy=yy-data;
  if (nargin>5),
    yy=yy.*con;
  end;
  [x sum(yy.*yy)],
end;

