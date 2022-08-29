function f=mybell5(t,width,amp,center)
% Usage ... f=mybell1(t,width,amp,center)
% Bell function construction of the type
% f=1/(1+exp((r-r0)/d)^2), the resulting vector
% will have t size.

argument=(abs(t-center)./width).^2;
f= amp./(1+exp(argument));

if (nargout==0), plot(t,f); end;