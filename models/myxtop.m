function f=myxtop(x,order)
% Usage ... f=myxtop(x,order)

[xr,xc]=size(x);

for m=1:xr,
  gain=0;
  num=0;
  den=0;
  poles=0;
  zeros=0;
  if order(1)==0,
    num=x(m,1);
    den=x(m,2:xc);
  elseif order(2)==0,
    num=x(m,1:xc-1);
    den=x(m,xc);
  else,
    num=x(m,1:1+order(1));
    den=x(m,2+order(1):2+order(1)+order(2));
  end;
  gain=den(1);
  den=den./gain;
  num=num./gain;
  poles=roots(den);
  zeros=roots(num);
  f(m,:)=[gain zeros' poles'];
end;