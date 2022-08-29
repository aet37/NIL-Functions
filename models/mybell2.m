function f=mybell2(t,center,width,amp)
% Usage ... f=mybell1(t,center,width,amp)
% Bell function construction of the type
% f=amp/(1-exp((t-center)/width), the resulting vector
% will have t size.

argument=(0.5).*(t-center)./width;
f= amp.*exp(-argument.^2);

if (nargout==0), plot(t,f); end;