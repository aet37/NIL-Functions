
%
%function [S,Q,V,F]=BOLD(NN,parms,Vparms,Eparms)
% Usage ... [S,Q,V,F]=BOLD(NN,parms,Vparms,Eparms)
%
% BOLD signal model where the input is a neuronal input function NN
% and the vascular and oxygen extraction responses are simulated as
% well as the resulting BOLD response.
% See function code for details.
% parms = [ dt ]
% Vparms = [ ]
% Eparms = [ ]

% Simulation units:
%  T = [min]
%  V = [ml]
%  q = [mmol]
%  C = q/V
%  Q = V/T


clear all

% simulation flags
doplots=1;
rk_flag=1;
rk_flag2=0;
rk_flag3=0;

% time vector 
dt=1e-2;		% units: sec
T=90;			% units: sec
t=[0:dt:T];

% inputs
nst=10; ndur=30; nramp=.5;
NN=mytrapezoid(t,nst,ndur,nramp);
UU=mytrapezoid(t,nst,ndur,nramp);

% conversion factors
cm2m=1e-2;
m2cm=1/cm2m;
mmHg2Pa=133.32;
Pa2mmHg=1/133.32;
ml2m3=1e-6;
m32ml=1/ml2m3;
min2sec=1/60;
sec2min=60;
opt1min=optimset('fminbnd');

% oxygen extraction parameters
%  important units to maintain mmol/L
alpha_o2=1.39e-3;	% units: mmol/L/mmHg
P50_o2=26;		% units: mmHg
hill=2.73;
cHb=2.3;		% units: mmol/L
PO=4;
PS=7200;		% units: ml/min
Hparms = [cHb PO alpha_o2 P50_o2 hill];

% define o2 tensions/concentrations
Vc=1;			% units: ml (this we could verify below)
Vt=96;			% unitsL ml
Pa_o2=90;		% units: mmHg
Pt_o2=20;		% units: mmHg
Cpa=Pa_o2*alpha_o2;
Ca=Cpa+(cHb*PO)/(1+((P50_o2/Pa_o2)^hill));
Ct=Pt_o2*alpha_o2;

% more input parameters
camp=0.2;
dtau=2;
damp=0.1;
 
% blood flow parameters
%  important units to maintain m3/s (metric)
mu=0.004;		% units: cP (metric)
grubb=0.4;

% flow paramters
F0=50*ml2m3*min2sec;	% units: m3/sec
F1=50*ml2m3*min2sec;	% units: m3/sec
F2=50*ml2m3*min2sec;	% units: m3/sec
F3=50*ml2m3*min2sec;	% units: m3/sec

% other vascular parameters
D1=200e-6;		% units: m
L1=1e-1;		% units: m
D2=20e-6;		% units: m
L2=1e-1;		% units: m
D3=400e-6;		% units: m
L3=2e-1;		% units: m

% define input arterial and output end-venous pressures
Pi=50*mmHg2Pa;
Po=4*mmHg2Pa;
P0=0*mmHg2Pa;

% define end-arteriole, end-capillary and end-venuole pressure
P1=20*mmHg2Pa;
P2=10*mmHg2Pa;
P3=5*mmHg2Pa;

% determine Req's and Deq's to satisfy F's
R1eq=(Pi-P1)/F1;
D1eq=(128*mu*L1/(pi*R1eq))^(1/4);
V1=(pi*D1eq*D1eq*L1);
N1=V1/(pi*D1*D1*L1);
R2eq=(P1-P2)/F2;
D2eq=(128*mu*L2/(pi*R2eq))^(1/4);
V2=(pi*D2eq*D2eq*L2);
N2=V2/(pi*D2*D2*L2);
R3eq=(P2-P3)/F3;
D3eq=(128*mu*L3/(pi*R3eq))^(1/4);
V3=(pi*D3eq*D3eq*L3);
N3=V3/(pi*D3*D3*L3);
R4eq=(P3-Po)/F3;

