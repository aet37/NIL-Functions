
clear all

mmHg2Pa=133.32*1e-3;
Pa2mmHg=1/133.32*1e+3;

mu=0.004*1e-3;          % Pa s

Pi=65*mmHg2Pa;
Po=35*mmHg2Pa;
L=1e-2*1e+3;
R0=100e-6*1e+3;
RR0=8*mu*L/(pi*R0^4);

Yamp=0.4; Ytau=5;
Y(1)=0;

V0=pi*R0*R0*L;
Pm(1)=mean([Pi Po]);
V(1)=V0;
C0=2;

dt=5e-3;
t=[0:dt:50];
U=rect(t,30,16);

for m=1:length(t)-1,

  %Y(m+1)=Y(m)+dt*(1/Ytau)*(U(m)-Y(m));
  Y(m)=U(m);
  R(m)=R0*(1+Yamp*Y(m));

  Va(m)=0.5*(pi*R(m)*R(m)*L-V0);

  RR(m)=(8*mu*L)/(pi*R(m)*R(m)*R(m)*R(m));

  Qi(m)=(Pi-Pm(m))/(0.5*RR(m));
  Qo(m)=(Pm(m)-Po)/(0.5*RR0);
  
  C(m)=(1/C0)*(V0/Pm(1)); 
  V(m)=V0+(V0/C(m))*((Pm(m)/Pm(1))-1);
 
  Pm(m+1)=Pm(m)+dt*(1/C(m))*(Qi(m)-Qo(m));

end;

R(end+1)=R(end);
Va(end+1)=Va(end);
RR(end+1)=RR(end);
C(end+1)=C(end);
V(end+1)=V(end);
Qi(end+1)=Qi(end);
Qo(end+1)=Qo(end);

subplot(231)
plot(t,RR)
legend('RR')
xlabel('Time'), ylabel('Resistance'),
axis('tight'), grid('on'),
subplot(232)
plot(t,Pi*Pa2mmHg*ones(size(t)),t,Pm*Pa2mmHg,t,Po*Pa2mmHg*ones(size(t)))
legend('Pi','Pm','Po')
xlabel('Time'), ylabel('Pressure'),
axis('tight'), grid('on'),
subplot(233)
plot(t,Qi,t,Qo)
legend('Qi','Qo')
xlabel('Time'), ylabel('Flow'),
axis('tight'), grid('on'),
subplot(234)
plot(t,V)
legend('V')
xlabel('Time'), ylabel('Volume'),
axis('tight'), grid('on'),
subplot(235)
plot(V,Pm)
legend('C')
xlabel('Volume'), ylabel('Pressure'),
axis('tight'), grid('on'),
subplot(236)
plot(t,Qi/Qi(1),t,Qo/Qo(1),t,V/V(1))
legend('Qi/Qi_0','Qo/Qo_0','V/V_0')
xlabel('Time'), ylabel('Normalized Flow/Vol'),
axis('tight'), grid('on'),

