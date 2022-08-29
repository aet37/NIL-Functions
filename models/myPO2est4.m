function [CCt,CCc,CCm,CMRO2,t,Fout,VV]=myPO2est4(x,tparms,sparms,parms2fit,tdata,data)
% Usage ... [CCt,CCc,CCm,CMRO2]=myPO2est4(x,tparms,sparms,parms2fit,tdata,data)
%
% x = parameters to fit
% tparms = [dt T]
% sparms = [F0 V0 Vk1 camp P50 Vc Vct PS Pa Pt]
% parms2fit = index#'s of sparms that correspond to x
% data is in columns = [CBF PO2normchange]
% tdata is the time vector corresponding to data


tic,
if (~isempty(x)),
  sparms(parms2fit)=x;
end;


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

RK_flag=tparms(3);
error_flag=tparms(4);


F0=sparms(1);	% 50
V0=sparms(2);	% 1
Vk1=20;
Vk2=0.0080;
Vk3=sparms(3);	% 0.20
ctype=4;

Fin=F0*interp1(tdata,data(:,1),t);


alpha=1.39e-3;
P50=sparms(5);		% 26
hill=2.73;
cHb=sparms(6);
PO=4;


% Note that in this model:
%   Vt is the extra-cellular tissue volume
%   Vm is the intra-cellular tissue volume

camp=sparms(4);
Vc=sparms(7);		% 1
Vct=sparms(8);		% 98
PS=sparms(9);		% 7200
Pa=sparms(10);		% 90
Pt=sparms(11);		% 20
Vm=sparms(13);
PSm=sparms(14);

Vt=Vct-Vc-Vm;



Cpa=Pa*alpha;
Ct=Pt*alpha;
Hparms = [cHb PO alpha P50 hill];
Cpa_curve=[1:1e5]*(600/1e5)*alpha;
Catot_curve = Cpa_curve + (cHb*PO)./(1 + ((P50*alpha)./Cpa_curve).^hill );

Ca=interp1(Cpa_curve,Catot_curve,Cpa);
Cc_curve=[1:1e5]*(Ca/1e5);
Ccp_curve=interp1(Catot_curve,Cpa_curve,Cc_curve);

Cc=interp1(2*F0*(Ca-Cc_curve)-PS*(Ccp_curve-Ct),Cc_curve,0);
Ccp=interp1(Catot_curve,Cpa_curve,Cc);
CMRO20=PS*(Ccp-Ct);
E0=2*(1-Cc/Ca);
Cm=Ct-(PS/PSm)*(Ccp-Ct);


%bbeta=0.002;
bbeta=sparms(12);


fp2cmro2_f=sparms(15);
FP=interp1(tdata,data(:,2),t);
CMRO2=CMRO20*(1+camp*fp2cmro2_f*FP);


[maxCMRO2,imaxCMRO2]=max(CMRO2);
Cm_pseudoact=Ct-(maxCMRO2/PSm);
clear Cc_curve Ccp_curve
disp(sprintf('  error_flag= %d   rk_flag= %d',error_flag,RK_flag));
disp(sprintf('  Cc0= %f   Cp0=   %f   Ct0= %f',Cc,Ccp/alpha,Ct/alpha));
disp(sprintf('  E0=  %f   CMRO2= %f',E0,CMRO20*.0224));
disp(sprintf('  F0= %f  PS= %f  PSm= %f',F0,PS,PSm));
disp(sprintf('  Vc= %f  Vt= %f  Vm= %f',Vc,Vt,Vm));


%nctype=sparms(15);
%N=sparms(16);
%ytype=[14 N 1.5/60];
%y2st=sparms(17); y2dur=sparms(18); y2ramp=sparms(19); u2tau(20)=sparms(20);

