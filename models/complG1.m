%function [P,V,C,u,Qi,Qo]=complG1(x,uparms,params,params2fit,data)
% Usage ... [P,V,C,u,Fi,Fo]=complG1(x,uparms,params,params2fit,data)
%
% uparms = [ust udur uramp uamp]
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

Pi=50;
P=20;
Po=10;
Pc=5;

Q0=50;
V0=1;

Ri=(Pi-P)/Q0;
Ro=(P-Po)/Q0;
R0=Ro;

k1=0.01;
k2=0.1;

C0=10;
alpha=0;
aa=1;
C0=C0+alpha*(P-Pc)^aa;

T=R0*C0;
dt=T/1e3;
T_hat=[0:dt:1*T];
t=T_hat/T;

ust=4/60; udur=10/60; uramp=1/60; uamp=-1;
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

