
clear all
plot_flag=1;

% assume we know:  Rin, Rout, Qdotin, Pin (?)
% want to know:  Qdotout, Pout, V

Pa2mmHg = 1/133.322;
mmHg2Pa = 133.322;

Lc = 1e-2;		% units: m
visc = 0.004;		% units: Ns/m2

a0_in = 150e-6;		% units: m
L_in = 1e-2;		% units: m

v0_in = 5e-2;		% units: m/s

a0_out = 100e-6;	% units: m
L_out = 1e-2;		% units: m

tt = Lc/v0_in;		% units: s

% assume pressure is a faster version of the flow response
dt=1e-2;		% units: s
t=[0:dt:100];
u=rect(t,5,10);
ud=rect(t,5,10+tt);

% Calculate Pin and Qdotin using first-order dynamics
Y1amp=0.5; Y1tau=2;
Y2amp=0.5; Y2tau=2;
Y3amp=0.5; Y3tau=2;
Y4amp=0.5; Y4tau=2;
Y1(1)=0;
Y2(1)=0;
Y3(1)=0;
Y4(1)=0;
for m=2:length(t),
  Y1(m) = Y1(m-1) + dt*( (1/Y1tau)*u(m-1) - (1/Y1tau)*Y1(m-1) );
  Y2(m) = Y2(m-1) + dt*( (1/Y2tau)*u(m-1) - (1/Y2tau)*Y2(m-1) );
  Y3(m) = Y3(m-1) + dt*( (1/Y3tau)*u(m-1) - (1/Y3tau)*Y3(m-1) );
  Y4(m) = Y4(m-1) + dt*( (1/Y4tau)*ud(m-1) - (1/Y4tau)*Y4(m-1) );
end;

Rin = (8*visc*L_in/(pi*a0_in*a0_in*a0_in*a0_in))*(1-Y3amp*Y3);
Rout = (8*visc*L_out/(pi*a0_out*a0_out*a0_out*a0_out))*(1-Y4amp*Y4);

Pin = 50*mmHg2Pa*(1+Y1amp*Y1);

Qdotin = pi*a0_in*a0_in*v0_in*(1+Y2amp*Y2);

% Calculate the pressure of the compartment
Pc = Pin - Qdotin.*Rin;

% Calculate the volume of the compartment from the Pressure inside
% assume linear relationship for now
% maybe there should be some delay here or slow behavior
X=([35 42 49 56 63 70]+9)*mmHg2Pa;
Y=[.0 .60 .87 .97 0.99 1.0]*3e-10+2.2e-9;
%Y=[.0 .20 .40 .60 .80 1.0]*3e-10+2.2e-9;
%X=([35 42 49 56 63 70]+3)*mmHg2Pa;
%Y=[.0 .05 .15 .85 .95 1.0]*5e-10+2.2e-9;
%Y=[.0 .05 .10 .20 0.45 1.0]*3e-10+2.2e-9;
V=polyval(polyfit(X,Y,5),Pc);

% Calculate Qdotout
for m=2:length(t),
  Qdotout(m) = Qdotin(m) - (1/dt)*(V(m)-V(m-1));
end;
Qdotout(1)=Qdotout(2);

% Calculate Pout
Pout = Pc - Qdotout.*Rout;

if (plot_flag),
  figure(1)
  subplot(311)
  plot(t,Pin*Pa2mmHg)
  xlabel('Time'), ylabel('Pressure IN')
  subplot(312)
  plot(t,Qdotin)
  xlabel('Time'), ylabel('Flow IN')
  subplot(325)
  plot(Pc*Pa2mmHg,V,X*Pa2mmHg,Y,'x')
  xlabel('Pressure'), ylabel('Volume')
  subplot(326)
  plot(t,1-(Qdotout./V))
  figure(2)
  subplot(311)
  plot(t,Pin*Pa2mmHg,t,Pout*Pa2mmHg,t,Pc*Pa2mmHg)
  xlabel('Time'), ylabel('Pressure')
  subplot(312)
  plot(t,Qdotin,t,Qdotout)
  xlabel('Time'), ylabel('Flow')
  subplot(325)
  plot(t,V)
  xlabel('Time'), ylabel('Volume')
  subplot(326)
  plot(V./V(1),Qdotin./Qdotin(1))
  xlabel('V/V_0'), ylabel('Qin/Qin_0')
end;

