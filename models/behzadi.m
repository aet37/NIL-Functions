function [f,r,cm,s,cmr,rr,t]=behzadi(x,tparms,parms2fit,parms,u,rr,cmr,flowdata,range)
% Usage ... [f,r,cm,s,cmr,rr,t]=behzadi(x,tparms,parms2fit,parms,u,rr,cmr,flowdata)

if (~isempty(x)),
  parms(parms2fit)=x;
end;

dt=tparms(1);
tfin=tparms(2);
t=[0:dt:tfin];

r0=parms(1);
eff=parms(2);
ks=parms(3);
gf=parms(4);
fpow=parms(5);
t0=parms(6);

s(1)=0;
r(1)=r0;
rb=1;
cm(1)=interp1(rr,cmr,r0);
for mm=2:length(t),
  s(mm) = s(mm-1) + dt*( eff*u(mm-1) - ks*s(mm-1) - gf*((r(mm-1)^fpow)-1) );
  cm(mm) = cm(mm-1) + dt*s(mm-1);
  r(mm) = interp1(cmr,rr,cm(mm));
end;

f=r.^fpow;

if (abs(t0)>(dt/10)),
  % do it at the end to avoid propagating errors
  t0i=round((t(1)+t0+dt)/dt);
  t0s=t(t0i); t0s=t0;
  s=tshift(t,s,t0s);
  r=tshift(t,r,t0s);
  f=tshift(t,f,t0s);
end;

if (nargin>=8),
  if (nargout==0),
    plot(t,f,t,flowdata)
  end;
  f=f(:)-flowdata(:);
  if (nargin>8),
    f=f(range);
  end;
  [x sum(f.^2)]
end;

