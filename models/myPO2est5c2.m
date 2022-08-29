function [CCt,CCc,CCm1,CCm2,CMRO2,t,Cat,Vmft]=myPO2est5c(x,tparms,sparms,parms2fit,iunfix,ifix,ttt,tdata,data)
% Usage ... [CCt,CCc,CCm,CCm2,CMRO2,t,CCa,Vm]=myPO2est5c(x,tparms,sparms,parms2fit,iunfix,ifix,ttt,tdata,data)
%
% x = parameters to fit
% tparms = [dt T]
% sparms = [F0 V0 Vk1 camp P50 Vc Vct PS Pa Pt]
% parms2fit = index#'s of sparms that correspond to x
% data is in columns = [CBF FPenv PO2normal PO2cmro2diff]
% tdata is the time vector corresponding to data


tic,
if (~isempty(x)),
  sparms(parms2fit)=x;
end;

opt1min=optimset('fminbnd');
opt1min.TolFun=1e-10;
opt1min.TolX=1e-8;
opt1min.MaxIter=1000;


ftype=2;


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

neglectplasma=tparms(3);
RK_flag=tparms(4);


F0=sparms(1);	% 50
V0=sparms(2);	% 1
Vk1=20;
Vk2=0.0080;
Vk3=sparms(3);	% 0.20
ctype=4;
Ek1=1.0;



Fin=F0*interp1(tdata,data(:,1),t);

alpha=1.39e-3;
P50=sparms(5);		% 26
hill=2.73;
cHb=sparms(6);
PO=4;

camp=sparms(4);
Vc=sparms(7);		% 1
Vct=sparms(8);		% 98
PS=sparms(9);		% 7200
Pa=sparms(10);		% 90
Pt=sparms(11);		% 20
Vm=sparms(14);
PSm=sparms(15);
Vmf_amp=sparms(16);

Vt=Vct-Vc-Vm;



Cpa=Pa*alpha;
Ct=Pt*alpha;
Hparms = [cHb PO alpha P50 hill];
if (neglectplasma),
  Ca=(cHb*PO)/(1+((P50/Pa)^hill));
  Cc=fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,Fin(1),Hparms);
  Ccp=H_inv(Cc,Hparms);
else,
  Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
  Cc=Cc_H_inv1(Pa,[Fin(1) PS Pt],Hparms,0);
  Ccp=H_inv1(Cc,Hparms);
end;
Cm=Ct-(PS/PSm)*(Ccp-Ct);
CMRO20 = PS*( Ccp - Ct );
E0 = 2*(1-Cc/Ca);
[Cc CMRO20*0.0224 E0], 


%bbeta=0.002;
bbeta=sparms(12);



fp2cmro2_f=sparms(13);
FP=interp1(tdata,data(:,2),t);
CMRO2=CMRO20*(1+camp*fp2cmro2_f*FP);
%CMRO2=CMRO20*(1+camp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t));
[maxCMRO2,imaxCMRO2]=max(CMRO2);
Cm_maxest=Ct-(maxCMRO2/PSm);


ca_amp=sparms(17);
Vmf_base=sparms(18);
xunfix=sparms(19:end);

Cat=Ca*(1+ca_amp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t));

Vmft=Vmf_base+Vmf_amp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t);
Vm1t=Vm*Vmft;
Vm2t=Vm*(1-Vmft);

PSm1t=PSm*Vmft;
PSm2t=PSm*(1-Vmft);

Cm1=Ct-CMRO20*Vmft(1)/PSm1t(1);
Cm2=Ct-CMRO20*(1-Vmft(1))/PSm2t(1);


