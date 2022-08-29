function [S,F2,F4,V3,CMRO2,EE,q,u2,t,u4,CCt,CCc]=myBOLD(x,tparms,sparms,parms2fit_i,data,tdata)
% Usage ... [S,Fin,Fout,V,CMRO2,EE,q,t]=myBOLD(x,tparms,sparms,parms2fit_i,data,tdata)
%
% x = parameters to fit
% tparms = [dt T]
% sparms = [itype ist idur iramp ftau famp camp F0 V0 Vk1 P50 Vc Va PS Pa Pt Sk1 Sk2]
% parms2fit = index#'s of sparms that correspond to x
% data is in columns = [BOLD CBF]
% tdata is the time vector corresponding to data

% Example: tparms=[1/(60*20) 2]
% Example: sparms=[1 3.5/60 11.5/60 0.5/60 2/60 0.62 0.24 50 1 0.2 26 1 96 7200 90 20 0.5 1]

% L1,3=3e-2 might be more realistic then C1=4e-11 and C3=???
% also pressures of 50-30-20-15-10 and 5 outside
% to avoid the art-flow response from looking funky we need L1=5e-3 C1=1e-12

if (~isempty(x)),
  sparms(parms2fit_i)=x;
end;

opt1min=optimset('fminbnd');
RK_flag=1;
plots_flag=2;
ftype=2;
ytype=sparms(1);	% 14
ytype=[14 0 1.5/60];

cm2m=1e-2;
m2cm=1/cm2m;
mmHg2Pa=133.32;
Pa2mmHg=1/133.32;
ml2m3=1e-6;
m32ml=1/ml2m3;
min2sec=1/60;
sec2min=60;

Namp=sparms(19);
Ntau=sparms(20);
kn=sparms(21);
nctype=sparms(22);
if (length(sparms)<23),
  cn=kn;
else,
  cn=sparms(23);
end;
ytype(2)=Namp; ytype(3)=Ntau; u2(1)=0;

grubb=0.4;
mu=0.004;

dt=tparms(1);
T=tparms(2);
t=[0:dt:T];


L1=1e-2;
L2=1e-1;
L3=1e-2;

Pi=50*mmHg2Pa;
P1=20*mmHg2Pa;
P2=10*mmHg2Pa;
P3=5*mmHg2Pa;
Po=4*mmHg2Pa;
P0=0*mmHg2Pa;

C1=7e-12;
C2=2e-11;
C3=7e-11;
C3k=65;
C3k1=.0001;
C3k2=+0e-0;
c3type=2;


F0=sparms(8);	% 50
V0=sparms(9);	% 1
Vk0=0.35;
Vk1=20;
Vk2=0.0080;
Vk3=sparms(10);	% 0.20
ctype=4;


yst=3.5/60+dt; ydur=11.5/60; yramp=[.5/60 .5/60];
ytau=3/60;
yamp=0.25;
y2st=sparms(2); y2dur=sparms(3); y2ramp=sparms(4);	% 3.5/60 11.5/60 0.5/60
y2tau=sparms(5);		% 2/60
y2amp=sparms(6);		% 0.62

cstart=sparms(2); cdur=sparms(3); cramp=sparms(4);
%cstart=15/60+dt; cdur=09/60; cramp=12/60;
camp=sparms(7);


alpha=1.39e-3;
P50=sparms(11);		% 26
hill=2.73;
cHb=2.3;
PO=4;

Vc=sparms(12);		% 1
Vct=sparms(13);		% 98
PS=sparms(14);		% 7200
Pa=sparms(15);		% 90
Pt=sparms(16);		% 20

% Vt+Vc+Va+Vv=100;
Vt=Vct-Vc;
PS=PS*sqrt(Vc/1.0);

Cpa=Pa*alpha;
Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
Ct=Pt*alpha;
Hparms = [cHb PO alpha P50 hill];
Cc = fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,F0,Hparms);
CMRO20 = PS*( H_inv(Cc,Hparms) - Ct );
E0 = 2*(1-Cc/Ca);

CMRO2=CMRO20*(1+camp*mytrapezoid2(t,cstart,cdur,cramp,ytype));

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

