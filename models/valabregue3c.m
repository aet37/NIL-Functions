
clear all

opt1min=optimset('fminbnd');
dtol=1e-10;
RK_flag=1;
BOLD_flag=1;
plots_flag=1;

cm2m=1e-2;
m2cm=1/cm2m;
mmHg2Pa=133.32;
Pa2mmHg=1/133.32;
ml2m3=1e-6;
m32ml=1/ml2m3;
min2sec=1/60;
sec2min=60;


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
C3k1=.0002;


alpha=1.39e-3;	% units: mmol/L/mmHg
P50=26;		% units: mmHg
hill=2.73;
cHb=2.3;	% units: mmol/L
PO=4;

F0=50;		% units: ml/min

% calculate the initial condition first from the steady state solution
%   assume CMRO2 is given (units: mmol/min)
%     we can solve for either Ct, Cp (mmol/ml) or PS (ml/min)
%     PS has been reported around to be around 3000 to 7000 ml/min!
%     but this is likely dependent on the choice of L!
      PS=7200;
%   assume Cp_bar is known
%

%CMRO20=2.7938;
%Cp_bar=0.0065;
%PS=CMRO20/(Cp_bar-Ct);

Pa=90;		% units: mmHg
Pt=20;		% units: mmHg
Cpa=Pa*alpha;
Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
Ct=Pt*alpha;

Hparms = [cHb PO alpha P50 hill];
Cc = fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,F0,Hparms);
CMRO20 = PS*( H_inv(Cc,Hparms) - Ct );
E = 2*(1-Cc/Ca);

% now we have a steady-state calculation that can be used as initial
% condition, let's try to calculate the dynamic model


T=2.0;		% units: min
dt=1/(60*20);	% units: min (0.5 sec resolution)
t=[0:dt:T];

Vc=1;		% units: ml
Vt=96;		% units: ml

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
q_dHb=Ca*E*F0/(F0/(V3*m32ml));

hgamma=42.57*1e-6;      % units: Hz T
B0=3.0;                 % units: T
dHb_dchi=1e-6;          % units: ppm*1e-6
sk1=1;
sk2=1;
sb1=4.3*(hgamma*B0*dHb_dchi);
sb2=2.0; sb0=sk1/4;
sb3=0.6;


F=ones(size(t))*F0;
famp=0.64; fstart=10.5/60; fdur=52/60; framp=8/60;
%famp=0.64; fstart=18.5/60; fdur=44/60; framp=16/60;
F=F0*(1+famp*mytrapezoid(t,fstart,fdur,framp));
CMRO2=ones(size(t))*CMRO20;
camp=0.24; cstart=3/60; cdur=59.5/60; cramp=.5/60;
%camp=0.24; cstart=4.5/60; cdur=58/60; cramp=2/60;
CMRO2=CMRO20*(1+camp*mytrapezoid(t,cstart,cdur,cramp));

ftype=2;
ytau=framp/4;
yamp=0.25;

