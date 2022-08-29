function phs=movspinphs(G,r,t)
% Usage ... phs=movspinphs(G,r,t)
%
% Assumes G and r are Nx3 and t is uniformly spaced
% Units: G = G/cm, r = cm

dt=t(2)-t(1);
gamma=26752/(2*pi);	% 1 / G s

Gdotr=sum((G.*r)')';
phs=cumsum(gamma*Gdotr*dt);

if (nargout==0),
  subplot(311)
  plot(t,G)
  xlabel('Time'), ylabel('Gradient')
  subplot(312)
  plot(t,r)
  xlabel('Time'), ylabel('Position')
  subplot(313)
  plot(t,phs)
  xlabel('Time'), ylabel('Phase')
end;
