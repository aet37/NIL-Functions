
clear all

plots_flag=1;

% Script for the description of a...
% Vessel as a rigid fluid conduit and as an elastic fluid conduit

% Vessel/Tube properties
v0=0.5e-2;		 % units: m/s
a0=100e-6;               % units: m
E0=5.0e4;                % units: N/m2
h0=0.20*a0;               % units: m

% Blood/Fluid properties
rho0=1e3;		 % units: kg/m3
visc0=0.004;             % units: Ns/m2
Fin0=v0*pi*a0*a0;        % units: m3/s (x10^6 for cm3/2)
Fout0=Fin0;              % units: m3/s
Ftau=2.0;		 % units: s

Etau1=10.0;		 % units: s
Etau2=50.0;		 % units: s

alphabase=1.0;
alphaamp=0.0;

% Environment properties
Pinx=10*133.322;        % units: N/m2
Pout=10*133.322;        % units: N/m2

P20=Pinx;
P30=Pout;

x=[0:1e-4:5e-2];	% units: m
dx=x(2)-x(1);

% Time dependent quantities
t=[0:1:100]';
dt=t(2)-t(1);
u=zeros(size(t)); ue=u;
%u(11:15)=ones([5 1]);
%ue(14:18)=ones([5 1]);
%u(25:29)=ones([5 1]);
%ue(27:33)=ones([7 1]);
%u(11:15)=ones([5 1]); u(25:29)=ones([5 1]);
%ue(13:19)=ones([7 1]); ue(29:35)=ones([7 1]);
%u(16:20)=ones([5 1]);
%ue(18:24)=ones([7 1]);
%u(11:20)=ones([10 1]);
%ue(13:24)=ones([12 1]);		% used to be 14:25
%u(41:52)=conv([1 1 1],ones([10 1]))./3;
%ue(41:54)=conv([1 1 1],ones([12 1]))./3;
u=smrect(t,[0.1 10 20],1);
ue=smrect(t,[0.05 12 19],1);

% consider a portion of the compartment
x1i=1;
x2i=501;

% Time progression
Rin(1)=0;
Ramp=0.50;
Et(1)=0;
Etamp=-0.50;
Etmax=1.0;
onset1=0;
onset2=0;

for m=1:length(t),

  % Generate flow dynamics
  if (m<length(t)),
    Rin(m+1)= Rin(m) + dt*( (1/Ftau)*u(m) - (1/Ftau)*Rin(m)  );
  end;
  %Rin(m)=u(m);
  Fin(m)=Fin0*(Ramp*Rin(m)+1.0);
  Fout(m)=Fin(m);

  % Generate elasticity dynamics
  if (ue(m)>0)&(onset1==0), onset1=1; end;
  if (ue(m)==0)&(onset1==1), onset1=-1; end;
  if (m<length(t)),
    Et(m+1)= Et(m) + dt*( (1/Etau1)*ue(m) - (1/Etau2)*Et(m) );
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

  V(m)=sum(pi*a_elas(m,x1i:x2i).*a_elas(m,x1i:x2i)*dx);

  if (m==1), 
    Fout(m)=Fin(m); 
  else,
    Fout(m)=Fin(m)-(V(m)-V(m-1))/dt;
  end;
 
end;

Re=rho0*v0*2*a0/visc0;

% signal translation section
signal_type=0;
Hct=0.40;
if (signal_type==1),
  k1=+16.0;
  k2=-1;
  k3=-1;
  k4=+0.0035;	% 0.0035 for a=1 (k1/k2/k3=16/1/1)
  alpha=alphabase+alphaamp*u';
  dQHb = k1*Fin*dt*Hct + k2*alpha.*V*Hct + k3*(1-alpha).*Fout*dt*Hct;
elseif (signal_type==2),
  k1=+1.0;
  k2=+1.0;
  k3=+1.0;
  k4=+1.0;
  dQHb = (k1.*Fin*dt*Hct+k2.*V*Hct)./(1-k3.*Fout*dt./V); 
elseif (signal_type==3),
  k1=+10.0;
  k2=+1.0;
  k3=+1.0;
  k4=+1.0;
  dQHb = (k1.*Fin*dt*Hct+k2.*V*Hct).*(1-k3.*Fout*dt./V);
else,
  k1=+1.0;
  k2=+1.0;
  k3=+1.0;
  k4=+1.0;
  dQHb = (k1.*Fin*dt*Hct+k2.*V*Hct).*(1-k3.*Fout*dt./V);
end;

dS=k4*(dQHb./dQHb(1)-1);


if plots_flag,
  figure(1)
  subplot(321)
  plot(x,a_elas(1,:),x,a_elas(30,:),'r')
  hold('on')
  plot([x(x1i) x(x1i)],[a0 a_elas(1,x1i)],'g')
  plot([x(x2i) x(x2i)],[a0 a_elas(1,x2i)],'g')
  hold('off')
  ylabel('r (m)')
  xlabel('x (m)')
  subplot(322)
  plot(t,a_elas(:,1))
  xlabel('Time (s)')
  ylabel('r(m)')
  subplot(312)
  plot(t,P13rigid(:,1))
  ylabel('P13_r_i_g_i_d (N/m2)')
  xlabel('Time (s)')
  subplot(313)
  plot(t,E)
  ylabel('E')
  xlabel('t (s)')
  %subplot(326)
  %plot(t,a_elas(:,1))
  %ylabel('r (m)')
  %xlabel('t (s)')

  figure(2)
  subplot(321)
  plot(t,Fin,t,Fout)
  ylabel('Flow In/out (m^3/s)')
  xlabel('Time (s)')
  subplot(322)
  plot(t,V)
  ylabel('Volume (m^3)')
  xlabel('Time (s)')
  subplot(312)
  plot(t,dS')
  xlabel('Time (s)')
  ylabel('Signal Change')
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

