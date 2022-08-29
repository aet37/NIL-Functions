
%clear all

% Vessel/Tube properties
v0=0.5e-2;               % units: m/s
a0=100e-6;               % units: m
E0=3.5e5;                % units: N/m2
h0=0.15*a0;               % units: m

% Blood/Fluid properties
rho0=1e3;                % units: kg/m3
visc0=0.004;            % units: Ns/m2
Fin0=v0*pi*a0*a0;        % units: m3/s (x10^6 for cm3/2)
Fin0=40.0*Fin0;

% Environment properties
mmHg2Pa=133.322;
Pa2mmHg=1/133.322;
Pin0=55*mmHg2Pa;        % units: N/m2
Pout0=30*mmHg2Pa;        % units: N/m2

Pin0=1.25*Pin0;
Fin0=1.50*Fin0;

dt=2e-1;
dx=2e-4;
x=[0:dx:2e-2]';

% Design P vs. R curve
pp=[0 0.1 0.2 0.4 0.6 0.8 1];
aa=[0 0.34 0.60 0.77 0.90 0.95 1];
%aa=[0 0.40 0.55 0.80 0.92 0.97 1];
aai=[0:.01:1]; ppi=interp1(aa,pp,aai,'linear');
pm=50*mmHg2Pa; pb=25*mmHg2Pa;
am=40e-6; ab=110e-6;
oP=7;
cP=polyfit(am*aai+ab,pm*ppi+pb,oP);		% highest-to-zeroeth order
cA=polyfit(pm*ppi+pb,am*aai+ab,oP);
AA=am*aai+ab;
PP=polyval(cP,AA);

% Do the calculations for radius and pressure 
% using numerical differentiation (terrible with noise)
Fin=Fin0;
p(1)=Pin0;
a(1)=polyval(cA,p(1));
dpda(1)=0;
for m=2:length(x),
  dpda(m)=0;
  for nn=1:length(cP)-1,
    dpda(m)=dpda(m)+(oP-nn+1)*cP(nn)*(a(m-1).^(oP-nn));
  end;
  dadxterm=-8*visc0*Fin./(pi*(a(m-1).^4));
  a(m)=a(m-1)+dx*(dadxterm./dpda(m)); 
  p(m)=polyval(cP,a(m));
end;

% calculate volume
v=sum(pi*a.*a*dx);

% plot results
subplot(221)
plot(x,a)
xlabel('Distance'), ylabel('Radius')
subplot(222)
plot(x,dpda*Pa2mmHg)
xlabel('Distance'), ylabel('dP/dA')
subplot(223)
plot(x,p*Pa2mmHg)
xlabel('Distance'), ylabel('Pressure')
subplot(224)
plot(a,p*Pa2mmHg,AA,PP*Pa2mmHg)
xlabel('Radius'), ylabel('Pressure')
