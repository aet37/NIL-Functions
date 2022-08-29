function [I0,T2,fit]=calcT2(TEs,data)
% Usage ... [I0,T2]=calcT2(TEs,data)

xx=polyfit(TEs,log(data),1);

I0=exp(xx(2));
T2=-1/xx(1);
fit=I0*exp(-TEs/T2);

if (nargout==0),
  plot(TEs,data,TEs,fit)
  title(sprintf('I0= %5.3f   T2= %5.3f ms',I0,1000*T2))
end;
if (nargout==1),
  I0=T2;
end;

