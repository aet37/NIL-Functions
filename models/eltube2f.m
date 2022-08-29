function [dS,V,Fin,P12rigid,E,a_elas]=eltube2f(u,ue,t,x,parms)
% Usage ... [dS,Vt,Fin,dPin_rigid,Et,a_elas]=eltube2f(u,ue,t,x,parms)

% Script for the description of a...
% Vessel as a rigid fluid conduit and as an elastic fluid conduit

if nargin<5, parms=[]; end;

if length(parms)<20, k4=0.0035; else, k4=parms(20); end;
if length(parms)<19, k3=1.0; else, k3=parms(19); end;
if length(parms)<18, k2=1.0; else, k2=parms(18); end;
if length(parms)<17, k1=16; else, k1=parms(17); end;
if length(parms)<16, Pout=10*133.322; else, Pout=parms(16); end;
if length(parms)<15, Pinx=10*133.322; else, Pinx=parms(15); end;
if length(parms)<14, alphaamp=0.0; else, alphaamp=parms(14); end;
if length(parms)<13, alphabase=1.0; else, alphabase=parms(13); end;
if length(parms)<12, Etau=9.0; else, Etau=parms(12); end;
if length(parms)<11, Ftau=3.0; else, Ftau=parms(11); end;
if length(parms)<10, v0=0.5e-2; else, v0=parms(10); end;
if length(parms)<9,  rho0=1e3; else, rho0=parms(9); end;
if length(parms)<8,  visc0=0.004; else, visc0=parms(8); end;
if length(parms)<6,  E0=2.0e4; else, E0=parms(6); end;
if length(parms)<5,  a0=100e-6; else, a0=parms(5); end;
if length(parms)<7,  h0=0.15*a0; else, h0=parms(7); end; 
if length(parms)<4,  Etamp=-0.25; else, Etamp=parms(4); end;
if length(parms)<3,  Et(1)=0; else, Et(1)=parms(3); end;
if length(parms)<2,  Ramp=0.5; else, Ramp=parms(2); end;
if length(parms)<1,  Rin(1)=0; else, Rin(1)=parms(1); end;

Fin0=v0*pi*a0*a0;
Re=rho0*v0*2*a0/visc0;

disp(sprintf('Rin(1)= %f  Ramp= %f',Rin(1),Ramp));
disp(sprintf('Et(1)= %f   Etamp= %f',Et(1),Etamp));
disp(sprintf('a0= %f m  h0= %f m  E0= %f N/m2',a0,h0,E0));
disp(sprintf('visc0= %f  dens0= %f',visc0,rho0));
disp(sprintf('Fin0= %f m3/s',Fin0));
disp(sprintf('Ftau= %f s  Etau= %f s',Ftau,Etau));
disp(sprintf('Re= %f',Re)); 

if nargin<4, x=[0:a0:500*a0]; end;
if nargin<3, t=[0:length(u)-1]; end;

P20=Pinx;
P30=Pout;

dx=x(2)-x(1);
dt=t(2)-t(1);

onset1=0;
onset2=0;
Etmax=1.0;

% Time progression
for m=1:length(t),

  % Generate flow dynamics
  if (m<length(t)),
    Rin(m+1)= Rin(m) + dt*( (1/Ftau)*u(m) - (1/Ftau)*Rin(m)  );
  end;
  Fin(m)=Fin0*(Ramp*Rin(m)+1.0);
  Fout(m)=Fin(m);

  % Generate elasticity dynamics
  if (ue(m)>0)&(onset1==0), onset1=1; end;
  if (ue(m)==0)&(onset1==1), onset1=-1; end;
  if (m<length(t)),
    Et(m+1)= Et(m) + dt*( (1/Etau)*ue(m) - (1/Etau)*Et(m) );
  end;
  if (ue(m)>0)&(onset1==-1)&(onset2==0),
    onset2=m;
    Etmax=max(Et(1:onset2-1));
  end;
  if Et(m)>Etmax, Et(m)=Etmax; end;
  E(m)=E0*(1+Etamp*Et(m));

  % Determine pressure
  P12rigid(m,:) = (x(length(x))-x) * (8*visc0*Fin(m)/(pi*a0*a0*a0*a0));

  P13rigid(m,:) = P12rigid(m,:) + P20 - P30;
  a_defor(m,:)=1-a0*P13rigid(m,:)/(E(m)*h0);
  a_elas(m,:)=a0./a_defor(m,:);

  V(m)=sum(pi*a_elas(m,:).*a_elas(m,:)*dx);

  if (m==1),
    Fout(m)=Fin(m);
  else,
    Fout(m)=Fin(m)-(V(m)-V(m-1))/dt;
  end;
 
end;

alpha=alphabase+alphaamp*u';

xl=length(x);
Hct=0.40;
%k1=10.6;
%k2=1;
%k3=1;
%k4=0.0035;      % 0.0035 for a=1

dQHb = k1*Fin*dt*Hct - k2*(alpha.*V)*Hct - k3*(1-alpha).*Fout*dt*Hct;
dS=k4*(dQHb./dQHb(1)-1);

if nargout==0,
  qmaxi=find(Fin==max(Fin));
  figure(1)
  subplot(311)
  plot(x,P13rigid(1,:),x,P13rigid(qmaxi,:),'r')
  ylabel('dP (a)')
  xlabel('x (m)')
  subplot(312)
  plot(x,a_elas(1,:),x,a_elas(qmaxi,:),'r')
  ylabel('a (m)')
  xlabel('x (m)')
  subplot(325)
  plot(t,E)
  ylabel('E')
  xlabel('t (s)')
  subplot(326)
  plot(t,a_elas(:,1))
  ylabel('a (m)')
  xlabel('t (s)')
  
  figure(2)
  subplot(321)
  plot(t,Fin)
  ylabel('Flow In (m^3/s)')
  xlabel('Time (s)')
  subplot(322)
  plot(t,V)
  ylabel('Volume (m^3)')
  xlabel('Time (s)')
  subplot(312)
  plot(t,S)
  xlabel('Time (s)')
  ylabel('Signal (relative)')
  subplot(313)
  plot(V./V(length(V)),Fin./Fin(length(Fin)))
  xlabel('Volume Change')
  ylabel('Flow Change')
end;

% A fundamental problem with this approach is that with
% distance in the vasculature, the flow changes, the Elasticity
% changes, the diameter of the tube and wall changes also,
% all of which change with distance


% To Continue:
%  Correct calculation of the pressures (so that radius can be computed)
%  Come up with some dynamics for the elasticity (viscoelastic - 
%   linear -- phase variations with same frequency?)

