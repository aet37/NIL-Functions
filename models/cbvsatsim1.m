
clear all

dt=0.1;
tt=[0:dt:120];
uu=rect(tt,60,32);

ptau=6;
pT1=1.6; pT2=80e-3;
ctau=2;
ctau2=40;
cT1=1.5; cT2=160e-3;
TR=1;
TE=40e-3;

[exp(-TR/cT1) exp(-TR/pT1) exp(-0.5*TR/cT1)*exp(-0.5*TR/pT1)],
[exp(-TE/cT2) exp(-TE/pT2) exp(-0.5*TE/cT2)*exp(-0.5*TE/pT2)],

p(1)=0;
c(1)=0;
c2(1)=0;
s(1)=0;
for m=2:length(tt),
  p(m)=p(m-1)+dt*(1/ptau)*(uu(m-1)-p(m-1));
  c(m)=c(m-1)+dt*(1/ctau)*(uu(m-1)-c(m-1));
  c2(m)=c2(m-1)+dt*(1/ctau2)*(uu(m-1)-c2(m-1));
  cc(m)=0.6*c(m)+0.4*c2(m);
  s(m)=cc(m)-0.5*p(m);
  s2(m)=cc(m)-0.25*p(m);
end;

plot(tt,s,tt,s2,tt,cc,tt,p)

