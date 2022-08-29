function [Q,D,UU,F]=voigtkelvin3(x,parms,parms2fit,data)
% usage ... [Q,D,U]=voigtkelvin3(x,parms,parms2fit,data)
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
T=parms(3);
npts=round(T/dt);
t=[1:npts]*dt;

if (mtype==2),
  mu0=parms(6);
  mu1=parms(4);
  nu1=parms(5);
  mu=parms(4);
  nu=parms(5);
else,
  mu=parms(4);
  nu=parms(5);
  mu1=parms(4);
  nu1=parms(5);
  mu0=parms(6);
end;


D=parms(7);
FF=parms(8);

fst=parms(10);
fdur=parms(11);
framp=parms(12);
UU=mytrapezoid(t,fst,fdur,framp);

if (length(parms)>12),
utau=parms(13);
ftype3=[14 parms(14) parms(15)];
UU(1)=0;
for mm=2:length(t),
  UU(mm)=UU(mm-1) + (dt/utau)*( mytrapezoid3(t(mm-1),fst,fdur,framp,ftype3) - UU(mm-1) );
end;
end;

rFt=1+UU;
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

Q0=parms(9);
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

if (nargin>3),
  if (nargout==0),
    clf,
    plot(t,data,t,Q/Q(1))
  end;
  Q=data-Q/Q(1);
  [x sum(Q.*Q)],
end;


