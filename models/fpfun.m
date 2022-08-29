function y=fpfun(x,xparms,parms2fit,t,data,range)
% Usage ... y=fpfun(x,parms,parms2fit,t,data,range)

if (~isempty(parms2fit)),
  xparms(parms2fit)=x;
end;

t1=xparms(1);
a1=xparms(2);
g1=xparms(3);
h1=xparms(4);
t2=xparms(5)+t1;
a2=xparms(6);
g2=xparms(7);
h2=xparms(8);

%[t1 a1 g1 h1 t2 a2 g2 h2],

y=a1*gammafun(t,t1,g1,h1)+a2*gammafun(t,t2,g2,h2);

if (nargin>4),
  y=y-data;
  if (nargin>5),
    if (length(range)==2), range=[range(1):1:range(2)]; end;
    y=y(range);
  end;
end;

