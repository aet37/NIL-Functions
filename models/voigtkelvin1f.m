function [y,u1,F,t]=voigtkelvin1f(x,tparms,parms,parms2fit,data,tdata)
% Usage ... [Y,UU,U]=voigtkelvin1f(x,tparms,parms,parms2fit) 

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

Va=0.01*ml2m3;
La=0.005;
Da=sqrt(4*Va/(pi*La));
Ea=5e4*dycm22Pa;


dt=tparms(1); 		% 1/(60*20);
T=tparms(2);		% 2;
t=[0:dt:T];

mu=parms(1);		% 1;
nu=parms(2);		% 2/60;

mu0=parms(1);		% 1.5;
mu1=parms(2)*mu0;	% 1*mu0;
nu1=parms(3);		% 20/60;

D=1;
FF=parms(4);		% 0.1;

fst=parms(5); fdur=parms(6); framp=parms(7);
ftype=1; ftype3=[14 parms(8) parms(9)];
F=FF*mytrapezoid(t,fst,fdur,framp,ftype);
ftau=parms(10);
for mm=2:length(t),
  F(mm)=F(mm-1)+(dt/ftau)*( FF*mytrapezoid4(t(mm-1),fst,fdur,framp,ftype3) - F(mm-1) );
end;

u(1)=0;
u1(1)=0;
for mm=2:length(t),
  u(mm) = u(mm-1) + dt*(1/nu)*( F(mm-1) - mu*u(mm-1)  );
  if (mm>2), dFdt=(F(mm)-F(mm-1))/dt; else, dFdt=0; end;
  u1(mm) = u1(mm-1) + dt*(1/(nu1+nu1*mu0/mu1))*( F(mm-1) + (nu1/mu1)*dFdt - mu0*u1(mm-1) );
end;

Dv=D+u;
Dk=D+u1;

kq=1;
rQv=kq*((Dv/D).^4);
rQk=kq*((Dk/D).^4);

if (nargin>4),
  datai=interp1(tdata,data,t);
  err=(rQk-datai).^2;
  y=err;
  [x sum(y.^2)],
else,
  y=rQk;
end;

if (nargout==0), 
  %subplot(311)
  %plot(t,F)
  %subplot(312)
  %plot(t,Dv,t,Dk)
  %subplot(313)
  %plot(t,F,t,u,t,(rQv-1)/max(rQv-1))
  %plot(t,F,t,u1,t,(rQk-1)/max(rQk-1))
  plot(t,y)
end;