% vascular compliances: elastic, non-elastic and visco-elastic
%  * for c3type=1 (3e-8,2,0.1) works -- no bold post-undershoot
%  * for c3type=2 (1e-8,40,0.001) works
%  * for c3type=2,3 (1e-8,20,0.008,3e-10) works
%  * for c3type=2,3 (1e-8,10,0.030,5e-10) works
%  * for c3type=2 (1e-8,5,0.1) works
c3type=2;
C1=2e-10;
C2=2e-11;
C3=1e-8;
C3k=20;
C3k1=.008;
C3k2=4e-10;

% signal constants
hgamma=42.57*1e-6;	% units: Hz T
B0=3.0;			% units: T
dHb_dchi=1e-6;		% units: ppm*1e-6
sk1=1;
sk2=1;
sb1=4.3*(hgamma*B0*dHb_dchi);
sb2=2.0; sb0=sk1/4;
sb3=0.6;

%
% simulation PART 1: steady-state solutions
%

% oxygen delivery and consumption steady-state solution
% issues:
%   * is tissue tension considered ???
Hparms = [cHb PO alpha_o2 P50_o2 hill];
Cc0 = fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,F2*m32ml*sec2min,Hparms);
CMRO20 = PS*( H_inv(Cc0,Hparms) - Ct );
E0 = 2*(1-Cc0/Ca);
%q0_dHb=(cHb0/1000)*V3_0*(m32ml/1000);
q0_dHb=Ca*E0*F2/(F3/V3);

%
% simulation PART 2: dynamic  solutions
%

CMRO2t=CMRO20*(1+camp*mytrapezoid(t,nst,ndur,nramp));