Ek1=1.0;

sk1=sparms(17);		% 0.5
sk2=sparms(18);		% 1
sb1=4.3*(42.57*1e-6*3.0*1.0e-6);
sb2=2.0; sb0=sk1/4;
sb3=0.6;

y(1)=0; y2(1)=0; y3(1)=0; u4(1)=0;
VV(1)=V0; Fin(1)=F0; Fout(1)=F0;
CCt(1)=Ct; CCc(1)=Cc; EE(1)=E0;
q(1)=Ca*E0*V3*m32ml; qs(1)=q(1); qb(1)=q(1); qn(1)=q(1);
qB(1)=Ca*E0*V0; qBs(1)=qB(1); qBb(1)=qB(1); qBn(1)=qB(1);
for mm=2:length(t),

  y(mm) = y(mm-1) + dt*( (1/ytau)*( mytrapezoid2(t(mm-1),yst,ydur,yramp,ytype) - y(mm-1) ));
 
  D1(mm-1) = D1eq*(1+yamp*y(mm-1));
  R1eq(mm-1) = R1eq(1)*((D1(1)/D1(mm-1))^4);

  if (c3type==2),
    C3(mm-1) = (V3(1)/C3k)*( 1/( P3(mm-1) - P3(1) + C3k1*(P3(1)-P0) ));
    V3dP=0;
  elseif (c3type==3),
    C3(mm-1) = (V3(1)/C3k)*( 1/( P3(mm-1) - P3(1) + C3k1*(P3(1)-P0) ));
    if (mm>2),
      dPP3dt(mm-1) = (P3(mm-1)-P3(mm-2))/dt; dPP3dt(1)=0;
      %C3(mm-1) = C3(mm-1) + C3k2*dPP3dt(mm-1);
      %C3(mm-1) = C3(mm-1) - C3k2*abs(dPP3dt(mm-1)^(1/3));%*sign(dPP3dt(mm-1));
      C3(mm-1) = C3(mm-1) - C3k2*(dPP3dt(mm-1)^3);
      dPP3dt2(mm-1)=dPP3dt(mm-1);
      if (dPP3dt(mm-1)<0), dPP3dt2(mm-1)=-dPP3dt(mm-1); end;
      iP3dP(mm-1)=trapz(P3(1:mm-1)-P0,dPP3dt2(1:mm-1));
      V3dP=C3k2*iP3dP(mm-1);
    end;
  elseif (c3type==4),
    y3(mm)=y3(mm-1)+dt*( (1/C3tau)*( mytrapezoid2(t(mm-1),yst,ydur,yramp,ytype) - y3(mm-1) ));
    C3(mm-1) = C30*(1+C3amp*y3(mm-1));
    V3dP=0;
  else,
    C3(mm-1) = C30;
    V3dP=0;
  end;

  P1(mm) = P1(mm-1) + dt*( (1/C1)*( (Pi-P1(mm-1))/R1eq(mm-1) - (P1(mm-1)-P2(mm-1))/R2eq ));
  P2(mm) = P2(mm-1) + dt*( (1/C2)*( (P1(mm-1)-P2(mm-1))/R2eq - (P2(mm-1)-P3(mm-1))/R3eq ));
  P3(mm) = P3(mm-1) + dt*( (1/C3(mm-1))*( (P2(mm-1)-P3(mm-1))/R3eq - (P3(mm-1)-Po)/R4eq ));

  V1(mm) = V1(mm-1) + C1*( P1(mm)-P1(mm-1) );
  V2(mm) = V2(mm-1) + C2*( P2(mm)-P2(mm-1) );
  V3(mm) = V3(mm-1) + C3(mm-1)*( P3(mm)-P3(mm-1) );
  %V3(mm) = (V3(1)/C3k)*log( (1/C3k1)*( (P3(mm)-P0)/(P3(1)-P0) - 1) + 1) + V3(1);
  %V3(mm) = (V3(1)/C3k)*log( (1/C3k1)*( (P3(mm)-P0)/(P3(1)-P0) - 1) + 1) + V3(1) + V3dP;

  F1(mm-1) = (Pi-P1(mm-1))/R1eq(mm-1);
  F2(mm-1) = (P1(mm-1)-P2(mm-1))/R2eq;
  F3(mm-1) = (P2(mm-1)-P3(mm-1))/R3eq;
  F4(mm-1) = (P3(mm-1)-Po)/R4eq;

  if (RK_flag),
    yh = y(mm-1) + (dt/2)*(1/ytau)*( mytrapezoid2(t(mm-1),yst,ydur,yramp,ytype) - y(mm-1) );
    R1h = R1eq*((1/(1+yamp*yh))^4);
    R1hh = R1eq*((1/(1+yamp*y(mm)))^4);
    P1h = P1(mm-1) + (dt/2)*( (1/C1)*( (Pi-P1(mm-1))/R1eq(mm-1) - (P1(mm-1)-P2(mm-1))/R2eq ));
    P2h = P2(mm-1) + (dt/2)*( (1/C2)*( (P1(mm-1)-P2(mm-1))/R2eq - (P2(mm-1)-P3(mm-1))/R3eq ));
    F2h = (P1h-P2h)/R2eq;
    F2hh = (P1(mm)-P2(mm))/R2eq;
    P3h = P3(mm-1) + (dt/2)*( (1/C3(mm-1))*( (P2(mm-1)-P3(mm-1))/R3eq - (P3(mm-1)-Po)/R4eq ));
  end;



  u2(mm) = u2(mm-1) + dt*( (1/kn)*( mytrapezoid2(t(mm-1),y2st,y2dur,y2ramp,ytype) - u2(mm-1) )); 
  u4(mm) = u4(mm-1) + dt*( (1/cn)*( mytrapezoid2(t(mm-1),y2st,y2dur,y2ramp,ytype) - u4(mm-1) )); 
  if (RK_flag),
    k1u2=dt*(1/kn)*(mytrapezoid2(t(mm-1),y2st,y2dur,y2ramp,ytype)-u2(mm-1));
    k2u2=dt*(1/kn)*(mytrapezoid2(t(mm-1)+dt/2,y2st,y2dur,y2ramp,ytype)-(u2(mm-1)+k1u2/2));
    k3u2=dt*(1/kn)*(mytrapezoid2(t(mm-1)+dt/2,y2st,y2dur,y2ramp,ytype)-(u2(mm-1)+k2u2/2));
    k4u2=dt*(1/kn)*(mytrapezoid2(t(mm-1)+dt,y2st,y2dur,y2ramp,ytype)-(u2(mm-1)+k3u2));
    u2(mm)=u2(mm-1)+k1u2/6+k2u2/3+k3u2/3+k4u2/6;

    k1u4=dt*(1/cn)*(mytrapezoid2(t(mm-1),y2st,y2dur,y2ramp,ytype)-u4(mm-1));
    k2u4=dt*(1/cn)*(mytrapezoid2(t(mm-1)+dt/2,y2st,y2dur,y2ramp,ytype)-(u4(mm-1)+k1u4/2));
    k3u4=dt*(1/cn)*(mytrapezoid2(t(mm-1)+dt/2,y2st,y2dur,y2ramp,ytype)-(u4(mm-1)+k2u4/2));
    k4u4=dt*(1/cn)*(mytrapezoid2(t(mm-1)+dt,y2st,y2dur,y2ramp,ytype)-(u4(mm-1)+k3u4));
    u4(mm)=u4(mm-1)+k1u4/6+k2u4/3+k3u4/3+k4u4/6;
  end;

  y2(mm) = y2(mm-1) + dt*( (1/y2tau)*( u2(mm-1) - y2(mm-1) ));
  Fin(mm-1) = F0*( 1 + y2amp*y2(mm-1) );
  Fin(mm) = F0*( 1 + y2amp*y2(mm) );
  if (RK_flag),
    y2h = y2(mm-1) + (dt/2)*( (1/y2tau)*( u2(mm-1) - y2(mm-1) ));
    Finh = 0.5*(Fin(mm-1)+Fin(mm));
    Finhh= Fin(mm);
  end;

  if (ctype==2),
    Fout(mm-1) = F0*( Vk2*(exp(Vk1*(VV(mm-1)/V0-1))-1)+1 );
    VV(mm) = VV(mm-1) + dt*( Fin(mm-1) - Fout(mm-1) );
  elseif (ctype==3),
    VV(mm) = VV(mm-1) + dt*(1/(1+F0*Vk3))*( Fin(mm-1) - F0*(Vk2*(exp(Vk1*(VV(mm-1)/V0-1))-1)+1) );
    Fout(mm) = Fin(mm) - (1/dt)*( VV(mm)-VV(mm-1) );
  elseif (ctype==4),
    VV(mm) = VV(mm-1) + dt*(1/(1+F0*Vk3))*( Fin(mm-1) - F0*((VV(mm-1)/V0)^(1/grubb)) );
    Fout(mm) = Fin(mm) - (1/dt)*( VV(mm)-VV(mm-1) );
  else,
    Fout(mm-1) = F0*( (VV(mm-1)/V0)^(1/grubb) );
    VV(mm) = VV(mm-1) + dt*( Fin(mm-1) - Fout(mm-1) );
  end;
  
  if (nctype==1),
    CMRO2(mm-1)=CMRO20*(1+camp*u2(mm-1));
  elseif (nctype==2),
    CMRO2(mm-1)=CMRO20*(1+camp*y2(mm-1));
  elseif (nctype==3),
    CMRO2(mm-1)=CMRO20*(1+camp*u4(mm-1));
  end;

  CCt(mm) = CCt(mm-1) + (dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2(mm-1) );

  A =  F2(mm-1)*2*( Ca - CCc(mm-1) );
  B =  PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt/Vc)*( A - B );

  if (RK_flag),
    if (nctype==0),
      CMRO2a=CMRO20*(1+camp*mytrapezoid2(t(mm-1),cstart,cdur,cramp,ytype));
      CMRO2b=CMRO20*(1+camp*mytrapezoid2(t(mm-1)+dt/2,cstart,cdur,cramp,ytype));
      CMRO2c=CMRO20*(1+camp*mytrapezoid2(t(mm-1)+dt,cstart,cdur,cramp,ytype));
    elseif (nctype==2),
      CMRO2a=CMRO20*(1+camp*y2(mm-1));
      CMRO2b=CMRO20*(1+camp*(y2(mm-1)+y2(mm))*0.5);
      CMRO2c=CMRO20*(1+camp*y2(mm));
    elseif (nctype==3),
      CMRO2a=CMRO20*(1+camp*u4(mm-1));
      CMRO2b=CMRO20*(1+camp*(u4(mm-1)+u4(mm))*0.5);
      CMRO2c=CMRO20*(1+camp*u4(mm));
    else,
      CMRO2a=CMRO20*(1+camp*u2(mm-1));
      CMRO2b=CMRO20*(1+camp*(u2(mm-1)+u2(mm))*0.5);
      CMRO2c=CMRO20*(1+camp*u2(mm));
    end;
    Ctk1=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2a );
    Ctk2=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk1/2) ) - CMRO2b );
    Ctk3=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk2/2) ) - CMRO2b );
    Ctk4=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk3) ) - CMRO2c );
    CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;

    if (ftype==2),
      Fa=Fin(mm-1);
      Fb=Finh;
      Fc=Finhh;
    else,
      Fa=F2(mm-1)*m32ml*sec2min;
      Fb=F2h*m32ml*sec2min;
      Fc=F2hh*m32ml*sec2min;
    end;
    Cck1=(dt/Vc)*( Fa*2*(Ca-CCc(mm-1)) - PS*(H_inv(CCc(mm-1),Hparms)-CCt(mm-1)) );
    Cck2=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck1/2)) - PS*(H_inv(CCc(mm-1)+Cck1/2,Hparms)-CCt(mm-1)) );
    Cck3=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck2/2)) - PS*(H_inv(CCc(mm-1)+Cck2/2,Hparms)-CCt(mm-1)) );
    Cck4=(dt/Vc)*( Fc*2*(Ca-(CCc(mm-1)+Cck3)) - PS*(H_inv(CCc(mm-1)+Cck3,Hparms)-CCt(mm-1)) );
    CCc(mm) = CCc(mm-1) + Cck1/6 + Cck2/3 + Cck2/3 + Cck4/6;
  end;

  EE(mm) = 2*( 1 - CCc(mm)/Ca );
  EE(mm)=EE(1)*( Ek1*(EE(mm)/EE(1)-1) +1);

  if (ftype==2),
    [EEs(mm-1),CMRO2s(mm-1)]=valabregue3ff(Fin(mm-1),PS,Pt,Pa);
  else,
    [EEs(mm-1),CMRO2s(mm-1)]=valabregue3ff(F2(mm-1)*m32ml*sec2min,PS,Pt,Pa);
  end;
  %EEs(mm-1)=EEs(1)*( 1.3*(EEs(mm-1)/EEs(1)-1) +1);
  %EEn(mm-1)=EE(1);

  EEb(mm-1) = 1 - (1-E0)^(F3(1)/F3(mm-1));
  EEb2(mm-1) = 1 - (1-E0)^(Fin(1)/Fin(mm-1));



  %q(mm) = q(mm-1) + dt*sec2min*( Ca*EE(mm-1)*m32ml*F2(mm-1)*V2(1)/V2(mm-1) - q(mm-1)*F3(mm-1)/V3(mm-1) );
  %qs(mm) = qs(mm-1) + dt*sec2min*( Ca*EEs(mm-1)*m32ml*F2(mm-1)*V2(1)/V2(mm-1) - qs(mm-1)*F3(mm-1)/V3(mm-1) );
  %qb(mm) = qb(mm-1) + dt*sec2min*( Ca*EEb(mm-1)*m32ml*F2(mm-1)*V2(1)/V2(mm-1) - qb(mm-1)*F3(mm-1)/V3(mm-1) );
  %qn(mm) = qn(mm-1) + dt*sec2min*( Ca*EEn(mm-1)*m32ml*F2(mm-1)*V2(1)/V2(mm-1) - qn(mm-1)*F3(mm-1)/V3(mm-1) );

  q(mm) = q(mm-1) + dt*sec2min*( Ca*EE(mm-1)*m32ml*F3(mm-1)*V2(1)/V2(mm-1) - q(mm-1)*F4(mm-1)/V3(mm-1) );
  qs(mm) = qs(mm-1) + dt*sec2min*( Ca*EEs(mm-1)*m32ml*F3(mm-1)*V2(1)/V2(mm-1) - qs(mm-1)*F4(mm-1)/V3(mm-1) );
  qb(mm) = qb(mm-1) + dt*sec2min*( Ca*EEb(mm-1)*m32ml*F3(mm-1)*V2(1)/V2(mm-1) - qb(mm-1)*F4(mm-1)/V3(mm-1) );

  qB(mm) = qB(mm-1) + dt*( Ca*EE(mm-1)*Fin(mm-1) - qB(mm-1)*Fout(mm-1)/VV(mm-1) );
  qBs(mm) = qBs(mm-1) + dt*( Ca*EEs(mm-1)*Fin(mm-1) - qBs(mm-1)*Fout(mm-1)/VV(mm-1) );
  qBb(mm) = qBb(mm-1) + dt*( Ca*EEb2(mm-1)*Fin(mm-1) - qBb(mm-1)*Fout(mm-1)/VV(mm-1) );
  %qBn(mm) = qBn(mm-1) + dt*( Ca*EEn(mm-1)*Fin(mm-1) - qBn(mm-1)*Fout(mm-1)/VV(mm-1) );



  S(mm-1) = 1 + sk1*( 1 - sk2*q(mm-1)/q(1) );
  Ss(mm-1) = 1 + sk1*( 1 - sk2*qs(mm-1)/qs(1) );
  Sb(mm-1) = 1 + sk1*( 1 - sk2*qb(mm-1)/qb(1) );
  %Sn(mm-1) = 1 + sk1*( 1 - sk2*qn(mm-1)/qn(1) );

  SB(mm-1) = 1 + sk1*( 1 - sk2*(qB(mm-1)/qB(1))^1.5 );
  SBs(mm-1) = 1 + sk1*( 1 - sk2*(qBs(mm-1)/qBs(1))^1.5 );
  SBb(mm-1) = 1 + sk1*( 1 - sk2*(qBb(mm-1)/qBb(1))^1.5 );
  %SBn(mm-1) = 1 + sk1*( 1 - sk2*(qBn(mm-1)/qBn(1))^1.5 );


  SS(mm-1) = 1 + sb0*( sb1*E0*( 1 - q(mm-1)/q(1) ) + sb2*( 1 - (q(mm-1)/q(1))/(V3(mm-1)/V3(1)) ) + sb3*( 1 - V3(mm-1)/V3(1) ) );
  SSs(mm-1) = 1 + sb0*( sb1*E0*( 1 - qs(mm-1)/qs(1) ) + sb2*( 1 - (qs(mm-1)/qs(1))/(V3(mm-1)/V3(1)) ) + sb3*( 1 - V3(mm-1)/V3(1)) );
  SSb(mm-1) = 1 + sb0*( sb1*E0*( 1 - qb(mm-1)/qb(1) ) + sb2*( 1 - (qb(mm-1)/qb(1))/(V3(mm-1)/V3(1)) ) + sb3*( 1 - V3(mm-1)/V3(1)) );
  %SSn(mm-1) = 1 + sb0*( sb1*E0*( 1 - qn(mm-1)/qn(1) ) + sb2*( 1 - (qn(mm-1)/qn(1))/(V3(mm-1)/V3(1)) ) + sb3*( 1 - V3(mm-1)/V3(1)) );

  SSB(mm-1) = 1 + sb0*( sb1*E0*( 1 - qB(mm-1)/qB(1) ) + sb2*( 1 - (qB(mm-1)/qB(1))/(VV(mm-1)/VV(1)) ) + sb3*( 1 - VV(mm-1)/VV(1) ) );
  SSBs(mm-1) = 1 + sb0*( sb1*E0*( 1 - qBs(mm-1)/qBs(1) ) + sb2*( 1 - (qBs(mm-1)/qBs(1))/(VV(mm-1)/VV(1)) ) + sb3*( 1 - VV(mm-1)/VV(1)) );
  SSBb(mm-1) = 1 + sb0*( sb1*E0*( 1 - qBb(mm-1)/qBb(1) ) + sb2*( 1 - (qBb(mm-1)/qBb(1))/(VV(mm-1)/VV(1)) ) + sb3*( 1 - VV(mm-1)/VV(1)) );
  %SSBn(mm-1) = 1 + sb0*( sb1*E0*( 1 - qBn(mm-1)/qBn(1) ) + sb2*( 1 - (qBn(mm-1)/qBn(1))/(VV(mm-1)/VV(1)) ) + sb3*( 1 - VV(mm-1)/VV(1)) );

