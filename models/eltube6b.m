
clear all

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
Pin0=60*mmHg2Pa;        % units: N/m2
Pout0=25*mmHg2Pa;        % units: N/m2

dt=2e-1; T=50;
dx=2e-4; L=1e-2;
x=[0:dx:L]';
t=[0:dt:T]';

u=rect(t,8,14);

% Generate some temporal dynamics
Y1(1)=0;
Y1tau=2;
Y1amp=0.5; Y1amp2=0.25;
for m=1:length(t),
  if (m<length(t)),
    Y1(m+1)= Y1(m) + dt*( (1/Y1tau)*u(m) - (1/Y1tau)*Y1(m)  );
  end;
end;

% Flow and Pressure dynamic (linear) at the INLET
Fin=Fin0*(1+Y1amp*Y1');
Pin=Pin0*(1+Y1amp2*Y1');
pmaxi=find(Pin==max(Pin));

for n=1:length(t),
  q0=Fin(n);
  p(1,n)=Pin(n);
  a(1,n)=a0/(1-p(1,n)*(a0/(E0*h0)));
  for m=1:length(x)-1,
    vv(m)=pi*a(m,n)*a(m,n)*dx;
    dpdv(m)=8e24*vv(m)+((1e19*(vv(m)-1e-12))^2);
    term1=-8*visc0*q0/(pi*a(m,n)*a(m,n)*a(m,n)*a(m,n));
    term2=1/(2*pi*a(m,n)*dx);
    term3=1/(dpdv(m));
    a(m+1,n)=a(m)+dx*term1*term2*term3;
    p(m+1,n)=E0*h0*((1/a0)-(1/a(m+1,n)));
  end;
  vv(m+1)=pi*a(m+1)*a(m+1)*dx;
  V(n)=sum(vv);
end;

clf
subplot(211)
plot(x,a(:,1),x,a(:,pmaxi))
subplot(223)
plot(t,Fin)
subplot(224)
plot(V./V(1),Fin./Fin(1))

