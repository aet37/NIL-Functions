
clear all

ctype=2;
doplots=0;

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

Pi=40*mmHg2Pa;
Po=5*mmHg2Pa;
P0=0*mmHg2Pa;

P1=30*mmHg2Pa;
P2=15*mmHg2Pa;
P3=7.5*mmHg2Pa;

R0=128*mu*L/(pi*(D^4));
V1_0=pi*((D/2)^2)*1e-2;
V2_0=V1_0;
V3_0=V1_0;
% V2/V1=(D2/D1)^2.0=(R1/R2)^0.5
q0=(cHb0/1000)*V3_0*(m32ml/1000);

Ra=0.5*R0;
R1eq=1.5*Ra;
R2eq=0.5*R1eq;
R3=R2eq/3;


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
C1_0=(V1p*V1_0)/(F1p*P2);
C2_0=0.5*C1_0;


Pm1(1)=P1;
Pm2(1)=P2;
Pm3(1)=P3;
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
  Va(m) = (0.5*V1_0 + pi*((D*(1+yamp*y(m))/2)^2)*(L/2));

  [Pm1(m+1),C1(m),V1(m),Q1in(m),Q1out(m)]=complUnit([Pi Pm1(m) Pm2(m)],P0,[Ra(m) R1eq],[1 C1_0],dt,V1_0,Pm1(1));
  [Pm2(m+1),C2(m),V2(m),Q2in(m),Q2out(m)]=complUnit([Pm1(m) Pm2(m) Pm3(m)],P0,[R1eq R2eq],[1 C2_0],dt,V2_0,Pm2(1));
  [Pm3(m+1),C3(m),V3(m),Q3in(m),Q3out(m)]=complUnit([Pm2(m) Pm3(m) Po],P0,[R2eq R3],[ctype k k1 k2],dt,V3_0,Pm3);


  E(m) = 1 - (1-E0)^(Q3in(1)/Q3in(m));

  q(m+1) = q(m) + dt*( q0*(E(m)/E0)*(Q3in(m)/V3(1)) - q(m)*(Q3out(m)/V3(m)) );

end;

Pm1=Pm1(1:end-1);
Pm2=Pm2(1:end-1);
Pm3=Pm3(1:end-1);
q=q(1:end-1);

%Qin=N*Qin;
%Qout=N*Qout;
%V=N*V;

kk=1;
S = 1 - kk*(q/q(1));

if (doplots),
  figure(1)
  subplot(231)
  plot(t,[Q1in' Q2in' Q3in'],t,[Q1out' Q2out' Q3out'])
  legend('Qin','Qout')
  subplot(232)
  plot(t,[Pm1' Pm2' Pm3']*Pa2mmHg)
  legend('Pm')
  subplot(233)
  plot(t,[V1' V2' V3']*m32ml),
  legend('V'),
  subplot(234)
  plot(V1/V1(1),(Pm1-P0)/(Pm1(1)-P0),V2/V2(1),(Pm2-P0)/(Pm2(1)-P0),V3/V3(1),(Pm3-P0)/(Pm3(1)-P0))
  xlabel('rV'), ylabel('rPm'),
  subplot(235)
  plot(t,[C1' C2' C3'])
  legend('C')
  subplot(236)
  plot(t(2:end),[diff(Pm1)' diff(Pm2)' diff(Pm3)'])
  legend('dPdt')
  
  figure(2)
  subplot(311)
  plot(t,(Pm1/Pm1(1)-1),t,(V1/V1(1)-1),t,(Q1in/Q1in(1)-1),t,(Q1out/Q1out(1)-1))
  axis('tight'), grid,
  legend('rP','rV','rQin','rQout')
  title(sprintf('rPm1= %f, rV1= %f (%f), rQ1= %f %f',max(Pm1/Pm1(1)),max(V1/V1(1)),max(Q1in/Q1in(1))^alpha,max(Q1in/Q1in(1)),max(Q1out/Q1out(1))))
  subplot(312)
  plot(t,(Pm2/Pm2(1)-1),t,(V2/V2(1)-1),t,(Q2in/Q2in(1)-1),t,(Q2out/Q2out(1)-1))
  axis('tight'), grid,
  legend('rP','rV','rQin','rQout')
  title(sprintf('rPm2= %f, rV2= %f (%f), rQ2= %f %f',max(Pm2/Pm2(1)),max(V2/V2(1)),max(Q2in/Q2in(1))^alpha,max(Q2in/Q2in(1)),max(Q2out/Q2out(1))))
  subplot(313)
  plot(t,(Pm3/Pm3(1)-1),t,(V3/V3(1)-1),t,(Q3in/Q3in(1)-1),t,(Q3out/Q3out(1)-1))
  axis('tight'), grid,
  legend('rP','rV','rQin','rQout')
  title(sprintf('rPm3= %f, rV3= %f (%f), rQ3= %f %f',max(Pm3/Pm3(1)),max(V3/V3(1)),max(Q3in/Q3in(1))^alpha,max(Q3in/Q3in(1)),max(Q3out/Q3out(1))))
end;