end;
D1(mm)=D1(mm-1);
R1eq(mm)=R1eq(mm-1);
C3(mm)=C3(mm-1);
F1=[F1 F1(mm-1)]*m32ml*sec2min; V1=V1*m32ml;
F2=[F2 F2(mm-1)]*m32ml*sec2min; V2=V2*m32ml;
F3=[F3 F3(mm-1)]*m32ml*sec2min; V3=V3*m32ml;
Fin(mm)=Fin(mm-1);
VV(mm)=VV(mm-1);
Fout(mm)=Fout(mm-1);
EEb(mm)=EEb(mm-1);
EEb2(mm)=EEb2(mm-1);
EEs(mm)=EEs(mm-1);
%EEn(mm)=EEn(mm-1);
CMRO2s(mm)=CMRO2s(mm-1);
q(mm)=q(mm-1);
qs(mm)=qs(mm-1);
qb(mm)=qb(mm-1);
%qn(mm)=qn(mm-1);
qB(mm)=qB(mm-1);
qBs(mm)=qBs(mm-1);
qBb(mm)=qBb(mm-1);
%qBn(mm)=qBn(mm-1);
S(mm)=S(mm-1);
Ss(mm)=Ss(mm-1);
Sb(mm)=Sb(mm-1);
%Sn(mm)=Sn(mm-1);
SB(mm)=SB(mm-1);
SBs(mm)=SBs(mm-1);
SBb(mm)=SBb(mm-1);
%SBn(mm)=SBn(mm-1);
SS(mm)=SS(mm-1);
SSs(mm)=SSs(mm-1);
SSb(mm)=SSb(mm-1);
%SSn(mm)=SSn(mm-1);
SSB(mm)=SSB(mm-1);
SSBs(mm)=SSBs(mm-1);
SSBb(mm)=SSBb(mm-1);
%SSBn(mm)=SSBn(mm-1);

  if (ftype==2),
    F2=Fin;
    F4=Fout;
    V3=VV;
    EEb=EEb2;
    q=qB;
    qs=qBs;
    qb=qBb;
    %qn=qBn;
    S=SB;
    Ss=SBs;
    Sb=SBb;
    %Sn=SBn;
    SS=SSB;
    SSs=SSBs;
    SSb=SSBb;
    %SSn=SSBn;
  end;