CCc(1)=Cc;
CCt(1)=Ct;
EE(1)=E;
EEx(1)=E;
y(1)=0;
for mm=2:length(t),

  y(mm) = y(mm-1) + (dt/ytau)*( mytrapezoid(t(mm-1),cstart,cdur,cramp) - y(mm-1) );

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

  if (RK_flag),
    yh = y(mm-1) + (dt/2)*(1/ytau)*( mytrapezoid(t(mm-1),cstart,cdur,cramp) - y(mm-1) );
    R1h = R1eq*((1/(1+yamp*yh))^4);
    R1hh = R1eq*((1/(1+yamp*y(mm)))^4);
    P1h = P1(mm-1) + (dt/2)*( (1/C1)*( (Pi-P1(mm-1))/R1eq(mm-1) - (P1(mm-1)-P2(mm-1))/R2eq ));
    P2h = P2(mm-1) + (dt/2)*( (1/C2)*( (P1(mm-1)-P2(mm-1))/R2eq - (P2(mm-1)-P3(mm-1))/R3eq ));
    F2h = (P1h-P2h)/R2eq;
    F2hh = (P1(mm)-P2(mm))/R2eq;
  end;
  


  CCt(mm) = CCt(mm-1) + (dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2(mm-1) );

  if (RK_flag),
    %CMRO2a(mm-1)=CMRO20;
    %CMRO2b(mm-1)=CMRO20;
    %CMRO2c(mm-1)=CMRO20;
    CMRO2a(mm-1)=CMRO20*(1+camp*mytrapezoid(t(mm-1),cstart,cdur,cramp));
    CMRO2b(mm-1)=CMRO20*(1+camp*mytrapezoid(t(mm-1)+dt/2,cstart,cdur,cramp));
    CMRO2c(mm-1)=CMRO20*(1+camp*mytrapezoid(t(mm-1)+dt,cstart,cdur,cramp));
    Ctk1=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2a(mm-1) );
    Ctk2=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk1/2) ) - CMRO2b(mm-1) );
    Ctk3=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk2/2) ) - CMRO2b(mm-1) );
    Ctk4=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk3) ) - CMRO2c(mm-1) );

    CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;
  end;

  A =  F2(mm-1)*2*( Ca - CCc(mm-1) );
  B =  PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt/Vc)*( A - B );

  if (RK_flag),
    if (ftype==2),
      Fa=F2(mm-1)*m32ml*sec2min;
      Fb=F2h*m32ml*sec2min;
      Fc=F2hh*m32ml*sec2min;
    else,
      Fa=F0*(1+famp*mytrapezoid(t(mm-1),fstart,fdur,framp));
      Fb=F0*(1+famp*mytrapezoid(t(mm-1)+dt/2,fstart,fdur,framp));
      Fc=F0*(1+famp*mytrapezoid(t(mm-1)+dt,fstart,fdur,framp));
    end;
    Cck1=(dt/Vc)*( Fa*2*(Ca-CCc(mm-1)) - PS*(H_inv(CCc(mm-1),Hparms)-CCt(mm-1)) );
    Cck2=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck1/2)) - PS*(H_inv(CCc(mm-1)+Cck1/2,Hparms)-CCt(mm-1)) );
    Cck3=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck2/2)) - PS*(H_inv(CCc(mm-1)+Cck2/2,Hparms)-CCt(mm-1)) );
    Cck4=(dt/Vc)*( Fc*2*(Ca-(CCc(mm-1)+Cck3)) - PS*(H_inv(CCc(mm-1)+Cck3,Hparms)-CCt(mm-1)) );
    CCc(mm) = CCc(mm-1) + Cck1/6 + Cck2/3 + Cck2/3 + Cck4/6;
  end;

  EE(mm) = 2*( 1 - CCc(mm)/Ca );

  EEx(mm) = 1 - (1-EEx(1))^(F1(1)/F1(mm-1));


  DD1 = Ca*EE(mm-1)*V2(1) * m32ml*F2(mm-1)/V2(mm-1);
  DD2 = F3(mm-1)/V3(mm-1);
  q_dHb(mm) = q_dHb(mm-1) + dt*( DD1 - q_dHb(mm-1)*DD2 );

  S1(mm-1) = sk1*( 1 - sk2*(q_dHb(mm-1)/q_dHb(1)) );
  S2(mm-1) = sb0*( sb1*EE(1)*( 1 - q_dHb(mm-1)/q_dHb(1) ) + sb2*( 1 - (q_dHb(mm-1)/q_dHb(1))/(V3(mm-1)/V3(1)) )  + sb3*( 1 - V3(mm-1)/V3(1) ) );

end;
C3(mm)=C3(mm-1);
F1(mm)=F1(mm-1);
F2(mm)=F2(mm-1);
F3(mm)=F3(mm-1);
S1(mm)=S1(mm-1);
S2(mm)=S2(mm-1);


[EEa,CMRO2a]=valabregue3ff(F0*[1 1+famp],PS,Pt,Pa);
[EEb,CMRO2b]=valabregue3ff(F2*m32ml*sec2min,PS,Pt,Pa);



if (plots_flag),
  figure(1)
  subplot(211)
  plot(t*60,F2*m32ml*sec2min,'b-')
  ylabel('CBF')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  subplot(212)
  plot(t*60,CMRO2,'b-',t*60,CMRO2b,'g-')
  ylabel('rCMRO2')
  axis('tight'), grid('on'),
  xlabel('Time')
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  legend('Dynamic','Steady')
  figure(2)
  subplot(211)
  plot(t*60,EE,'b-',t*60,EEb,'g-')
  ylabel('E')
  xlabel('Time')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  legend('Dynamic','Steady',4)
  subplot(212)
  plot(t*60,S1,'b-',t*60,S2,'g-')
  ylabel('BOLD')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  xlabel('Time')
  dofontsize(15), fatlines,
end;

