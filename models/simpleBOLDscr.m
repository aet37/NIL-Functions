
clear all

cm2m=1e-2;
m2cm=1/cm2m;
mmHg2Pa=133.32;
Pa2mmHg=1/133.32;
ml2m3=1e-6;
m32ml=1/ml2m3;
min2sec=1/60;
sec2min=60;

alpha=0.4;

dt=(1/(60*20));
T=2;
t=[0:dt:T];

mu=0.004;

L1=1e-2;
L2=1e-1;
L3=2e-2;

Pi=50*mmHg2Pa;
Po=4*mmHg2Pa;
P0=0*mmHg2Pa;

P1=20*mmHg2Pa;
P2=10*mmHg2Pa;
P3=5*mmHg2Pa;

C1=7e-12;
C2=2e-11;
C3=1e-8;
C3k=40;
C3k1=.001;

F0=50;
V0=2;
Ca=9;
E0=0.45;

yst=4/60; ydur=20/60; yramp=1/60;

R1eq=(Pi-P1)/(F0*ml2m3*min2sec);
D1eq=(128*mu*L1/(pi*R1eq))^(1/4);
V1=(pi*D1eq*D1eq*L1);
R2eq=(P1-P2)/(F0*ml2m3*min2sec);
D2eq=(128*mu*L2/(pi*R2eq))^(1/4);
V2=(pi*D2eq*D2eq*L2);
R3eq=(P2-P3)/(F0*ml2m3*min2sec);
D3eq=(128*mu*L3/(pi*R3eq))^(1/4);
V3=(pi*D3eq*D3eq*L3);
R4eq=(P3-Po)/(F0*ml2m3*min2sec);


sk1=1;
sk2=1;
sb1=4.3*(42.57*1e-6*3.0*1.0e-6);
sb2=2.0; sb0=sk1/4;
sb3=0.6;

yamp=0.25;
ytau=3/60;

Vk1=0.05;
Vk2=100;
Vk3=-0.0000;

y2amp=0.60;
y2tau=2/60;

