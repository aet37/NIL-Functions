function [Q,D,F]=voigtkelvin2(x,parms,parms2fit,rFt,data)
% usage ... [Q,D,F]=voigtkelvin2(x,parms,parms2fit,input,data)
%
% parms = [ type dt mu nu mu1 D0 F0 Q0]
% data = [raCBF]

% Example:
% dt=1/(60*20);
% tt=[0:dt:50/60];
% uu=mytrapezoid(tt,2.5/60,11.5/60,0.5/60);
% voigtkelvin2([],[1 dt 50 100/60 50 1e-3 0.01 1],[],uu+1);


% Visco-elastic models that relate force F to extension u
%  * Voigt model - for fixed mu, nu is the time-constant
%      F = m*u + n*du/dt
%  * Kelvin model - more complicated
%      F = m*u + n*(1+m/m1)*du/dt - (n/m1)*dF/dt
%         t_e=n/m1   t_s=(n/m)*(1+m/m1)   Er=m
%
% Units: m=[Force/Displ]  n=[Force/Time/Displ]
%
% Modulus of Elasticity for relaxed muscle ~ 1e4 dy/cm2 (contracted 1e5)
% Small artery ~ 0.2mm diameter (50% wall thickness, additional?)

if (~isempty(x)),
  parms(parms2fit)=x;
end;

ml2m3=1e-6;
dycm22Pa=0.1;

mtype=parms(1);

Va=0.01*ml2m3;
La=0.005;
Da=sqrt(4*Va/(pi*La));
Ea=5e4*dycm22Pa;


dt=parms(2);
t=[1:length(rFt)]*dt;

if (mtype==2),
  mu0=parms(5);
  mu1=parms(3);
  nu1=parms(4);
  mu=parms(3);
  nu=parms(4);
else,
  mu=parms(3);
  nu=parms(4);
  mu1=parms(3);
  nu1=parms(4);
  mu0=parms(5);
end;


D=parms(6);
FF=parms(7);
F=FF*(rFt-1);

u(1)=0;
u1(1)=0;
for mm=2:length(rFt),
  u(mm) = u(mm-1) + dt*(1/nu)*( F(mm-1) - mu*u(mm-1)  );
  if (mm>2), dFdt=(F(mm)-F(mm-1))/dt; else, dFdt=0; end;
  u1(mm) = u1(mm-1) + dt*(1/(nu1+nu1*mu0/mu1))*( F(mm-1) + (nu1/mu1)*dFdt - mu0*u1(mm-1) );
end;

Dv=D+u;
Dk=D+u1;

Q0=parms(8);
Qv=Q0*((Dv/D).^4);
Qk=Q0*((Dk/D).^4);

if (mtype==2),
  D=Dk;
  Q=Qk;
else,
  D=Dv;
  Q=Qv;
end;

if (nargout==0),
  subplot(311)
  plot(t,F)
  subplot(312)
  plot(t,D/D(1))
  subplot(313)
  plot(t,Q/Q(1))
end;

if (nargin>4),
  if (nargout==0),
    clf,
    plot(t,data,t,Q/Q(1))
  end;
  Q=data-Q/Q(1);
  [x sum(Q.*Q)],
end;