% initial conditions (some determined in Part 1)
% and numerical integration
D1t(1)=D1eq;
P1t(1)=P1; P2t(1)=P2; P3t(1)=P3;
Q1c(1)=0;  Q2c(1)=0;  Q3c(1)=0;
V1t(1)=V1; V2t(1)=V2; V3t(1)=V3;
CCc(1)=Cc0;
CCt(1)=Ct;
EE(1)=E0; 
q_dHb(1)=q0_dHb;
y(1)=0; 
for mm=2:length(t),

  % arterial input
  y(mm)=y(mm-1)+dt*( (1/dtau)*( UU(mm-1) - y(mm-1) ));
  D1t(mm-1)=D1t(1)*(1+damp*y(mm-1));
  R1t(mm-1)=R1eq*((D1t(1)/D1t(mm-1))^4);

  if (rk_flag),
    yh1=(dt/2)*( (1/dtau)*( mytrapezoid(t(mm-1),nst,ndur,nramp) - y(mm-1) ));
    yh2=(dt/2)*( (1/dtau)*( mytrapezoid(t(mm-1)+dt/4,nst,ndur,nramp) - (y(mm-1)+yh1/2) ));
    yh3=(dt/2)*( (1/dtau)*( mytrapezoid(t(mm-1)+dt/4,nst,ndur,nramp) - (y(mm-1)+yh2/2) ));
    yh4=(dt/2)*( (1/dtau)*( mytrapezoid(t(mm-1)+dt/2,nst,ndur,nramp) - (y(mm-1)+yh3) ));
    yh=y(mm-1)+(yh1/6)+(yh2/3)+(yh3/3)+(yh4/6);
    yk1=dt*( (1/dtau)*( mytrapezoid(t(mm-1),nst,ndur,nramp) - y(mm-1) ));
    yk2=dt*( (1/dtau)*( mytrapezoid(t(mm-1)+dt/2,nst,ndur,nramp) - (y(mm-1)+yk1/2) ));
    yk3=dt*( (1/dtau)*( mytrapezoid(t(mm-1)+dt/2,nst,ndur,nramp) - (y(mm-1)+yk2/2) ));
    yk4=dt*( (1/dtau)*( mytrapezoid(t(mm-1)+dt,nst,ndur,nramp) - (y(mm-1)+yk3) ));
    y(mm)=y(mm-1)+(yk1/6)+(yk2/3)+(yk3/3)+(yk4/6);
    yhh=y(mm);
    R1h=R1eq*((1/(1+damp*yh))^4);
    R1hh=R1eq*((1/(1+damp*yhh))^4);
  end;

  % arterial segment -- elastic
  %PP1(mm-1) = P1t(mm-1) - P0;
  Q1t(mm-1) = ( Pi - P1t(mm-1) )/ R1t(mm-1);
  %C1t(mm) = C1;
  P1t(mm) = P1t(mm-1) + (dt/C1)*( Q1t(mm-1) - (P1t(mm-1)-P2t(mm-1))/R2eq );

  if (rk_flag),
    P1h1=(dt/2)*( (1/C1)*( (Pi-P1t(mm-1))/R1t(mm-1) - (P1t(mm-1)-P2t(mm-1))/R2eq ));
    P1h2=(dt/2)*( (1/C1)*( (Pi-(P1t(mm-1)+P1h1/2))/(0.5*(R1t(mm-1)+R1h)) - ((P1t(mm-1)+P1h1/2)-P2t(mm-1))/R2eq ));
    P1h3=(dt/2)*( (1/C1)*( (Pi-(P1t(mm-1)+P1h2/2))/(0.5*(R1t(mm-1)+R1h)) - ((P1t(mm-1)+P1h2/2)-P2t(mm-1))/R2eq ));
    P1h4=(dt/2)*( (1/C1)*( (Pi-(P1t(mm-1)+P1h3))/R1h - ((P1t(mm-1)+P1h3)-P2t(mm-1))/R2eq ));
    P1h=P1t(mm-1)+(P1h1/6)+(P1h2/3)+(P1h3/3)+(P1h4/6);
    P1k1=dt*( (1/C1)*( (Pi-P1t(mm-1))/R1t(mm-1) - (P1t(mm-1)-P2t(mm-1))/R2eq ));
    P1k2=dt*( (1/C1)*( (Pi-(P1t(mm-1)+P1k1/2))/R1h - ((P1t(mm-1)+P1k1/2)-P2t(mm-1))/R2eq ));
    P1k3=dt*( (1/C1)*( (Pi-(P1t(mm-1)+P1k2/2))/R1h - ((P1t(mm-1)+P1k2/2)-P2t(mm-1))/R2eq ));
    P1k4=dt*( (1/C1)*( (Pi-(P1t(mm-1)+P1k3))/R1hh - ((P1t(mm-1)+P1k3)-P2t(mm-1))/R2eq ));
    P1t(mm)=P1t(mm-1)+(P1k1/6)+(P1k2/3)+(P1k3/3)+(P1k4/6);
    Q1h=(Pi-P1h)/R1h;
    Q1hh=(Pi-P1t(mm))/R1hh;
  end;

  %Q1c(mm) = C1*(P1t(mm)-P1t(mm-1))/dt;
  %V1t(mm) = V1t(1)*((D1t(mm-1)/D1t(1))^2) + C1*( P1t(mm) - P1t(mm-1) );
  V1t(mm) = V1t(mm-1) + C1*( P1t(mm) - P1t(mm-1) );

  % capillary segment -- mildly-elastic
  %PP2(mm-1) = P2t(mm-1) - P0;
  Q2t(mm-1) = ( P1t(mm-1) - P2t(mm-1) )/R2eq;
  %C2t(mm-1) = C2;
  P2t(mm) = P2t(mm-1) + (dt/C2)*( Q2t(mm-1) - (P2t(mm-1)-P3t(mm-1))/R3eq );

  if (rk_flag),
    P2h1=(dt/2)*( (1/C2)*( (P1t(mm-1)-P2t(mm-1))/R2eq - (P2t(mm-1)-P3t(mm-1))/R3eq ));
    P2h2=(dt/2)*( (1/C2)*( (P1t(mm-1)-(P2t(mm-1)+P2h1/2))/R2eq - ((P2t(mm-1)+P2h1/2)-P3t(mm-1))/R3eq ));
    P2h3=(dt/2)*( (1/C2)*( (P1t(mm-1)-(P2t(mm-1)+P2h2/2))/R2eq - ((P2t(mm-1)+P2h2/2)-P3t(mm-1))/R3eq ));
    P2h4=(dt/2)*( (1/C2)*( (P1t(mm-1)-(P2t(mm-1)+P2h3))/R2eq - ((P2t(mm-1)+P2h3)-P3t(mm-1))/R3eq ));
    P2h=P2t(mm-1)+(P2h1/6)+(P2h2/3)+(P2h3/3)+(P2h4/6);
    P2k1=dt*( (1/C2)*( (P1t(mm-1)-P2t(mm-1))/R2eq - (P2t(mm-1)-P3t(mm-1))/R3eq ));
    P2k2=dt*( (1/C2)*( (P1t(mm-1)-(P2t(mm-1)+P2k1/2))/R2eq - ((P2t(mm-1)+P2k1/2)-P3t(mm-1))/R3eq ));
    P2k3=dt*( (1/C2)*( (P1t(mm-1)-(P2t(mm-1)+P2k2/2))/R2eq - ((P2t(mm-1)+P2k2/2)-P3t(mm-1))/R3eq ));
    P2k4=dt*( (1/C2)*( (P1t(mm-1)-(P2t(mm-1)+P2k3))/R2eq - ((P2t(mm-1)+P2k3)-P3t(mm-1))/R3eq ));
    P2t(mm)=P2t(mm-1)+(P2k1/6)+(P2k2/3)+(P2k3/3)+(P2k4/6);
    Q2h=(P1h-P2h)/R2eq;
    Q2hh=(P1t(mm)-P2t(mm))/R2eq;
    V2h=V2t(mm-1)+C2*(P2h-P2t(mm-1));
    V2hh=V2t(mm-1)+C2*(P2t(mm)-P2t(mm-1));
  end;

  %Q2c(mm) = C2*(P2t(mm)-P2t(mm-1))/dt;
  V2t(mm) = V2t(mm-1) + C2*( P2t(mm) - P2t(mm-1) );

  % oxygen delivery and consumption 
  %    assumed linear extraction along capillary
  %    assumed constant volume in the capillary
  AA = PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1) );
  BB = 2.0*Q2t(mm-1)*m32ml*sec2min*( Ca - CCc(mm-1) );
  CCt(mm) = CCt(mm-1) + (dt*sec2min/Vt)*( AA - CMRO2t(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt*sec2min/Vc)*( BB - AA );
  if (rk_flag),
    CMRO2a=CMRO20*(1+camp*mytrapezoid(t(mm-1),nst,ndur,nramp));
    CMRO2b=CMRO20*(1+camp*mytrapezoid(t(mm-1)+dt/2,nst,ndur,nramp));
    CMRO2c=CMRO20*(1+camp*mytrapezoid(t(mm-1)+dt,nst,ndur,nramp));
    Ctk1=dt*sec2min*(1/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2a );
    Ctk2=dt*sec2min*(1/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk1/2) ) - CMRO2b );
    Ctk3=dt*sec2min*(1/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk2/2) ) - CMRO2b );
    Ctk4=dt*sec2min*(1/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk3) ) - CMRO2c );
    CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;
    Q2a=Q2t(mm-1)*m32ml*sec2min;
    Q2b=Q2h*m32ml*sec2min;
    Q2b=Q2hh*m32ml*sec2min;
    Cck1=dt*sec2min*(1/Vc)*( Q2a*2*(Ca-CCc(mm-1)) - PS*(H_inv(CCc(mm-1),Hparms)-CCt(mm-1)) );
    Cck2=dt*sec2min*(1/Vc)*( Q2b*2*(Ca-(CCc(mm-1)+Cck1/2)) - PS*(H_inv(CCc(mm-1)+Cck1/2,Hparms)-CCt(mm-1)) );
    Cck3=dt*sec2min*(1/Vc)*( Q2b*2*(Ca-(CCc(mm-1)+Cck2/2)) - PS*(H_inv(CCc(mm-1)+Cck2/2,Hparms)-CCt(mm-1)) );
    Cck4=dt*sec2min*(1/Vc)*( Q2c*2*(Ca-(CCc(mm-1)+Cck3)) - PS*(H_inv(CCc(mm-1)+Cck3,Hparms)-CCt(mm-1)) );
   CCc(mm) = CCc(mm-1) + Cck1/6 + Cck2/3 + Cck2/3 + Cck4/6;
  end;
  EE(mm) = 2*( 1 - CCc(mm)/Ca );
  EEb(mm-1) = 1 - (1-E0)^(Q2t(1)/Q2t(mm-1));

  % venous segment -- visco-elastic
  PP3(mm-1) = P3t(mm-1) - P0;
  Q3t(mm-1) = ( P2t(mm-1) - P3t(mm-1) )/R3eq;
  C3t(mm-1) = C3;

  if (c3type==2),
    C3t(mm-1) = (V3t(1)/C3k)*( 1/( PP3(mm-1) - PP3(1) + C3k1*PP3(1) ) );
    P3t(mm) = P3t(mm-1) + (dt/C3t(mm-1))*( Q3t(mm-1) - (P3t(mm-1)-Po)/R4eq );
    if (rk_flag2),
      C3a=(V3t(1)/C3k)*( 1/( PP3(mm-1) - PP3(1) + C3k1*PP3(1) ) );
      P3k1=(dt/2)*( (1/C3a)*( (P2t(mm-1)-P3t(mm-1))/R3eq - (P3t(mm-1)-Po)/R4eq ));
      C3b=(V3t(1)/C3k)*( 1/( PP3(mm-1)+P3k1/2 - PP3(1) + C3k1*PP3(1) ));
      P3k2=(dt/2)*( (1/C3b)*( (P2t(mm-1)-(P3t(mm-1)+P3k1/2))/R3eq - ((P3t(mm-1)+P3k1/2)-Po)/R4eq ));
      C3c=(V3t(1)/C3k)*( 1/( PP3(mm-1)+P3k2/2 - PP3(1) + C3k1*PP3(1) ));
      P3k3=(dt/2)*( (1/C3c)*( (P2t(mm-1)-(P3t(mm-1)+P3k2/2))/R3eq - ((P3t(mm-1)+P3k2/2)-Po)/R4eq ));
      C3d=(V3t(1)/C3k)*( 1/( PP3(mm-1)+P3k3 - PP3(1) + C3k1*PP3(1) ));
      P3k4=(dt/2)*( (1/C3d)*( (P2t(mm-1)-(P3t(mm-1)+P3k3))/R3eq - ((P3t(mm-1)+P3k3)-Po)/R4eq ));
      P3h=P3t(mm-1)+(P3k1/6)+(P3k2/3)+(P3k3/3)+(P3k4/6);
      V3h=(V3t(1)/C3k)*log( (1/C3k1)*( (P3h-P0)/PP3(1) - 1) + 1 ) + V3t(1);
      C3a=(V3t(1)/C3k)*( 1/( PP3(mm-1) - PP3(1) + C3k1*PP3(1) ) );
      P3k1=dt*( (1/C3a)*( (P2t(mm-1)-P3t(mm-1))/R3eq - (P3t(mm-1)-Po)/R4eq ));
      C3b=(V3t(1)/C3k)*( 1/( PP3(mm-1)+P3k1/2 - PP3(1) + C3k1*PP3(1) ));
      P3k2=dt*( (1/C3b)*( (P2t(mm-1)-(P3t(mm-1)+P3k1/2))/R3eq - ((P3t(mm-1)+P3k1/2)-Po)/R4eq ));
      C3c=(V3t(1)/C3k)*( 1/( PP3(mm-1)+P3k2/2 - PP3(1) + C3k1*PP3(1) ));
      P3k3=dt*( (1/C3c)*( (P2t(mm-1)-(P3t(mm-1)+P3k2/2))/R3eq - ((P3t(mm-1)+P3k2/2)-Po)/R4eq ));
      C3d=(V3t(1)/C3k)*( 1/( PP3(mm-1)+P3k3 - PP3(1) + C3k1*PP3(1) ));
      P3k4=dt*( (1/C3d)*( (P2t(mm-1)-(P3t(mm-1)+P3k3))/R3eq - ((P3t(mm-1)+P3k3)-Po)/R4eq ));
      P3t(mm)=P3t(mm-1)+(P3k1/6)+(P3k2/3)+(P3k3/3)+(P3k4/6);
    end;
    V3t(mm) = (V3t(1)/C3k)*log( (1/C3k1)*( (P3t(mm)-P0)/PP3(1) - 1) + 1 ) + V3t(1);
  elseif (c3type==3),
    C3t(mm-1) = (V3t(1)/C3k)*( 1/( PP3(mm-1) - PP3(1) + C3k1*PP3(1) ) );
    if (mm>2),
      dPP3dt(mm-1) = (PP3(mm-1)-PP3(mm-2))/dt; dPP3dt(1)=0;
      dPP3dt2(mm-1)=dPP3dt(mm-1);
      if (dPP3dt(mm-1)<0), dPP3dt2(mm-1)=-dPP3dt(mm-1); end;
      iP3dP(mm-1)=trapz(PP3(1:mm-1),dPP3dt2(1:mm-1));
      C3t(mm-1) = C3t(mm-1) + C3k2*dPP3dt(mm-1);
      V3dP=C3k2*iP3dP(mm-1);
    else,
      V3dP=0;
    end;
    P3t(mm) = P3t(mm-1) + (dt/C3t(mm-1))*( Q3t(mm-1) - (P3t(mm-1)-Po)/R4eq );
    V3t(mm) = (V3t(1)/C3k)*log( (1/C3k1)*( (P3t(mm)-P0)/PP3(1) - 1) + 1 ) + V3t(1);
    V3t(mm) = V3t(mm) + V3dP;
    if (rk_flag2),
      % not sure about the error here
    end;
  else,
    P3t(mm) = P3t(mm-1) + (dt/C3)*( Q3t(mm-1) - (P3t(mm-1)-Po)/R4eq );
    if (rk_flag2),
      P3h1=(dt/2)*( (1/C3)*( (P2t(mm-1)-P3t(mm-1))/R3eq - (P3t(mm-1)-Po)/R4eq ));
      P3h2=(dt/2)*( (1/C3)*( (P2t(mm-1)-(P3t(mm-1)+P3h1/2))/R3eq - ((P3t(mm-1)+P3h1/2)-Po)/R4eq ));
      P3h3=(dt/2)*( (1/C3)*( (P2t(mm-1)-(P3t(mm-1)+P3h2/2))/R3eq - ((P3t(mm-1)+P3h2/2)-Po)/R4eq ));
      P3h4=(dt/2)*( (1/C3)*( (P2t(mm-1)-(P3t(mm-1)+P3h3))/R3eq - ((P3t(mm-1)+P3h3)-Po)/R4eq ));
      P3h=P3t(mm-1)+(P3h1/6)+(P3h2/3)+(P3h3/3)+(P3h4/6);
      V3h=V3t(mm-1)+C3*(P3h-P3t(mm-1));
      P3k1=dt*( (1/C3)*( (P2t(mm-1)-P3t(mm-1))/R3eq - (P3t(mm-1)-Po)/R4eq ));
      P3k2=dt*( (1/C3)*( (P2h-(P3t(mm-1)+P3k1/2))/R3eq - ((P3t(mm-1)+P3k1/2)-Po)/R4eq ));
      P3k3=dt*( (1/C3)*( (P2h-(P3t(mm-1)+P3k2/2))/R3eq - ((P3t(mm-1)+P3k2/2)-Po)/R4eq ));
      P3k4=dt*( (1/C3)*( (P2t(mm)-(P3t(mm-1)+P3k3))/R3eq - ((P3t(mm-1)+P3k3)-Po)/R4eq ));
      P3t(mm)=P3t(mm-1)+(P3k1/6)+(P3k2/3)+(P3k3/3)+(P3k4/6);
    end;
    V3t(mm) = V3t(mm-1) + C3*( P3t(mm) - P3t(mm-1) ); 
  end;
  if (C3t(mm-1)<=0), disp('Warning: C3 < 0 !!!'); C3t(mm-1)=C3t(mm-2); end;
  Q3c(mm) = C3t(mm-1)*( P3t(mm) - P3t(mm-1) )/dt;

  % end-venous considerations ???
  Q4t(mm-1) = ( P3t(mm-1) - Po )/R4eq;

  % amount of deoxy-hemoglobin
  DD1 = Ca*EEb(mm-1)*V2t(1) * Q2t(mm-1)/V2t(mm-1);
  DD2 = Q3t(mm-1)/V3t(mm-1);
  q_dHb(mm) = q_dHb(mm-1) + dt*( DD1 - q_dHb(mm-1)*DD2 );
  if (rk_flag3),
    qk1=dt*( Ca*EEb(mm-1)*V2t(1)*Q2t(mm-1)/V2t(mm-1) - q_dHb(mm-1)*Q3t(mm-1)/V3t(mm-1) );
    qk2=dt*( Ca*EEb(mm-1)*V2t(1)*Q2t(mm-1)/V2t(mm-1) - (q_dHb(mm-1)+qk1/2)*Q3t(mm-1)/V3t(mm-1) );
    qk3=dt*( Ca*EEb(mm-1)*V2t(1)*Q2t(mm-1)/V2t(mm-1) - (q_dHb(mm-1)+qk2/2)*Q3t(mm-1)/V3t(mm-1) );
    qk4=dt*( Ca*EEb(mm-1)*V2t(1)*Q2t(mm-1)/V2t(mm-1) - (q_dHb(mm-1)+qk3)*Q3t(mm-1)/V3t(mm-1) );
    q_dHb(mm)=q_dHb(mm-1)+(qk1/6)+(qk2/3)+(qk3/3)+(qk4/6);
  end;

  % BOLD signal estimation
  St(mm-1) = sk1*( 1 - sk2*q_dHb(mm-1)/q_dHb(1) );
  St2(mm-1) = sb0*( sb1*E0*( 1 - (q_dHb(mm-1)/q_dHb(1)) ) + sb2*( 1 - (q_dHb(mm-1)/q_dHb(1))/(V3t(mm-1)/V3t(1)) ) + sb3*( 1 - (V3t(mm-1)/V3t(1)) ) );
 
