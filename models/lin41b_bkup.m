function [z,w,v]=lin41(x,t,u,nnumden,parms,parms2fit,y,wc)
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
% ** none for now **

% Calculate system response using mysol function,
%  assume zero initial conditions.
if nnumden(1)==0,
  num=[1];
elseif nnumden(1)==1,
  num=[1 parms(1)];
else,
  for mm=1:nnumden(1),
  end;
end;
nden=length(parms)-nnumden(1);

num=parms(4);
den=parms(5:6);
amp=parms(7);	% always last term

num=[1 num(1)];
den=conv([1 den(1)],[1 den(2)]);
z=mysol(num,den,w,t);
z=amp*z(:)+1;

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
  plot(t,y,t,z)
end;

