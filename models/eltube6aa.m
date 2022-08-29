
clear all

dt=2e-1; T=50;
dx=2e-4; L=1e-2;
x=[0:dx:L]';
t=[0:dt:T]';

u=rect(t,8,14);

% Vessel/Tube properties
v0=0.5e-2;               % units: m/s
a0=100e-6;               % units: m
E0=3.5e5;                % units: N/m2
h0=0.15*a0;               % units: m

% Blood/Fluid properties
rho0=1e3;                % units: kg/m3
visc0=0.004;            % units: Ns/m2
Fin0=v0*pi*a0*a0;        % units: m3/s (x10^6 for cm3/2)

% Environment properties
mmHg2Pa=133.322;
Pa2mmHg=1/133.322;
Pin0=55*mmHg2Pa;        % units: N/m2
Pout0=30*mmHg2Pa;        % units: N/m2

% Generate some temporal dynamics
Y1(1)=0;
Y1tau=2;
Y1amp=0.5; Y1amp2=0.25;
for m=1:length(t),
  if (m<length(t)),
    Y1(m+1)= Y1(m) + dt*( (1/Y1tau)*u(m) - (1/Y1tau)*Y1(m)  );
  end;
end;

Fin=Fin0*(1+Y1amp*Y1');
Pin=Pin0*(1+Y1amp2*Y1');
pmaxi=find(Pin==max(Pin));

for n=1:length(t),
  [v(n),p(:,n),a(:,n)]=eltube6a(x,Pin(n),Fin(n),[a0 h0 E0],[rho0 visc0]);
end;

subplot(211)
plot(t,v./v(1),t,Fin./Fin(1))
subplot(212)
plot(v./v(1),Fin./Fin(1))

