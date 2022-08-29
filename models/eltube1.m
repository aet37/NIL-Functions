
% Script for the description of a...
% Vessel as a rigid fluid conduit and as an elastic fluid conduit

% Vessel/Tube properties
a0=100e-6;              % units: m
E=1e4;                  % units: N/m2
h=0.2*a0;               % units: m

% Blood/Fluid properties
visc=0.004;             % units: Ns/m2
Fin=2e-10;              % units: m3/s (x10^6 for cm3/2)
Fout=1e-10;             % units: m3/s

% Environment properties
Pin0=40*133.322;        % units: N/m2
Pinx=5*133.322;         % units: N/m2
Pout=0*133.322;         % units: N/m2

x=100e-6*[0:1:1000];    % units: m
dx=x(2)-x(1);

dPin=Pin0-Pinx;

Prigid=x*8*visc*Fin/(pi*a0*a0*a0*a0);
Pinx_rigid=Pin0-Prigid;

a_defor=1-a0*(Pinx_rigid-Pin0)/(E*h);
a_elas=a0./a_defor;

V=sum(pi*a_elas.*a_elas*dx);

Pelas=8*visc*Fin*cumsum(dx./(a_elas.*a_elas.*a_elas.*a_elas))/pi;
Pinx_elas=Pin0-Pelas;

a_defor2=1-a0*(Pinx_elas-Pin0)/(E*h);
a_elas2=a0./a_defor2;

figure(1)
subplot(211)
plot(x,Pinx_rigid)
ylabel('dP (a)')
xlabel('x (m)')
subplot(212)
plot(x,a_elas)
ylabel('a (m)')
xlabel('x (m)')

% A fundamental problem with this approach is that with
% distance in the vasculature, the flow changes, the Elasticity
% changes, the diameter of the tube and wall changes also,
% all of which change with distance