if (nargout==0), plots_flag=2; else, plots_flag=0; end;
if (plots_flag==2),

  if (ftype==2),
    F2=Fin;
    F4=Fout;
    EEb=EEb2;
    q=qB;
    qs=qBs;
    qb=qBb;
    %qn=qBn;
    S=SB;
    Ss=SBs;
    Sb=SBb;
    %Sn=SBn;
    SS=SSB;
    SSs=SSBs;
    SSb=SSBb;
    %SSn=SSBn;
  end;

  figure(1)
  subplot(211)
  plot(t*60,F2,'b-')
  ylabel('CBF')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  subplot(212)
  plot(t*60,CMRO2,'b-',t*60,CMRO2s,'g-')
  ylabel('rCMRO2')
  axis('tight'), grid('on'),
  xlabel('Time')
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  legend('Dynamic','Steady')
  figure(2)
  subplot(211)
  plot(t*60,EE,'b-',t*60,EEs,'g-',t*60,EEb,'c-')
  ylabel('E')
  xlabel('Time')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  legend('Dynamic','Steady','Steady2',4)
  subplot(212)
  %plot(t*60,S,'b-',t*60,Ss,'g-',t*60,SSb,'c--')
  plot(t*60,S,'b-',t*60,SSb,'c--')
  ylabel('BOLD')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  xlabel('Time')
  dofontsize(15), fatlines,
  %legend('Dynamic','Steady','Steady2')
  legend('Dynamic','Balloon')

