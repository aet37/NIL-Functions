%function [qout,qin,V,C,dPdt]=compl1(P,t)
%% Usage ... qout=compl1(P,t)

clear all

ctype=1;
mmHg2Pa=133.32;
Pa2mmHg=1/mmHg2Pa;

P1=30*mmHg2Pa;

dt=0.001;
t=[0:dt:50];
u=rect(t,10,10);

ytau=5; yamp=0.5*P0; ybas=P0;
y2tau=15; y2amp=1*C0; y2bas=C0;
y(1)=0;
y2(1)=0;

P=(ybas+y*yamp);

if (length(t)>1),
  dt=t(2)-t(1);
elseif (length(t)==1),
  dt=t;
else,
  dt=1;
end;

mu=0.004;
D=100e-6;
L=1e-2;

R=128*mu*L/(pi*(D^4));
qin=P/R;

V0=pi*((D/2)^2)*1e-2;
k=30; alpha=0.4;
F1p=0.7; V1p=((F1p+1)^alpha)-1; 
R1=R;
k1=(R/R1)*(F1p+1)/(exp(k*V1p)-1);
C(1)=0; V(1)=V0;
qout(1)=0;
for m=2:length(P),
  y(m)=y(m-1)+dt*( (1/ytau)*( u(m-1) - y(m-1) ));
  y2(m)=y2(m-1)+dt*( (1/y2tau)*( u(m-1) - y2(m-1) ));
  dPdt(m)=(P(m)-P(m-1))/dt;
  if (ctype==2),	% ad-hoc, not correct
    C(m)=y2bas+y2(m)*y2amp;
    V(m)=V0+C(m)*(P(m)-P0);
  elseif (ctype==1),	% exponential?
    C(m)=(V0/k)*(1/(P(m)-P0+k1*P0));
    V(m)=(V0/k)*log((1/k1)*(P(m)/P0-1)+1)+V0;
  else,			% constant
    C(m)=C0;
    V(m)=V0+C(m)*(P(m)-P0);
  end;
  qout(m)=qin(m)-dPdt(m)*C(m);
end;
C(1)=C(2); V(1)=V0;
qout(1)=qout(2);

  figure(1)
  subplot(231)
  plot(t,qin,t,qout)
  legend('Qin','Qout')
  subplot(232)
  plot(t,P)
  legend('P')
  subplot(233)
  plot(t,V),
  legend('V'),
  subplot(234)
  plot(V,P)
  xlabel('V'), ylabel('P'),
  subplot(235)
  plot(t,C)
  legend('C')
  subplot(236)
  plot(t,dPdt)
  legend('dPdt')

  figure(2)
  plot(t,P/P0-1,t,(V/V0-1),t,qin/qin(1)-1,t,qout/qout(1)-1)
  axis('tight'), grid,
  legend('rP','rV','rQin','rQout')
  title(sprintf('rP= %f, rV= %f (%f), rQ= %f %f  pV= %f %f',max(P/P0),max(V/V0),max(qin/qin(1)),max(qout/qout(1)),max(qin/qin(1))^0.4,max(qout/qout(1))^0.4))

