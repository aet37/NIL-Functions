function y=tkfit(x,parms,parms2fit,d,data)
% Usage ... y=tkfit(x,parms,parms2fit,d,data)

if ~isempty(parms2fit),
  parms(parms2fit)=x;
end;

a1=parms(1);
d1=parms(2);
w1=parms(3);
d2=parms(4);
w2=parms(5);
inv_flag=parms(6);

y=a1./(1+exp((d-d1)/w1))+(1-a1)./(1+exp((d-d2)/w2));
if inv_flag, y=1-y; end;

if nargin==5,
  ee=y-data;
  if nargout==0,
    plot(d,y,d,data)
  end;
  y=ee;
else,
  if nargout==0,
    plot(d,y)
  end;
end;



