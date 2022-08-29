function [v,p,a,dpda]=eltube6a(x,Pin0,Fin0,tubeparms,fluidparms,parms)
% Usage ... [v,p,a,dpda]=eltube6a(x,Pin0,Fin0,tubeparms,fluidparms,parms)
% 
% tubeparms= [a0 h0 E0]
% fluidparms= [v0 rho0 visc0]

% Vessel/Tube properties
if (exist('tubeparms')),
  a0=tubeparms(1);
  h0=tubeparms(2); 
  E0=tubeparms(3);
else,
  % Defaults
  a0=100e-6;               % units: m
  E0=3.5e5;                % units: N/m2
  h0=0.15*a0;              % units: m
end;

% Blood/Fluid properties
if (exist('fluidparms')),
  rho0=fluidparms(1);
  visc0=fluidparms(2);
else,
  % Defaults
  rho0=1e3;                % units: kg/m3
  visc0=0.004;            % units: Ns/m2
end;

% Environment properties
mmHg2Pa=133.322;
Pa2mmHg=1/133.322;
Pin0=55*mmHg2Pa;        % units: N/m2
Pout0=30*mmHg2Pa;        % units: N/m2

dx=x(2)-x(1);
L=x(end)-x(1);
%x=[0:dx:2e-2]';

% Design P vs. R curve
pp=[0 0.1 0.2 0.4 0.6 0.8 1];
aa=[0 0.34 0.60 0.77 0.90 0.95 1];
aai=[0:.01:1]; ppi=interp1(aa,pp,aai,'linear');
pm=30*mmHg2Pa; pb=30*mmHg2Pa;
am=20e-6; ab=110e-6;
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

p=p(:);
a=a(:);

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

