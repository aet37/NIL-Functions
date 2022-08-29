function x=movspin(t,v,x0)
% Usage ... x=movspin(t,v,x0)
%
% Assumes v is Nx3 and t is Nx1 and t is uniformly spaced

if (nargin<3), x0=zeros([length(t) 3]); end;

dt=t(2)-t(1);
x1=cumsum(v*dt);
x=x0+x1;

if (nargout==0),
  subplot(211)
  plot(t,v)
  xlabel('Time'), ylabel('Velocity')
  subplot(212)
  plot(t,x)
  xlabel('Time'), xlabel('Position')
end