VV(1)=V0; Fin(1)=F0; Fout(1)=F0;
CCt(1)=Ct; CCc(1)=Cc; CCm=Cm; EE(1)=E0;
for mm=2:length(t),

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

  nii=find((Catot_curve>0.99*CCc(mm-1))&(Catot_curve<1.01*CCc(mm-1))); 
  if (isempty(nii)), nii=[1:length(Catot_curve)]; end;
  CCp = interp1(Catot_curve(nii),Cpa_curve(nii),CCc(mm-1));
  A =  Fin(mm-1)*2*( Ca - CCc(mm-1) );
  B =  PS*( CCp - CCt(mm-1) );
  D =  PSm*( CCt(mm-1) - CCm(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt/Vc)*( A - B );
  CCt(mm) = CCt(mm-1) + (dt/Vt)*( B - D );
  CCm(mm) = CCm(mm-1) + (dt/Vm)*( D - CMRO2(mm-1) );

  if (RK_flag),
    Fa=Fin(mm-1);
    Fb=interp1(t,Fin,t(mm-1)+dt/2);
    Fc=Fin(mm);
    CMRO2a=CMRO20*(1+camp*fp2cmro2_f*FP(mm-1));
    CMRO2b=CMRO20*(1+camp*fp2cmro2_f*interp1(t,FP,t(mm-1)+dt/2));
    CMRO2c=CMRO20*(1+camp*fp2cmro2_f*FP(mm));

    Cck1=(dt/Vc)*( Fa*2*(Ca-CCc(mm-1)) - PS*(CCp-CCt(mm-1)) );
    Cck2=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck1/2)) - PS*(interp1(Catot_curve,Cpa_curve,CCc(mm-1)+Cck1/2)-CCt(mm-1)) );
    Cck3=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck2/2)) - PS*(interp1(Catot_curve,Cpa_curve,CCc(mm-1)+Cck2/2)-CCt(mm-1)) );
    Cck4=(dt/Vc)*( Fc*2*(Ca-(CCc(mm-1)+Cck3)) - PS*(interp1(Catot_curve,Cpa_curve,CCc(mm-1)+Cck3)-CCt(mm-1)) );
    CCc(mm) = CCc(mm-1) + Cck1/6 + Cck2/3 + Cck2/3 + Cck4/6;

    Ctk1=(dt/Vt)*( PS*(CCp - CCt(mm-1)) - PSm*(CCt(mm-1) - CCm(mm-1)) );
    Ctk2=(dt/Vt)*( PS*(CCp - (CCt(mm-1)+Ctk1/2)) - PSm*((CCt(mm-1)+Ctk1/2) - CCm(mm-1)) );
    Ctk3=(dt/Vt)*( PS*(CCp - (CCt(mm-1)+Ctk2/2)) - PSm*((CCt(mm-1)+Ctk2/2) - CCm(mm-1)) );
    Ctk4=(dt/Vt)*( PS*(CCp - (CCt(mm-1)+Ctk3)) - PSm*((CCt(mm-1)+Ctk3) - CCm(mm-1)) );
    CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;

    Cmk1=(dt/Vm)*( PSm*(CCt(mm-1) - CCm(mm-1)) - CMRO2a );
    Cmk2=(dt/Vm)*( PSm*(CCt(mm-1) - (CCm(mm-1)+Cmk1/2)) - CMRO2b );
    Cmk3=(dt/Vm)*( PSm*(CCt(mm-1) - (CCm(mm-1)+Cmk2/2)) - CMRO2b );
    Cmk4=(dt/Vm)*( PSm*(CCt(mm-1) - (CCm(mm-1)+Cmk3)) - CMRO2c );
    CCm(mm) = CCm(mm-1) + Cmk1/6 + Cmk2/3 + Cmk3/3 + Cmk4/6;
  end;

  EE(mm) = 2*( 1 - CCc(mm)/Ca );
  %EE(mm)=EE(1)*( Ek1*(EE(mm)/EE(1)-1) +1);
  %[EEs(mm-1),CMRO2s(mm-1)]=valabregue3ff(Fin(mm-1),PS,Pt,Pa);
end;
VV(mm)=VV(mm-1);
Fout(mm)=Fout(mm-1);



negCCm=find(CCm<0);
if (~isempty(negCCm)),
  disp(sprintf('  warning: CCm has negative values!'));
end;


if (size(data,2)>2),
  error_flag=1;
  %size(t), size(data), size(tdata),
  PO2ti=interp1(tdata',data(:,3)',t);
  zz=PO2ti-CCt/Ct;
  if (nargout==0),
    plot(tdata,data(:,2),t,CCt/Ct)
  end;    
  zz=zz+bbeta*sum(abs(diff(sparms(12:end))));
  %zz=zz+bbeta*sum(abs(diff(diff(sparms(12:end)))));
  [x sum(zz.*zz)],
elseif (nargout==0),
  subplot(511)
  plot(t,Fin)
  ylabel('Fin')
  axis('tight'); grid('on'); fatlines;
  subplot(512)
  plot(t,CCc)
  ylabel('Cc')
  axis('tight'); grid('on'); fatlines;
  subplot(513)
  plot(t,CCt)
  ylabel('Ct')
  axis('tight'); grid('on'); fatlines;
  subplot(514)
  plot(t,CCm)
  ylabel('Cm')
  axis('tight'); grid('on'); fatlines;
  subplot(515)
  plot(t,CMRO2)
  ylabel('CMRO2')
  axis('tight'); grid('on'); fatlines;
end;


if (error_flag),
  CCt=zz;
  sum(zz.*zz),
end;



etime=toc;
disp(sprintf('  etime= %f',etime));

