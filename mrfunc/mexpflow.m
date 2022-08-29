function f=mexpflow(t,tau1,tau2,tau3,lag,amp)
% Usage ... f=mexpflow(t,tau1,tau2,tau3,lag,amp)
%
% Describes a possible flow description in a capillary
% given by ascending and descending time constants and
% a time between the two. Assumes steady-state of the
% on-period.

% See mflowmod function.


if t<=lag,
  f=0;
elseif t<=(lag+tau1),
  f=amp*(1-exp(-(t-lag)/tau2));
else,
  f=amp*(exp(-(t-lag-tau1)/tau3));
  %f=f-(amp*exp(-(t-lag)/tau2));
end;
