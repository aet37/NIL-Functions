
clear all

cm2m=1e-2;
m2cm=1/cm2m;
mmHg2Pa=133.32;
Pa2mmHg=1/133.32;
ml2m3=1e-6;
m32ml=1/ml2m3;
min2sec=1/60;
sec2min=60;

dt=(1/(60*100));
T=1;
t=[0:dt:T];	% min

grubb=0.4;
mu=0.004;	% cP

Li=5e-2;	% m
Lo=5e-2;	% m

F0=50;		% ml/min

Pi=20;		% mmHg
P=10;		% mmHg
Po=5;		% mmHg
P0=9.999;	% mmHg

ctype=4;
C0=1*0.015;	% (1=0.015, 2=0.03, 4=0/-9/0)
Ck1=00.003;	% (2=40, 3=0, 4=0/100/0)
Ck2=0.0000;	% (2=0.001, 3=0, 4=0)
Ck3=0.0000;	% (2=0, 3=0.00001, 4=0.00001)
Ck5=-1;		% (4= -2)

Ri=(Pi-P)/F0;	% mmHg/ml/min
Ro=(P-Po)/F0;	% mmHg/ml/min

Di=(128*mu*Li/(pi*Ri*mmHg2Pa/ml2m3/min2sec))^(1/4);
Do=(128*mu*Lo/(pi*Ro*mmHg2Pa/ml2m3/min2sec))^(1/4);
Vi0=(pi*Di*Di*Li)*m32ml;
Vo0=(pi*Do*Do*Lo)*m32ml;
V0=Vi0;

yst=3.5/60; ydur=11.5/60; yramp=0.5/60;
ytype=[1];
ytau=4/60;
yamp=0.25;

ztau=8/60;
zamp=-0.25;

