function f=mybell4(t,width,amp)
% Usage ... f=mybell4(t,width,amp)
% Bell function construction of the type
% f=amp*exp(-t/width), the resulting vector
% will have t size.

argument=(-1.*t)./width;
f= amp.*exp(argument);

if (nargout==0), plot(t,f); end;