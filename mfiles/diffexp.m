function y=diffexp(x,tau1,tau2,f1,amp)
% Usage y=diffexp(x,tau1,tau2,f1,amp)

if nargin<5, amp=1; end;
if nargin<4, f1=0.5; end;

y=f1*exp(-x/tau1)-(1-f1)*exp(-x/tau2);
y=amp*y./max(abs(y));

