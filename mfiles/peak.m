function f=peak(x,center,tau,amplitude)
% Usage ... f=peak(x,center,tau,amplitude)
%
% Uses an exponent of time constant tau to
% generate a symmetric peak.

f=amplitude*exp(-abs(x-center)/tau);

if ~nargout,
  plot(x,f)
end;
