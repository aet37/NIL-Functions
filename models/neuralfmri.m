
clear all

% This work is based on Buxton's work
% presented on SMR2001 (Glasgow) Abstract# 1164

% Simulation timing
h=2e-2;
t=[0:h:100];
t=t(:);

% Simulation parameters
E0=0;
I0=0;
tauE=0.06;
tauI=0.5;
a=20;
nvnum=1;
nvden=[1 .4];
%nvnum=[1 .2];
%nvden=[1 1 .24];
Fin0=1;
V0=1;
q0=1;
EE0=0.4;

% Input stimulus
S=rect(t,10,15);

% Neural response set-up -- as observed by local field potentials?
E(1)=E0;
I(1)=I0;
R(1)=(E0>=I0)*(E0-I0);
for m=2:length(t),
  E(m) = E(m-1) + h*( (1/tauE)*( S(m-1)-E(m-1) )  );
  I(m) = I(m-1) + h*( (1/tauI)*( a*R(m-1)-I(m-1) ) );
  R(m) = (E(m)>=I(m))*( E(m) - I(m) );
end;

% Neuro-vascular response function
unv=rect(t,4,2+h);
NV=mysol(nvnum,nvden,unv,t);
%NV=gammafun(t,0,0.55,8.61.0,1);
NV=NV/max(NV);

% CBF response = R(t) ** NV(t)
Fin=conv(R,NV);
Fin=Fin(1:length(t));
Fin=Fin0+Fin;

% Balloon model 
V(1)=V0;
q(1)=q0;
Fout(1)=V(1)^(2.5);
ttau=1;
EE(1)=EE0-(1/3)*Fin(1);
for m=2:length(t),
  q(m) = q(m-1) + h*( (1/ttau)*(Fin(m-1)*EE(m-1) - Fout(m-1)*q(m-1)/V(m-1)) );
  V(m) = V(m-1) + h*( (1/ttau)*(Fin(m-1)-Fout(m-1))  );
  Fout(m) = V(m)^(2.5);
  EE(m)=EE0-(1/3)*Fin(m);
end;


figure(1)
subplot(311)
plot(t,E,t,I,t,S,'r')
xlabel('Time'), ylabel('Amplitude')
legend('E(t)','I(t)','S(t)') 
subplot(312)
plot(t,R,t,S,'r')
xlabel('Time'), ylabel('Amplitude')
legend('R(t)','S(t)')
subplot(313)
plot(t,NV)
xlabel('Time'), ylabel('Amplitude')
legend('NV(t)')
figure(2)
subplot(211)
plot(t,Fin,t,Fout,t,EE)
xlabel('Time'), ylabel('Amplitude')
legend('Fin(t)','Fout(t)','E(t)')
subplot(212)
plot(t,V,t,q)
xlabel('Time'), ylabel('Amplitude')
legend('V(t)','q(t)')

