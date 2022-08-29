function [y,uu]=lin51(x,parms,parms2fit,t,data,ww,numden)
% [y,u]=lin51(x,parms,parms2fit,t,data,ww,numden)
%
% Attempts to fit a nth-order linear model to the data.
% In this version, the input is generated (lin51 input is provided).


if (length(x)>0),
  parms(parms2fit)=x;
end;
uparms=parms(end-1:end);

t=t(:);
tl=length(t);

% Transfer Function Parameters
%   a1=3.8; a2=.2;
%   b1=4; b2=2; b3=.5;
tau=parms(1);
amp=parms(2);
t0=parms(3);

udur=uparms(1);
uramp=uparms(2);
uu=mytrapezoid3(t,t0+uramp,udur,uramp/2);


% Calculate system response using mysol function,
%  assume zero initial conditions.
if length(parms)==5,
  den=1/parms(1);
  y=mysol([1],[1 den(1)],uu,t);
else,
  % implement nth-order here with numden
  if exist('numden','var'),
    tmpnum=parms([1:numden(1)]+3);
    tmpden=parms([1:numden(2)]+3+numden(1));
    num=[1 tmpnum(1)];
    den=[1 tmpden(1)];
    for mm=2:numden(1), num=conv(num,[1 tmpnum(mm)]); end;
    for mm=2:numden(2), den=conv(den,[1 tmpden(mm)]); end;
  else,
    num=parms(4);
    den=parms(5:6);
    num=[1 num(1)],
    den=conv([1 den(1)],[1 den(2)]),
  end;
  y=mysol(num,den,uu,t);
end;
y=amp*y(:);

%keyboard,

if (nargin>5),
  err=data(:)-y;
  if exist('ww','var'), err=err(find(ww)); end;
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
  plot(t,y,t,data,t,uu*max(data(:)))
  clear y
end;