elseif (plots_flag==1),

  figure(1)
  subplot(311)
  plot(t,[F1' F2' F3'])
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
  subplot(221)
  plot(t,q/q(1),t,qs/qs(1))
  subplot(223)
  plot(t,S,t,Ss,t,SS,'--',t,SSs,'--')
  subplot(222)
  plot(t,qB/qB(1),t,qBs/qBs(1))
  subplot(224)
  plot(t,SB,t,SBs,t,SSB,'--',t,SSBs,'--')

end;

if (nargin>4),
  S_i=interp1(t,S-1,tdata);
  F_i=interp1(t,F2/F2(1)-1,tdata);
  data=data-1;

  %S_i=S_i/max(data(:,1));
  %F_i=F_i/max(data(:,2));
  %data(:,1)=data(:,1)/max(data(:,1));
  %data(:,2)=data(:,2)/max(data(:,2));

  zz=[S_i' F_i']-data(:,1:2);
  S=[(1/0.0359)*zz(:,1)' (1/0.6346)*zz(:,2)'];
  if (size(data,2)>2),
    data(:,3)=data(:,3)+1;
    S=S.*[data(:,3)' data(:,3)'];
  end;
  [x sum(S.*S)],
  if (nargout==0),
    figure(3)
    subplot(211)
    plot(tdata,data(:,2),tdata,F_i)
    %plot(tdata,data(:,2),tdata,F_i*max(data(:,2)))
    subplot(212)
    plot(tdata,data(:,1),tdata,S_i)
    %plot(tdata,data(:,1),tdata,S_i*max(data(:,1)))
  end;    
end;

