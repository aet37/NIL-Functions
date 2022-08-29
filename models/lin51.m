function [y,uu]=lin51(x,parms,parms2fit,u,t,data)
% [y,u]=lin51(x,parms,parms2fit,u,t,data)
%

if (length(x)>0),
  parms(parms2fit)=x;
end;

t=t(:);
u=u(:)-1;

tl=length(t);
ul=length(u);

% Transfer Function Parameters
%   a1=3.8; a2=.2;
%   b1=4; b2=2; b3=.5;
tau=parms(1);
amp=parms(2);
t0=parms(3);

uu=tshift(t,u,t0);


% Calculate system response using mysol function,
%  assume zero initial conditions.
if length(parms)==3,
  den=1/parms(1);
  y=mysol([1],[1 den(1)],uu,t);
else,
  num=parms(4);
  den=parms(5:6);
  num=[1 num(1)];
  den=conv([1 den(1)],[1 den(2)]);
  y=mysol(num,den,uu,t);
end;
y=amp*y(:)+1;

if (nargin>5),
  err=data(:)-y;
  %errn=length(err);
  %if (nargin>6),
  %  err=err.*wc(:);
  %  errn=sum(abs(wc)>0);
  %end;
  %err=err/max(y-1);
  %err=err/errn;
  [sum(err.^2)],
  y=err;
end;

if (nargout==0),
  plot(t,y,t,data)
end;

