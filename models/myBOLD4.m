function [S,S2,F2,F4,V3,CMRO2,EE,q,t]=myBOLD2(x,tparms,sparms,parms2fit_i,iunfix,ifix,tdata,data)
% Usage ... [S,Fin,Fout,V,CMRO2,EE,q,t]=myBOLD2(x,tparms,sparms,iparms,parms2fit_i,iunfix,ifix,tdata,data)
%
% x = parameters to fit
% tparms = [dt T]
% sparms = [ftau famp camp F0 V0 Vk1 P50 Vc Va PS Pa Pt Sk1 Sk2]
% parms2fit = index#'s of sparms that correspond to x
% data is in columns = [BOLD CBF]
% tdata is the time vector corresponding to data

% Example: tparms=[1/(60*20) 2]
% Example: sparms=[2/60 0.62 0.24 50 1 0.2 26 1 96 7200 90 20 0.5 1]

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
%ytype=sparms(1);	% 1
%ytype=2;
%ytype=[10 20 1 0.04];
%ytype=[10 240 1 .01];

cm2m=1e-2;
m2cm=1/cm2m;
mmHg2Pa=133.32;
Pa2mmHg=1/133.32;
ml2m3=1e-6;
m32ml=1/ml2m3;
min2sec=1/60;
sec2min=60;

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


F0=sparms(2);	% 50
V0=sparms(3);	% 1
Vk0=0.35;
Vk1=20;
Vk2=0.0080;
Vk3=sparms(4);	% 0.20
ctype=4;


yst=3.5/60+dt; ydur=11.5/60; yramp=[.5/60 .5/60];
ytau=3/60;
yamp=0.25;
%y2st=sparms(2); y2dur=sparms(3); y2ramp=sparms(4);	% 3.5/60 11.5/60 0.5/60
%y2tau=sparms(1);		% 2/60
%y2amp=sparms(2);		% 0.62

%cstart=sparms(2); cdur=sparms(3); cramp=sparms(4);
%cstart=15/60+dt; cdur=09/60; cramp=12/60;
camp=sparms(1);


alpha=1.39e-3;
P50=sparms(5);		% 26
hill=2.73;
cHb=2.3;
PO=4;

Vc=sparms(6);		% 1
Vt=sparms(7);		% 96
PS=sparms(8);		% 7200
Pa=sparms(9);		% 90
Pt=sparms(10);		% 20

Cpa=Pa*alpha;
Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
Ct=Pt*alpha;
Hparms = [cHb PO alpha P50 hill];
Cc = fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,F0,Hparms);
CMRO20 = PS*( H_inv(Cc,Hparms) - Ct );
E0 = 2*(1-Cc/Ca);

%bbeta=0.002;
bbeta=sparms(13);

xunfix=sparms(14:end);

CMRO2=CMRO20*(1+camp*myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t));



Ek1=1.0;

sk1=sparms(11);		% 0.5
sk2=sparms(12);		% 1
sb1=4.3*(42.57*1e-6*3.0*1.0e-6);
sb2=2.0; sb0=sk1/4;
sb3=0.6;

%nctype=sparms(15);
%N=sparms(16);
%ytype=[14 N 1.5/60];
%y2st=sparms(17); y2dur=sparms(18); y2ramp=sparms(19); u2tau(20)=sparms(20);

