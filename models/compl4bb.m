
clear all

ctype=0;

mu=.004;
mmpa=133.32;
pamm=1/133.32;

c0=.002;
pi=80*mmpa;
po=00*mmpa;
pm0=40*mmpa;

r0=.1e-4;
l0=1e-2;
rr=8*mu*l0/(pi*r0*r0*r0*r0);
v0=pi*r0*r0*l0;

k=40;
f1p=0.4;
v1p=((f1p+1)^0.4)-1;
k1=(rr/rr)*(f1p+1)/(exp(k*v1p)-1);

[t,pm]=ode23('compl4b',0,100,pm0,1e-6);

us=4;
ud=10;
ut=2;
ua=-0.5;
for m=1:length(t),
  if (t(m)<us),
    u(m)=0;
  elseif ((t(m)>=us)&(t(m)<(us+ud))),
    u(m)=1-exp(-(t(m)-us)/ut);
  elseif (t(m)>=(us+ud)),
    u(m)=(1-exp(-(us+ud)/ut))*exp(-(t(m)-(us+ud))/ut);
  end;
end; u=u(:);
r1=rr*(1+ua*u);
r2=rr;

qi=((pi-pm)./r1);
qo=((pm-po)./r2);

r0t=((8*mu*l0)./(pi*r1)).^(1/4);
%v0t=0.5*pi*r0t.*r0t*l0+0.5*v0;
v0t=v0;
if (ctype==1),
  c=(v0t/k).*(1./(pm-pm0+k1*pm0));
  v=v0t+(v0t/k).*log((1/k1)*(pm/pm0-1)+1);
else,
  c=(1/c0)*(v0t/pm0);
  v=v0t+(v0t/c0).*(pm/pm0-1);
end;
%r2=r2.*(v0./v);
r1=0.5*r1;
r2=0.5*r2;

