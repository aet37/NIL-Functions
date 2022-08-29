
clear all

mmHg2Pa=133.32;
Pa2mmHg=1/133.32;

mu=0.004;          % Pa s

Pi=65*mmHg2Pa;
Po=35*mmHg2Pa;
L=1e-2;
R0=100e-6;
RR0=8*mu*L/(pi*R0^4);

Yamp=0.4; Ytau=5;
Y(1)=0;

V0=pi*R0*R0*L;
k=25; alpha=0.4;
F1p=0.8; V1p=((F1p+1)^alpha)-1;
%F1p=RR0/(RR0+Yamp*RR0)-1; V1p=((F1p+1)^alpha)-1;
RRp=RR0;
k1=(RRp/RR0)*(F1p+1)/(exp(k*V1p)-1);

Pm1(1)=45*mmHg2Pa;
Pm2(1)=20*mmHg2Pa;
Pm3(1)=10*mmHg2Pa;
V(1)=V0;
C0=2e-13;

dt=2e-3;
t=[0:dt:100];
U=rect(t,30,20);

for m=1:length(t)-1,

  Y(m+1)=Y(m)+dt*(1/Ytau)*(U(m)-Y(m));

  R(m)=R0*(1+Yamp*Y(m));
  Va(m)=0.5*(pi*R(m)*R(m)*L-V0);
  RR(m)=(8*mu*L)/(pi*R(m)*R(m)*R(m)*R(m));
  Qi(m)=(Pi-Pm1(m))/(0.5*RR(m));
  %if m>1,
  %  RR1(m)=RR0*((V0/V(m-1))^2));
  %else,
     RR1(m)=RR0;
  %end;
  Q1(m)=(Pm1(m)-Pm2(m))/(0.5*RR1(m));
  if (m==1),
    C1(m)=C0;
    V1(m)=V0;
  else,
    C1(m)=C0;
    V1(m)=V0+C1(m)*(Pm1(m)-Pm1(m-1))/dt;
  end;
  Pm1(m+1)=Pm1(m)+dt*((Qi(m)-Q1(m))/C1(m));

  RR2(m)=RR0;
  Q2(m)=(Pm2(m)-Pm3(m))/(0.5*RR2(m));
  if (m==1),
    C2(m)=C0;
    V2(m)=V0;
  else,
    C2(m)=C0;
    V2(m)=V0+C2(m)*(Pm2(m)-Pm2(m-1))/dt;
  end;
  Pm2(m+1)=Pm2(m)+dt*((Q1(m)-Q2(m))/C2(m));

  RR3(m)=RR0;
  Q3(m)=(Pm3(m)-Po)/(0.5*RR3(m));
  C3(m)=(V0/k)*(1/(Pm3(m)-Pm3(1)+k1*Pm3(1)));
  V3(m)=(V0/k)*log((1/k1)*(Pm3(m)/Pm3(1)-1)+1)+V0;
  Pm3(m+1)=Pm3(m)+dt*((Q3(m)-Q2(m))/C2(m));

end;

R(end+1)=R(end);
Va(end+1)=Va(end);
RR(end+1)=RR(end);
C1(end+1)=C1(end);
Qi(end+1)=Qi(end);

RR1(end+1)=RR1(end);
Q1(end+1)=Q1(end);
C1(end+1)=C1(end);
V1(end+1)=V1(end);

RR2(end+1)=RR2(end);
Q2(end+1)=Q2(end);
C2(end+1)=C2(end);
V2(end+1)=V2(end);

RR3(end+1)=RR3(end);
Q3(end+1)=Q3(end);
C3(end+1)=C3(end);
V3(end+1)=V3(end);

subplot(231)
plot(t,RR,t,RR1,t,RR2,t,RR3)
legend('RR','RR1','RR2','RR3')
xlabel('Time'), ylabel('Resistance'),
axis('tight'), grid('on'),
subplot(232)
plot(t,Pi*Pa2mmHg*ones(size(t)),t,Pm1*Pa2mmHg,t,Pm2*Pa2mmHg,t,Pm3*Pa2mmHg,t,Po*Pa2mmHg*ones(size(t)))
legend('Pi','Pm1','Pm2','Pm3','Po')
xlabel('Time'), ylabel('Pressure'),
axis('tight'), grid('on'),
subplot(233)
plot(t,Qi,t,Q1,t,Q2,t,Q3)
legend('Qi','Q1','Q2','Q3')
xlabel('Time'), ylabel('Flow'),
axis('tight'), grid('on'),
subplot(234)
plot(t,V1,t,V2,t,V3)
legend('V1','V2','V3')
xlabel('Time'), ylabel('Volume'),
axis('tight'), grid('on'),
subplot(235)
plot(V1,Pm1,V2,Pm2,V3,Pm3)
legend('C1','C2','C3')
xlabel('Volume'), ylabel('Pressure'),
axis('tight'), grid('on'),
subplot(236)
plot(t,Qi/Qi(1),t,Q1/Q1(1),t,Q2/Q2(1),t,Q3/Q3(1),t,V1/V1(1),t,V2/V2(1),t,V3/V3(1))
legend('Qi/Qi_0','Q1/Q1_0','Q2/Q2_0','Q3/Q3_0','V1/V1_0','V2/V2_0','V3/V3_0')
xlabel('Time'), ylabel('Normalized Flow/Vol'),
axis('tight'), grid('on'),