y(1)=0; y2(1)=0; y3(1)=0; u2(1)=0;
VV(1)=V0; Fin(1)=F0; Fout(1)=F0;
CCt(1)=Ct; CCc(1)=Cc; EE(1)=E0;
qB(1)=Ca*E0*V0; qBs(1)=qB(1); qBb(1)=qB(1); qBn(1)=qB(1);
for mm=2:length(t),


  Fin(mm-1) = F0*myfoh(tdata,iunfix,data(iunfix,2),ifix(:,1),data(ifix(:,1),2),t(mm-1)); 
  Fin(mm) = F0*myfoh(tdata,iunfix,data(iunfix,2),ifix(:,1),data(ifix(:,1),2),t(mm)); 
  if (RK_flag),
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
  


  CCt(mm) = CCt(mm-1) + (dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2(mm-1) );

  A =  Fin(mm-1)*2*( Ca - CCc(mm-1) );
  B =  PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt/Vc)*( A - B );

  if (RK_flag),
    CMRO2a=CMRO20*(1+camp*myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)));
    CMRO2b=CMRO20*(1+camp*myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)+dt/2));
    CMRO2c=CMRO20*(1+camp*myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)+dt));
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

  [EEs(mm-1),CMRO2s(mm-1)]=valabregue3ff(Fin(mm-1),PS,Pt,Pa);

  EEb2(mm-1) = 1 - (1-E0)^(Fin(1)/Fin(mm-1));



  qB(mm) = qB(mm-1) + dt*( Ca*EE(mm-1)*Fin(mm-1) - qB(mm-1)*Fout(mm-1)/VV(mm-1) );
  qBs(mm) = qBs(mm-1) + dt*( Ca*EEs(mm-1)*Fin(mm-1) - qBs(mm-1)*Fout(mm-1)/VV(mm-1) );
  qBb(mm) = qBb(mm-1) + dt*( Ca*EEb2(mm-1)*Fin(mm-1) - qBb(mm-1)*Fout(mm-1)/VV(mm-1) );



  SB(mm-1) = 1 + sk1*( 1 - sk2*(qB(mm-1)/qB(1))^1.5 );
  SBs(mm-1) = 1 + sk1*( 1 - sk2*(qBs(mm-1)/qBs(1))^1.5 );
  SBb(mm-1) = 1 + sk1*( 1 - sk2*(qBb(mm-1)/qBb(1))^1.5 );


  SSB(mm-1) = 1 + sb0*( sb1*E0*( 1 - qB(mm-1)/qB(1) ) + sb2*( 1 - (qB(mm-1)/qB(1))/(VV(mm-1)/VV(1)) ) + sb3*( 1 - VV(mm-1)/VV(1) ) );
  SSBs(mm-1) = 1 + sb0*( sb1*E0*( 1 - qBs(mm-1)/qBs(1) ) + sb2*( 1 - (qBs(mm-1)/qBs(1))/(VV(mm-1)/VV(1)) ) + sb3*( 1 - VV(mm-1)/VV(1)) );
  SSBb(mm-1) = 1 + sb0*( sb1*E0*( 1 - qBb(mm-1)/qBb(1) ) + sb2*( 1 - (qBb(mm-1)/qBb(1))/(VV(mm-1)/VV(1)) ) + sb3*( 1 - VV(mm-1)/VV(1)) );

end;
Fin(mm)=Fin(mm-1);
VV(mm)=VV(mm-1);
Fout(mm)=Fout(mm-1);
EEb2(mm)=EEb2(mm-1);
EEs(mm)=EEs(mm-1);
CMRO2s(mm)=CMRO2s(mm-1);
qB(mm)=qB(mm-1);
qBs(mm)=qBs(mm-1);
qBb(mm)=qBb(mm-1);
SB(mm)=SB(mm-1);
SBs(mm)=SBs(mm-1);
SBb(mm)=SBb(mm-1);
SSB(mm)=SSB(mm-1);
SSBs(mm)=SSBs(mm-1);
SSBb(mm)=SSBb(mm-1);

    F2=Fin;
    F4=Fout;
    V3=VV;
    EEb=EEb2;
    q=qB;
    qs=qBs;
    qb=qBb;
    S=SB;
    Ss=SBs;
    Sb=SBb;
    SS=SSB;
    SSs=SSBs;
    SSb=SSBb;

S2=S;

if (nargout==0), plots_flag=2; else, plots_flag=0; end;
if (plots_flag==2),

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

end;

if (nargin>7),
  S_i=interp1(t,S-1,tdata);
  F_i=interp1(t,F2/F2(1)-1,tdata);
  data=data-1;
  zz=[S_i']-data(:,1);
  S=[18*zz(:,1)'];
  S=S+bbeta*sum(abs(diff(sparms(15:end))));
  %S=S+bbeta*sum(abs(diff(diff(sparms(15:end)))));
  [x sum(S.*S)],
  if (nargout==0),
    figure(3)
    subplot(211)
    plot(tdata,data(:,2),tdata,F_i)
    subplot(212)
    plot(tdata,data(:,1),tdata,S_i)
  end;    
end;

