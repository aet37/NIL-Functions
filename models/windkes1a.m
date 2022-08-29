
clear all

mmHg2Pa=133.32;
Pa2mmHg=1/133.32;

mu=0.004;

Pa0=100;
Paend1=90;
ra1=1e-2;
la1=4e-1;

Qa0=5*1e-3/60;

dt=0.1;
t=[0:dt:100];
dvddp=100000;

Pa1(1)=(Pa0-Paend1)*mmHg2Pa;
Ra1=8*mu*la1/(pi*ra1*ra1*ra1*ra1);
Qa1=Pa1/Ra1;
Qa0=Qa1;
%Qc(1)=0;

Y(1)=0; Yamp=0.15; Ytau=2;
u=rect(t,10,20);
for m=2:length(t),
  Y(m) = Y(m-1) + dt*( (1/Ytau)*u(m-1) - (1/Ytau)*Y(m-1) );
  YY(m-1)=1+Yamp*Y(m-1);
  ra1a(m-1)=ra1*YY(m-1);
  Ra1a(m-1)=8*mu*la1/(pi*ra1a(m-1)*ra1a(m-1)*ra1a(m-1)*ra1a(m-1));
  %Qa0a(m-1)=Pa1(m-1)/Ra1a(m-1);
  Qa0a(m-1)=Qa0*YY(m-1);
  Qa1(m-1) = Pa1(m-1)/Ra1;
  Qc1(m-1) = Qa0a(m-1) - Qa1(m-1);
  Pa1(m) = Pa1(m-1) + dt*dvddp*(Qa0a(m-1) - Qa1(m-1));
  Qa1o(m-1)=Qa1(m-1)+Qc1(m-1);
  Pa0(m) = Pa0(1);
  Paend1(m) = Pa0(m)-Pa1(m)*Pa2mmHg;
end;
ra1a(m)=ra1a(m-1);
Qa0a(m)=Qa0a(m-1);
Qa1(m)=Qa1(m-1);
Qa1o(m)=Qa1o(m-1);
V = dvddp*Pa1 + pi*ra1*ra1*la1;

subplot(411)
plot(t,Pa0,t,Paend1)
xlabel('Time'), ylabel('Pressure')
subplot(412)
%plot(t,Qa0a*60/1e-3,t,Qa1*60/1e-3)
plot(t,Qa0a*60/1e-3,t,Qa1*60/1e-3,t,Qa1o*60/1e-3)
xlabel('Time'), ylabel('Flow')
subplot(413)
plot(t,V)
xlabel('Time'), ylabel('Volume')
subplot(414)
plot(V./V(1),Qa0a./Qa0a(1))