vk1=0.3;
V(1)=Vi0;
P2(1)=P; V2(1)=V(1); VV(1)=1;
y(1)=0; z(1)=0;
for mm=2:length(t),

  y(mm) = y(mm-1) + dt*( (1/ytau)*( mytrapezoid(t(mm-1),yst,ydur,yramp,ytype) - y(mm-1) ));
  yh = y(mm-1) + (dt/2)*(1/ytau)*( mytrapezoid(t(mm-1),yst,ydur,yramp,ytype) - y(mm-1) );

  Dit(mm-1) = Di*(1+yamp*y(mm-1));
  Rit(mm-1) = Ri*((1/(1+yamp*y(mm-1)))^4);
  Rih = Ri*((1/(1+yamp*yh))^4);
  Rihh = Ri*((1/(1+yamp*y(mm)))^4);

  Fi(mm-1)=(Pi-P(mm-1))/Rit(mm-1);
  Fi2(mm-1)=F0*(1+2.5*yamp*y(mm-1));

  if (ctype==2),
    C(mm-1) = (V(1)/Ck1)*( 1/( P(mm-1)-P(1)+Ck2*(P(1)-P0) ));
    P(mm)=P(mm-1)+dt*( (1/C(mm-1))*( Pi/Rit(mm-1) + Po/Ro - P(mm-1)*(1/Rit(mm-1)+1/Ro) ));
    P2(mm)=P2(mm-1)+dt*( (1/C(mm-1))*( Fi2(mm-1) - (P2(mm-1)-Po)/Ro ));
  elseif (ctype==3),
    C(mm-1) = (V(1)/Ck1)*( 1/( P(mm-1)-P(1)+Ck2*(P(1)-P0) ));
    if (mm>2), C(mm-1) = C(mm-1) + Ck3*(P(mm-1)-P(mm-2))/dt; end;
    P(mm)=P(mm-1)+dt*( (1/C(mm-1))*( Pi/Rit(mm-1) + Po/Ro - P(mm-1)*(Rit(mm-1)+Ro)/(Rit(mm-1)*Ro) ));
    P2(mm)=P2(mm-1)+dt*( (1/C(mm-1))*( Fi2(mm-1) - (P2(mm-1)-Po)/Ro ));
  elseif (ctype==4),
    pp2 = (Ck3/(dt*dt));
    pp1 = (C0/dt) + (Ck1/dt)*((P(mm-1)-P0)^Ck5) - (2*Ck3/(dt*dt))*P(mm-1);
    pp0 = ( -(C0/dt)*P(mm-1) -(Ck1/dt)*P(mm-1)*((P(mm-1)-P0)^Ck5) + (Ck3/(dt*dt))*P(mm-1)*P(mm-1) );
    pp0a = pp0 - (Pi/Rit(mm-1) + Po/Ro - P(mm-1)*(1/Rit(mm-1)+1/Ro));
    pp0b = pp0 - (Fi2(mm-1)-(P(mm-1)-Po)/Ro);
    ppr = roots([pp2 pp1 pp0a]);
    P(mm)=ppr(1);
    ppr = roots([pp2 pp1 pp0b]);
    P2(mm)=ppr(1);
    C(mm-1) = C0 + Ck1*((P(mm-1)-P0)^Ck5) + Ck3*(P(mm)-P(mm-1))/dt;
  elseif (ctype==5),
    C(mm-1) = C0 + Ck1*( (((P(mm-1)-P0)/P(1))^Ck5)-1 );
    P(mm)=P(mm-1)+dt*( (1/C(mm-1))*( Pi/Rit(mm-1) + Po/Ro - P(mm-1)*(1/Rit(mm-1)+1/Ro) ));
    P2(mm)=P2(mm-1)+dt*( (1/C(mm-1))*( Fi2(mm-1) - (P2(mm-1)-Po)/Ro ));
    ck1=C0 + Ck1*( (((P(mm-1)-P0)/P(1))^Ck5)-1 );
    pk1=dt*( (1/ck1)*( Pi/Rit(mm-1) + Po/Ro - P(mm-1)*(1/Rit(mm-1)+1/Ro) ));
    ck2=C0 + Ck1*( (((P(mm-1)+pk1/2-P0)/P(1))^Ck5)-1 );
    pk2=dt*( (1/ck2)*( Pi/Rih + Po/Ro - (P(mm-1)+pk1/2)*(1/Rih+1/Ro) ));
    ck3=C0 + Ck1*( (((P(mm-1)+pk2/2-P0)/P(1))^Ck5)-1 );
    pk3=dt*( (1/ck3)*( Pi/Rih + Po/Ro - (P(mm-1)+pk2/2)*(1/Rih+1/Ro) ));
    ck4=C0 + Ck1*( (((P(mm-1)+pk3-P0)/P(1))^Ck5)-1 );
    pk4=dt*( (1/ck4)*( Pi/Rihh + Po/Ro - (P(mm-1)+pk3)*(1/Rihh+1/Ro) ));
    P(mm) = P(mm-1) + pk1/6+pk2/3+pk3/3+pk4/6;
  elseif (ctype==6),
    C(mm-1) = C0;
    if (mm>2), C(mm-1) = C(mm-1) + Ck3*(P(mm-1)-P(mm-2))/dt; end;
    P(mm)=P(mm-1)+dt*( (1/C(mm-1))*( Pi/Rit(mm-1) + Po/Ro - P(mm-1)*(Rit(mm-1)+Ro)/(Rit(mm-1)*Ro) ));
    P2(mm)=P2(mm-1)+dt*( (1/C(mm-1))*( Fi2(mm-1) - (P2(mm-1)-Po)/Ro ));
  elseif (ctype==9)
    z(mm) = z(mm-1) + dt*( (1/ztau)*( (P(mm-1)/P(1)-1) - z(mm-1) ));
    C(mm-1) = C0*(1+zamp*z(mm-1));
    P(mm)=P(mm-1)+dt*( (1/C(mm-1))*( Pi/Rit(mm-1) + Po/Ro - P(mm-1)*(Rit(mm-1)+Ro)/(Rit(mm-1)*Ro) ));
  else,
    C(mm-1)=C0;
    P(mm)=P(mm-1)+dt*( (1/C(mm-1))*( Pi/Rit(mm-1) + Po/Ro - P(mm-1)*(1/Rit(mm-1)+1/Ro) ));
    P2(mm)=P2(mm-1)+dt*( (1/C(mm-1))*( Fi2(mm-1) - (P2(mm-1)-Po)/Ro ));
  end;

  Fo(mm-1)=(P(mm-1)-Po)/Ro;
  Fo2(mm-1)=(P2(mm-1)-Po)/Ro;

  V(mm)=V(mm-1)+dt*(Fi(mm-1)-Fo(mm-1));
  V2(mm)=V2(mm-1)+dt*(Fi2(mm-1)-Fo2(mm-1));

  Fin(mm-1)=Fi2(mm-1);
  VV(mm)=VV(mm-1)+dt*( (1/(1+vk1*F0))*( Fin(mm-1) - F0*((VV(mm-1)/VV(1))^(1/grubb)) ));
  VV(mm)=VV(mm-1)+dt*( (1/(1+vk1*F0))*( Fin(mm-1) - F0*((VV(mm-1)/VV(1))^(1/grubb)) ));
  Fout(mm-1)=Fin(mm-1)-(VV(mm)-VV(mm-1))/dt;

end;
Fi(mm)=Fi(mm-1);
Fo(mm)=Fo(mm-1);
Fi2(mm)=Fi2(mm-1);
V2(mm)=V2(mm-1);
Fin(mm)=Fin(mm-1);
Fout(mm)=Fout(mm-1);

