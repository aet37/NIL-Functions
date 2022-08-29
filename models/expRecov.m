function y=expReconv(x,t,z)
% Usage ... y=expRecov(x,t,z)

if length(x)==2, x(3)=1; end;

A=x(1);
k=x(2);
alpha=x(3);

y=A*(1-2*alpha*exp(-k*t));

if (nargin>2),
  y=(y-z);
end;