%disp(sprintf('  neglectplasma_flag= %f,  rk_flag= %d',neglectplasma,RK_flag));
%disp(sprintf('  ca_amp= %.3f   fp2cmro2f= %.3f',ca_amp,fp2cmro2_f)); 
%disp(sprintf('  Cc0= %.3f   Cp0=   %.3f   Ct0= %.3f  (%.2f,%.2f)  Cm0= %.3f (%.3f)',Cc,Ccp/alpha,Ct/alpha,Pa,Cvp/alpha,Cm/alpha,Cm_maxest/alpha));
%disp(sprintf('  E0=  %.3f   CMRO2= %.3f',E0,CMRO20*.0224));
%disp(sprintf('  F0= %.2f  PS= %.2f  PSm= %.2f  Vc= %.2f  Vt= %.2f  Vm= %.2f',F0,PS,PSm,Vc,Vt,Vm));


%nctype=sparms(15);
%N=sparms(16);
%ytype=[14 N 1.5/60];
%y2st=sparms(17); y2dur=sparms(18); y2ramp=sparms(19); u2tau(20)=sparms(20);



VV(1)=V0; Fin(1)=F0; Fout(1)=F0;
CCt(1)=Ct; CCc(1)=Cc; CCm1(1)=Cm1; CCm2(1)=Cm2; EE(1)=E0;
for mm=2:length(t),

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
  
  if (neglectplasma),
    CCp = H_inv(CCc(mm-1),Hparms);
  else,
    CCp = H_inv1(CCc(mm-1),Hparms);
  end;
  if (mm>2),
    dVm1dt=(Vm1t(mm-1)-Vm1t(mm-2))/dt;
    dVm2dt=(Vm2t(mm-1)-Vm2t(mm-2))/dt;
  else, 
    dVm1dt=0; 
    dVm2dt=0; 
  end;
  A =  Fin(mm-1)*2*( Cat(mm-1) - CCc(mm-1) );
  B =  PS*( CCp - CCt(mm-1) );
  D =  PSm1t(mm-1)*(CCt(mm-1) - CCm1(mm-1) );
  D2=  PSm2t(mm-1)*(CCt(mm-1) - CCm2(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt/Vc)*( A - B );
  CCt(mm) = CCt(mm-1) + (dt/Vt)*( B - D - D2 );
  CCm1(mm) = CCm1(mm-1) + (dt/Vm1t(mm-1))*( D - Vmft(mm-1)*CMRO2(mm-1) - dVm1dt*CCm1(mm-1) );
  CCm2(mm) = CCm2(mm-1) + (dt/Vm2t(mm-1))*( D2 - (1-Vmft(mm-1))*CMRO20 - dVm2dt*CCm2(mm-1) );


  if (RK_flag),
    if (ftype==2),
      Fa=Fin(mm-1);
      Fb=Finh;
      Fc=Finhh;
    else,
      Fa=F2(mm-1)*m32ml*sec2min;
      Fb=F2h*m32ml*sec2min;
      Fc=F2hh*m32ml*sec2min;
    end;
    Cata=Ca*(1+ca_amp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)));
    Catb=Ca*(1+ca_amp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)+dt/2));
    Catc=Ca*(1+ca_amp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)+dt));
    Cck1=(dt/Vc)*( Fa*2*(Cata-CCc(mm-1)) - PS*(CCp-CCt(mm-1)) );
    if (neglectplasma),
      Cck2=(dt/Vc)*( Fb*2*(Catb-(CCc(mm-1)+Cck1/2)) - PS*(H_inv(CCc(mm-1)+Cck1/2,Hparms)-CCt(mm-1)) );
      Cck3=(dt/Vc)*( Fb*2*(Catb-(CCc(mm-1)+Cck2/2)) - PS*(H_inv(CCc(mm-1)+Cck2/2,Hparms)-CCt(mm-1)) );
      Cck4=(dt/Vc)*( Fc*2*(Catc-(CCc(mm-1)+Cck3)) - PS*(H_inv(CCc(mm-1)+Cck3,Hparms)-CCt(mm-1)) );
    else,
      Cck2=(dt/Vc)*( Fb*2*(Catb-(CCc(mm-1)+Cck1/2)) - PS*(H_inv1(CCc(mm-1)+Cck1/2,Hparms)-CCt(mm-1)) );
      Cck3=(dt/Vc)*( Fb*2*(Catb-(CCc(mm-1)+Cck2/2)) - PS*(H_inv1(CCc(mm-1)+Cck2/2,Hparms)-CCt(mm-1)) );
      Cck4=(dt/Vc)*( Fc*2*(Catc-(CCc(mm-1)+Cck3)) - PS*(H_inv1(CCc(mm-1)+Cck3,Hparms)-CCt(mm-1)) );
    end;
    CCc(mm) = CCc(mm-1) + Cck1/6 + Cck2/3 + Cck2/3 + Cck4/6;

    Ctk1=(dt/Vt)*( PS*(CCp - CCt(mm-1)) - PSm*(CCt(mm-1) - CCm(mm-1)) );
    Ctk2=(dt/Vt)*( PS*(CCp - (CCt(mm-1)+Ctk1/2)) - PSm*((CCt(mm-1)+Ctk1/2) - CCm(mm-1) ) );
    Ctk3=(dt/Vt)*( PS*(CCp - (CCt(mm-1)+Ctk2/2)) - PSm*((CCt(mm-1)+Ctk2/2) - CCm(mm-1) ) );
    Ctk4=(dt/Vt)*( PS*(CCp - (CCt(mm-1)+Ctk3)) - PSm*((CCt(mm-1)+Ctk3) - CCm(mm-1) ) );
    CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;

    CMRO2a=CMRO2(mm-1);
    CMRO2b=(CMRO2(mm-1)+CMRO2(mm))/2;
    CMRO2c=CMRO2(mm);
    Cmk1=(dt/Vm)*( PSm*(CCt(mm-1) - CCm(mm-1)) - CMRO2a );
    Cmk2=(dt/Vm)*( PSm*(CCt(mm-1) - (CCm(mm-1)+Cmk1/2) ) - CMRO2b );
    Cmk3=(dt/Vm)*( PSm*(CCt(mm-1) - (CCm(mm-1)+Cmk2/2) ) - CMRO2b );
    Cmk4=(dt/Vm)*( PSm*(CCt(mm-1) - (CCm(mm-1)+Cmk3) ) - CMRO2c );
    CCm(mm) = CCm(mm-1) + Cmk1/6 + Cmk2/3 + Cmk3/3 + Cmk4/6;
  end;

  EE(mm) = 2*( 1 - CCc(mm)/Ca );
  %EE(mm)=EE(1)*( Ek1*(EE(mm)/EE(1)-1) +1);
  %[EEs(mm-1),CMRO2s(mm-1)]=valabregue3ff(Fin(mm-1),PS,Pt,Pa);