end;
Q1t(mm)=Q1t(mm-1);
Q2t(mm)=Q2t(mm-1);
Q3t(mm)=Q3t(mm-1);
Q4t(mm)=Q4t(mm-1);
C3t(mm)=C3t(mm-1);
EEb(mm)=EEb(mm-1);
St(mm)=St(mm-1);
St2(mm)=St2(mm-1);


if (doplots),
  figure(1)
  plot(t,[NN' UU' y'])
  ylabel('Amplitude')
  xlabel('Time (s)')
  grid('on'), axis('tight'),
  legend('N','U','y')
  figure(2)
  subplot(211)
  plot(t,Q1t/Q1t(1),t,Q2t/Q2t(1),t,Q3t/Q3t(1),t,Q4t/Q4t(1))
  ylabel('Flow Change')
  grid('on'), axis('tight'),
  title(sprintf('Initial Q_{art} Q_{cap} Q_{ven} Q_{endven} = %4.2f %4.2f %4.2f %4.2f ml/min',Q1t(1)*sec2min*m32ml,Q2t(1)*sec2min*m32ml,Q3t(1)*sec2min*m32ml,Q4t(1)*sec2min*m32ml))
  legend('Art','Cap','Ven','end-Ven')
  subplot(212)
  plot(t,V1t/V1t(1),t,V2t/V2t(1),t,V3t/V3t(1))
  ylabel('Volume Change')
  xlabel('Time (s)')
  grid('on'), axis('tight'),
  title(sprintf('Initial V_{art} V_{cap} V_{ven} = %4.2f %4.2f %4.2f ml',V1t(1)*m32ml,V2t(1)*m32ml,V3t(1)*m32ml))
  legend('Art','Cap','Ven')
  figure(3)
  subplot(211)
  plot(V1t/V1t(1),P1t/P1t(1),V2t/V2t(1),P2t/P2t(1),V3t/V3t(1),P3t/P3t(1))
  ylabel('Norm. Pressure')
  xlabel('Norm. Volume')
  grid('on'), axis('tight'),
  legend('Art','Cap','Ven')
  subplot(212)
  plot(t,C3t)
  ylabel('Compliance (m3/Pa)')
  xlabel('Time (s)')
  grid('on'), axis('tight'),
  legend('Ven')
  figure(4)
  subplot(211)
  plot(t,EEb)
  ylabel('O_2 Extraction')
  grid('on'), axis('tight'),
  legend('Cap')
  subplot(212)
  plot(t,q_dHb)
  ylabel('Ven Deoxy-Hb Amt (mmol)')
  xlabel('Time (s)')
  grid('on'), axis('tight'),
  figure(5)
  plot(t,St,t,St2)
  ylabel('BOLD Amplitude')
  xlabel('Time (s)')
  grid('on'), axis('tight'),
  legend('Simple','Buxton')
end;

