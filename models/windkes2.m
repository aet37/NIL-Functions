
clear all
plot_flag=1;

% assume we know:  Rin, Rout, Qdotin, Pin (?)
% want to know:  Qdotout, Pout, V

Pa2mmHg = 1/133.322;
mmHg2Pa = 133.322;

visc = 0.004;		% units: Ns/m2

r_in = 150e-6;		% units: m
L_in = 1e-2;		% units: m
v0_in = 5e-2;		% units: m/s

r_out = 100e-6;		% units: m
L_out = 1e-2;		% units: m

Rin = 8*visc*L_in/(pi*r_in*r_in*r_in*r_in);
Rout = 8*visc*L_out/(pi*r_out*r_out*r_out*r_out);

% assume pressure is a faster version of the flow response
dt=1e-2;		% units: s
t=[0:dt:100];
u=rect(t,5,10);

% Calculate Pin and Qdotin using first-order dynamics
Y1amp=0.5; Y1tau=2;
Y2amp=0.5; Y2tau=2;
Y1(1)=0;
Y2(1)=0;
for m=2:length(t),
  Y1(m) = Y1(m-1) + dt*( (1/Y1tau)*u(m-1) - (1/Y1tau)*Y1(m-1) );
  Y2(m) = Y2(m-1) + dt*( (1/Y2tau)*u(m-1) - (1/Y2tau)*Y2(m-1) );
end;
Pin = 50*mmHg2Pa*(1+Y1amp*Y1);
Qdotin = pi*r_in*r_in*v0_in*(1+Y2amp*Y2);

% Calculate the pressure of the compartment
Pc = Pin - Qdotin*Rin;

% Calculate the volume of the compartment from the Pressure inside
% assume linear relationship for now
% maybe there should be some delay here or slow behavior
X=([35 40 45 50 55 60]+10)*mmHg2Pa;
Y=[.0 .70 .87 .97 0.99 1.0]*3e-10+2.2e-9;
V=polyval(polyfit(X,Y,4),Pc);
%Cp = 5e-9;
%V = 0 + (27e3/2e8)*Pc + (-1.8/2e8)*Pc.*Pc;
%V = Cp*V;

% Calculate Qdotout
for m=2:length(t),
  Qdotout(m) = Qdotin(m) - (1/dt)*(V(m)-V(m-1));
end;
Qdotout(1)=Qdotout(2);

% Calculate Pout
Pout = Pc - Qdotout*Rout;

if (plot_flag),
  figure(1)
  subplot(311)
  plot(t,Pin*Pa2mmHg)
  xlabel('Time'), ylabel('Pressure IN')
  subplot(312)
  plot(t,Qdotin)
  xlabel('Time'), ylabel('Flow IN')
  subplot(313)
  plot(Pc*Pa2mmHg,V,X*Pa2mmHg,Y,'x')
  xlabel('Pressure'), ylabel('Volume')
  figure(2)
  subplot(311)
  plot(t,Pin*Pa2mmHg,t,Pout*Pa2mmHg,t,Pc*Pa2mmHg)
  xlabel('Time'), ylabel('Pressure')
  subplot(312)
  plot(t,Qdotin,t,Qdotout)
  xlabel('Time'), ylabel('Flow')
  subplot(313)
  plot(t,V)
  xlabel('Time'), ylabel('Volume')
end;

