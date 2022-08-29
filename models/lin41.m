function [z,w,v]=lin41(x,t,u,parms,parms2fit,y,wc)
% [z,w]=lin41(x,t,u,parms,parms2fit,y,w)
%

if (length(x)>0),
  parms(parms2fit)=x;
end;

t=t(:);
u=u(:);

tl=length(t);
ul=length(u);

% Transfer Function Parameters
%   a1=3.8; a2=.2;
%   b1=4; b2=2; b3=.5;

% Filtering function initialization and selection
vst=parms(1);
vramp=parms(2);
vdur=parms(3);
v=mytrapezoid3(t,vst+vramp,vdur,vramp);

vnormalize=1;
if (vnormalize),
  v=v/trapz(t,v);
end;

w=myconv(u,v);
w=w(:);

% Calculate system response using mysol function,
%  assume zero initial conditions.
if length(parms)==5,
  num=1;
  den=parms(4);
  amp=parms(5);
  den=[1 den(1)];
else,
  num=parms(4);
  den=parms(5:6);
  amp=parms(7);
  num=[1 num(1)];
  den=conv([1 den(1)],[1 den(2)]);
end;

z=mysol(num,den,w,t);
z=amp*z(:)+1;
zz=z;


if (nargin>5),
  err=y(:)-z;
  errn=length(err);
  if (nargin>6),
    err=err.*wc(:);
    errn=sum(abs(wc)>0);
  end;
  %err=err/max(y-1);
  %err=err/errn;
  [sum(err.^2)],
  z=err;
end;

if (nargout==0),
  plot(t,y,t,zz)
end;

