function dpm_dt=tmp(t,pm)

mmpa=133.32;
pamm=1/133.32;

c0=4;
pi=50;
po=30;
rr=10;

us=4;
ud=10;
ut=2;
ua=-0.5;
if (t<us),
  u=0;
elseif ((t>=us)&(t<(us+ud))),
  u=1-exp(-(t-us)/ut);
elseif (t>=(us+ud)),
  u=(1-exp(-(us+ud)/ut))*exp(-(t-(us+ud))/ut);
end;
r1=0.5*rr*(1+ua*u);
r2=0.5*rr;

dpm_dt = (1/c)*( ((pi-pm)/r1) - ((pm-po)/r2) );

