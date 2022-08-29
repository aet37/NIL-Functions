function [P,V,C,Ri,u,Qi,Qo]=complG1(x,uparms,parms,parms2fit,outdata,data)
% Usage ... [P,V,C,Ri,u,Fi,Fo]=complG1(x,uparms,params,params2fit,outdata,data)
%
% uparms = [dt T ust udur uramp uamp]
% parms = [Pi P Po Pc Q0 V0 k1 k2 C0 alpha aa]

% Non-dimensional Equations
%
%  dRi_hat/dT = k1*C0*u(t) - k2*R0*C0*Ri_hat
%
%  C_hat*dP_hat/dT = 1/Ri_hat * Pi/(Pi - Pc) + Po/(Pi - Pc) - ...
%         ( P_hat + Pc/(Pi - Pc) )*( 1/Ri_hat + 1)
%
%  C_hat = 1 + alpha*P_hat^a*((Pi-Pc)^a/C0) + beta*dP_hat/dt*((Pi-Pc)/R0*C0^2)
%
% Picked: T=t/(R0*C0)  P_hat=(P-Pc)/(Pi-Pc)  Ri_hat=Ri/R0  C_hat=C/C0

if (~isempty(parms2fit)), parms(parms2fit)=x; end;

Pi=parms(1);
P=parms(2);
Po=parms(3);
Pc=parms(4);

Q0=parms(5);
V0=parms(6);

Ri=(Pi-P)/Q0;
Ro=(P-Po)/Q0;
R0=Ro;

k1=parms(7);
k2=parms(8);

C0=parms(9);
alpha=parms(10);
aa=parms(11);
C0=C0+alpha*(P-Pc)^aa;

dt=uparms(1);
T=uparms(2);
t=[0:dt:T]*(1*R0*C0)/T;

TT=R0*C0;
dT=TT/1e3;
TT_hat=[0:dT:1*TT];

ust=uparms(3); udur=uparms(4); uramp=uparms(5); uamp=uparms(6);
u=uamp*mytrapezoid(t,ust,udur,uramp);

Ri_hat(1)=Ri/R0;
P_hat(1)=(P-Pc)/(Pi-Pc);
C_hat=1;
for mm=2:length(u),

  Ri_hat(mm) = Ri_hat(mm-1) + dt*( k1*C0*u(mm-1) - k2*R0*C0*(Ri_hat(mm-1)-Ri/R0)  );

  P_hat(mm) = P_hat(mm-1) + (dt/C_hat(mm-1))*( (1/Ri_hat(mm-1))*(Pi/(Pi-Pc)) + Po/(Pi-Pc) - (P_hat(mm-1) + Pc/(Pi-Pc) )*( 1/Ri_hat(mm-1) + 1) );

  C_hat(mm) = 1 + alpha*(P_hat(mm)^aa)*(((Pi-Pc)^aa)/C0);

end;

Ri=(Ri_hat)*R0;
P=P_hat*(Pi-Pc)+Pc;
C=C_hat*C0;

V(1)=V0;
for mm=2:length(u),
  V(mm) = V(mm-1) + C(mm-1)*(P(mm)-P(mm-1));
end;

Qi=(Pi-P)./Ri;
Qo=(P-Po)./Ro;


if (nargin>4),
  if (outdata==1),
    yy=Qi/Qi(1);
  elseif (outdata==2),
    yy=Qo/Qo(1);
  elseif (outdata==3),
    yy=V/V(1);
  else,
    yy=[Qi/Qi(1) Qo/Qo(1) V/V(1)];
  end;
  %size(yy), size(data),
  zz=yy-data;
  x,
  sum(sum(zz.*zz))/length(zz),
  P=zz;
end;