y(1)=0; y2(1)=0;
VV(1)=V0; Fin(1)=F0; Fout(1)=F0;
q(1)=Ca*E0*V3*m32ml;
q2(1)=Ca*E0*V0;
for mm=2:length(t),

  y(mm) = y(mm-1) + dt*( (1/ytau)*( mytrapezoid(t(mm-1),yst,ydur,yramp) - y(mm-1) ));
 
  D1(mm-1) = D1eq*(1+yamp*y(mm-1));
  R1eq(mm-1) = R1eq(1)*((D1(1)/D1(mm-1))^4);

  C3(mm-1) = (V3(1)/C3k)*( 1/( P3(mm-1) - P3(1) + C3k1*(P3(1)-P0) ) );

  P1(mm) = P1(mm-1) + dt*( (1/C1)*( (Pi-P1(mm-1))/R1eq(mm-1) - (P1(mm-1)-P2(mm-1))/R2eq ));
  P2(mm) = P2(mm-1) + dt*( (1/C2)*( (P1(mm-1)-P2(mm-1))/R2eq - (P2(mm-1)-P3(mm-1))/R3eq ));
  P3(mm) = P3(mm-1) + dt*( (1/C3(mm-1))*( (P2(mm-1)-P3(mm-1))/R3eq - (P3(mm-1)-Po)/R4eq ));

  V1(mm) = V1(mm-1) + C1*( P1(mm)-P1(mm-1) );
  V2(mm) = V2(mm-1) + C2*( P2(mm)-P2(mm-1) );
  V3(mm) = (V3(1)/C3k)*log( (1/C3k1)*( (P3(mm)-P0)/(P3(1)-P0) - 1) + 1 ) + V3(1);

  F1(mm-1) = (Pi-P1(mm-1))/R1eq(mm-1);
  F2(mm-1) = (P1(mm-1)-P2(mm-1))/R2eq;
  F3(mm-1) = (P2(mm-1)-P3(mm-1))/R3eq;

 
  y2(mm) = y2(mm-1) + dt*( (1/y2tau)*( mytrapezoid(t(mm-1),yst,ydur,yramp) - y2(mm-1) ));

  Fin(mm-1) = F0*( 1 + y2amp*y2(mm-1) );
  VV(mm-1) = V0*(Vk1*(log(Vk2*(Fin(mm-1)/Fin(1)-1)+1))+1);
  if (mm>2),
    VV(mm-1) = VV(mm-1) + Vk3*(Fin(mm-1)-Fin(mm-2))/dt;
    Fout(mm-1) = 0.5*(Fin(mm-1)+Fin(mm-2)) - (VV(mm-1)-VV(mm-2))/dt;
  end;



  EEb(mm-1) = 1 - (1-E0)^(F2(1)/F2(mm-1));
  EEb2(mm-1) = 1 - (1-E0)^(Fin(1)/Fin(mm-1));


  q(mm) = q(mm-1) + dt*sec2min*( Ca*EEb(mm-1)*m32ml*F2(mm-1)*V2(1)/V2(mm-1) - q(mm-1)*F3(mm-1)/V3(mm-1) );
  q2(mm) = q2(mm-1) + dt*( Ca*EEb2(mm-1)*Fin(mm-1) - q2(mm-1)*Fout(mm-1)/VV(mm-1) );

  S(mm-1) = sk1*( 1 - sk2*q(mm-1)/q(1) );
  S2(mm-1) = sk1*( 1 - sk2*q2(mm-1)/q2(1) );

  Sb(mm-1) = sb0*( sb1*E0*( 1 - q(mm-1)/q(1) ) + sb2*( 1 - (q(mm-1)/q(1))/(V3(mm-1)/V3(1)) ) + sb3*( 1 - V3(mm-1)/V3(1) ) );
  Sb2(mm-1) = sb0*( sb1*E0*( 1 - q2(mm-1)/q2(1) ) + sb2*( 1 - (q2(mm-1)/q2(1))/(VV(mm-1)/VV(1)) ) + sb3*( 1 - VV(mm-1)/VV(1)) );

end;
D1(mm)=D1(mm-1);
R1eq(mm)=R1eq(mm-1);
C3(mm)=C3(mm-1);
F1(mm)=F1(mm-1);
F2(mm)=F2(mm-1);
F3(mm)=F3(mm-1);
Fin(mm)=Fin(mm-1);
VV(mm)=VV(mm-1);
Fout(mm)=Fout(mm-1);
EEb(mm)=EEb(mm-1);
EEb2(mm)=EEb2(mm-1);
q(mm)=q(mm-1);
q2(mm)=q2(mm-1);
S(mm)=S(mm-1);
S2(mm)=S2(mm-1);
Sb(mm)=Sb(mm-1);
Sb2(mm)=Sb2(mm-1);



figure(1)
subplot(311)
plot(t,[F1' F2' F3']*m32ml*sec2min)
title(sprintf('F_0 = [ %4.2f %4.2f %4.2f ] ml/min',[F1(1) F2(1) F3(1)]*m32ml*sec2min))
subplot(312)
plot(t,[V1'/V1(1) V2'/V2(1) V3'/V3(1)])
title(sprintf('V_0 = [ %4.2f %4.2f %4.2f ] ml',[V1(1) V2(1) V3(1)]*m32ml))
subplot(313)
plot(V1/V1(1),P1/P1(1),V2/V2(1),P2/P2(1),V3/V3(1),P3/P3(1))

figure(2)
subplot(311)
plot(t,[Fin' Fout'])
title(sprintf('F_0 = [ %4.2f %4.2f ] ml/min',[Fin(1) Fout(1)]))
subplot(312)
plot(t,VV/VV(1))
title(sprintf('V_0 = %4.2f ml',VV(1)))
subplot(313)
plot(VV/VV(1),Fin/Fin(1))

figure(3)
subplot(211)
plot(t,q/q(1),t,q2/q2(1))
subplot(212)
plot(t,Sb,t,Sb2,t,S,'--',t,S2,'--')

