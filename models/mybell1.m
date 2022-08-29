function f=mybell1(t,width,amp,center)
% Usage ... f=mybell1(t,width,amp,center)
% Bell function construction of the type
% f=2/(1-exp(t-center/width), the resulting vector
% will have t size.

argument=(t-center)./width;
f= amp./(1+exp(argument));

if (nargout==0), plot(t,f); end;