end;
VV(mm)=VV(mm-1);
Fout(mm)=Fout(mm-1);


%ww=[1:length(CCt)]-1; ww=ww*(2*pi/ww(end));
%PO2ff=fft(CCt).*exp(j*ww*t0);
%PO2ii=ifft(PO2iff);
%PO2ii=real(PO2ii);



if (nargout==0),
  subplot(611)
  plot(t,Cat)
  subplot(612)
  plot(t,Fin)
  subplot(613)
  plot(t,CCt)
  subplot(614)
  plot(t,CCm1,t,CCm2)
  subplot(615)
  plot(t,CMRO2*0.0224)
  subplot(616)
  plot(t,Vmft)
end;


if (size(data,2)>2),
  %size(t), size(data), size(tdata),
  PO2ti1=interp1(tdata',data(:,3)',t); 
  zz=CCt/alpha-PO2ti1;
  if (nargout==0),
    clf,
    subplot(311)
    plot(t,CCm/alpha)
    subplot(312)
    plot(t,PO2ti1,t,CCt/alpha)
    subplot(313)
    plot(t,zz)
  end;
  zz=zz+bbeta*sum(abs(diff(sparms(12:end))));
  %zz=zz+bbeta*sum(abs(diff(diff(sparms(12:end)))));
  [x sum(zz.*zz)],
  CCt=zz;
end;


etime=toc;
disp(sprintf('  etime= %f',etime));
%keyboard,

