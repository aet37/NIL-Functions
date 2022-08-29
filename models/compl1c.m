
clear all

ctype=2;
doplots=1;

mmHg2Pa=133.32;
Pa2mmHg=1/mmHg2Pa;
m32ml=1e6;

mu=0.004;
cHb0=23.1;
E0=0.4;

D=100e-6;
L=1e-2;
N=1e3;

alpha=0.4;

P1=30*mmHg2Pa;
P2=20*mmHg2Pa;
P3=10*mmHg2Pa;
P0=0*mmHg2Pa;

R0=128*mu*L/(pi*(D^4));
V0=pi*((D/2)^2)*1e-2;
q0=(cHb0/1000)*V0*(m32ml/1000);

dt=0.005;
t=[0:dt:50];
tlen=length(t);

%u=rect(t,10,10);
u=mytrapezoid(t,10,10,2);

F1p=0.7; V1p=((F1p+1)^alpha)-1; 
R1=R0;
k=1; k1=(R0/R1)*(F1p+1)/(exp(k*V1p)-1);
k=30; k1=0.01;
k2=1.36e-17;
C0=(V1p*V0)/(F1p*P2);


Pm(1)=P2;
q(1)=q0;

ytau=5; yamp=+0.40; y(1)=0;
y2tau=40; y2amp=-2.0; y2(1)=0;
xflag=0;

for m=1:length(t),

  if (m>1),
    y(m)=y(m-1)+dt*( (1/ytau)*( u(m-1) - y(m-1) ));
    y2(m)=y2(m-1)+dt*( (1/y2tau)*( u(m-1) - y2(m-1) ));
  end;

  Ra(m) = 0.5*R0*((1+yamp*y(m))^(-4));
  Va(m) = (0.5*V0 + pi*((D*(1+yamp*y(m))/2)^2)*(L/2));

  [Pm(m+1),C(m),V(m),Qin(m),Qout(m),dPdt(m)]=complUnit([P1 Pm(m) P3],P0,[Ra(m) 0.5*R0],[ctype k k1 k2],dt,V0,Pm);


  E(m) = 1 - (1-E0)^(Qin(1)/Qin(m));

  q(m+1) = q(m) + dt*( q0*(E(m)/E0)*(Qin(m)/V(1)) - q(m)*(Qout(m)/V(m)) );

end;

Pm=Pm(1:end-1);
PPm=Pm-P0;
q=q(1:end-1);

%Qin=N*Qin;
%Qout=N*Qout;
%V=N*V;

kk=1;
S = 1 - kk*(q/q(1));

if (doplots),
  figure(1)
  subplot(231)
  plot(t,Qin,t,Qout)
  legend('Qin','Qout')
  subplot(232)
  plot(t,Pm*Pa2mmHg)
  legend('Pm')
  subplot(233)
  plot(t,V*m32ml),
  legend('V'),
  subplot(234)
  plot(V/V(1),PPm/PPm(1))
  xlabel('rV'), ylabel('rPm'),
  subplot(235)
  plot(t,C)
  legend('C')
  subplot(236)
  plot(t,dPdt)
  legend('dPdt')
  
  figure(2)
  plot(t,(PPm/PPm(1)-1),t,(V/V(1)-1),t,(Qin/Qin(1)-1),t,(Qout/Qout(1)-1))
  axis('tight'), grid,
  legend('rP','rV','rQin','rQout')
  title(sprintf('rPm= %f, rV= %f (%f), rQ= %f %f',max(PPm/PPm(1)),max(V/V(1)),max(Qin/Qin(1))^alpha,max(Qin/Qin(1)),max(Qout/Qout(1))))
end;

