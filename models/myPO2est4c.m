function [CCt2,CCc2,CCt1,CCc1,CMRO2,t,Ca2,Fout,VV]=myPO2est4c(x,tparms,sparms,parms2fit,tdata,data)
% Usage ... [CCt2,CCc2,CCt1,CCc1,CMRO2]=myPO2est4c(x,tparms,sparms,parms2fit,tdata,data)
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
if (length(tparms)<5),
  cmro2_flag=1;
else,
  cmro2_flag=tparms(5);
end;


F0=sparms(1);	% 50
V0=sparms(2);	% 1
Vk1=20;
Vk2=0.0080;
Vk3=sparms(3);	% 0.20
ctype=4;

Fin=F0*interp1(tdata,data(:,1),t);


alpha=1.39e-3;
P50=sparms(5);		% 26
cHb=sparms(6);
hill=2.73;
PO=4;

camp=sparms(4);
Vc=sparms(7);		% 1
Vct=sparms(8);		% 98
PS=sparms(9);		% 7200
Pa=sparms(10);		% 90
Pt=sparms(11);		% 20
PS1=sparms(14);
Vc1=sparms(15);

Vt=Vct-Vc;
Vt1=Vct-Vc1;


Cpa=Pa*alpha;
Ct=Pt*alpha;
Hparms = [cHb PO alpha P50 hill];
Cpa_curve=[1:1e5]*(600/1e5)*alpha;
Catot_curve = Cpa_curve + (cHb*PO)./(1 + ((P50*alpha)./Cpa_curve).^hill );

Ca=interp1(Cpa_curve,Catot_curve,Cpa);
Cc_curve=[1:1e5]*(Ca/1e5);
Ccp_curve=interp1(Catot_curve,Cpa_curve,Cc_curve);

Cc=interp1(2*F0*(Ca-Cc_curve)-PS1*(Ccp_curve-Ct),Cc_curve,0);
Ccp=interp1(Catot_curve,Cpa_curve,Cc);
Cv=2*Cc-Ca;
Cvp=interp1(Catot_curve,Cpa_curve,Cv);
CMRO21=PS1*(Ccp-Ct);
E01=2*(1-Cc/Ca);

Cc2=interp1(2*F0*(Cv-Cc_curve)-PS*(Ccp_curve-Ct),Cc_curve,0);
Ccp2=interp1(Catot_curve,Cpa_curve,Cc2);
Cv2=2*Cc2-Cv;
Cvp2=interp1(Catot_curve,Cpa_curve,Cv2);
CMRO20=PS*(Ccp2-Ct);
E0=2*(1-Cc2/Cv);


%bbeta=0.002;
bbeta=sparms(12);


fp2cmro2_f=sparms(13);
FP=interp1(tdata,data(:,2),t);

if (cmro2_flag==2),
  CMRO2=CMRO20*(1+camp*interp1(tdata,data(:,3),t));
else,
  CMRO2=CMRO20*(1+camp*fp2cmro2_f*FP);
end;


ca_amp=sparms(16);
vc_amp=sparms(17);
ps1_amp=sparms(18);
vc1_amp=sparms(19);

VVc=Vc*( vc_amp*(Fin/F0-1) +1);
VVt=Vct-VVc;

PS1t=PS1*( ps1_amp*(Fin/F0-1) +1);
VVc1=Vc1*( vc1_amp*(Fin/F0-1) +1);
VVt1=Vct-VVc1;


clear Cc_curve Ccp_curve
disp(sprintf('  error_flag= %d   rk_flag= %d',error_flag,RK_flag));
disp(sprintf('  ca_amp= %.3f   vc_amp= %.3f  ps1_amp= %.3f   vc1_amp= %.3f',ca_amp,vc_amp,ps1_amp,vc1_amp)); 
disp(sprintf('  1: Cc0= %.3f   Cp0=   %.3f   Ct0= %.3f   (%.2f,%.2f)',Cc,Ccp/alpha,Ct/alpha,Pa,Cvp/alpha));
disp(sprintf('  1: E0=  %.3f   CMRO2= %.3f',E01,CMRO21*.0224));
disp(sprintf('  2: Cc0= %.3f   Cp0=   %.3f   Ct0= %.3f   (%.2f,%.2f)',Cc2,Ccp2/alpha,Ct/alpha,Cvp/alpha,Cvp2/alpha));
disp(sprintf('  2: E0=  %.3f   CMRO2= %.3f',E0,CMRO20*.0224));
disp(sprintf('  F0= %.2f  PS1= %.2f  Vc1= %.2f   PS= %.2f  Vc=%.2f   Vt=%.2f',F0,PS1,Vc1,PS,Vc,Vt));


%nctype=sparms(15);
%N=sparms(16);
%ytype=[14 N 1.5/60];
%y2st=sparms(17); y2dur=sparms(18); y2ramp=sparms(19); u2tau(20)=sparms(20);

Ca2(1)=Cv;
VV(1)=V0; Fin(1)=F0; Fout(1)=F0;
CCt1(1)=Ct; CCc1(1)=Cc; EE1(1)=E01;
CCt2(1)=Ct; CCc2(1)=Cc2; EE2(1)=E0;
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
 
  nii=find((Catot_curve>0.99*CCc1(mm-1))&(Catot_curve<1.01*CCc1(mm-1))); 
  CCp1 = interp1(Catot_curve(nii),Cpa_curve(nii),CCc1(mm-1));
  Caa = Ca*(ca_amp*((Fin(mm-1)/F0)-1)+1);
  PSc1 = PS1t(mm-1)*sqrt(VVc1(mm-1)/VVc1(1));
  A =  Fin(mm-1)*2*( Caa - CCc1(mm-1) );
  B =  PSc1*( CCp1 - CCt1(mm-1) );
  %CCc1(mm) = CCc1(mm-1) + (dt/Vc1)*( A - B );
  %CCt1(mm) = CCt1(mm-1) + (dt/Vt1)*( B - CMRO21 );
  if (mm>2), dVVc1dt=(VVc1(mm-1)-VVc1(mm-2))/dt; else, dVVc1dt=0; end;
  CCc1(mm) = CCc1(mm-1) + (dt/VVc1(mm-1))*( A - B - CCc1(mm-1)*dVVc1dt);
  CCt1(mm) = CCt1(mm-1) + (dt/VVt1(mm-1))*( B - CMRO21);

  n2ii=find((Catot_curve>0.99*CCc2(mm-1))&(Catot_curve<1.01*CCc2(mm-1))); 
  CCp2 = interp1(Catot_curve(n2ii),Cpa_curve(n2ii),CCc2(mm-1));
  Caa2 = 2*CCc1(mm-1) - Caa;
  PSc = PS*sqrt(VVc(mm-1)/VVc(1));
  A2 =  Fin(mm-1)*2*( Caa2 - CCc2(mm-1) );
  B2 =  PSc*( CCp2 - CCt2(mm-1) );
  %CCc2(mm) = CCc2(mm-1) + (dt/Vc)*( A2 - B2 );
  %CCt2(mm) = CCt2(mm-1) + (dt/Vt)*( B2 - CMRO2(mm-1) );
  if (mm>2), dVVcdt=(VVc(mm-1)-VVc(mm-2))/dt; else, dVVcdt=0; end;
  CCc2(mm) = CCc2(mm-1) + (dt/VVc(mm-1))*( A2 - B2 - CCc2(mm-1)*dVVcdt );
  CCt2(mm) = CCt2(mm-1) + (dt/VVt(mm-1))*( B2 - CMRO2(mm-1));

  Ca2(mm) = 2*CCc1(mm) - Caa;

  %%need to fix the numerical integration here
  %if (RK_flag),
  %  Fa=Fin(mm-1);
  %  Fb=interp1(t,Fin,t(mm-1)+dt/2);
  %  Fc=Fin(mm);
  %  CMRO2a=CMRO20*(1+camp*fp2cmro2_f*FP(mm-1));
  %  CMRO2b=CMRO20*(1+camp*fp2cmro2_f*interp1(t,FP,t(mm-1)+dt/2));
  %  CMRO2c=CMRO20*(1+camp*fp2cmro2_f*FP(mm));

  %  Cck1=(dt/Vc)*( Fa*2*(Ca-CCc(mm-1)) - PS*(CCp-CCt(mm-1)) );
  %  Cck2=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck1/2)) - PS*(interp1(Catot_curve,Cpa_curve,CCc(mm-1)+Cck1/2)-CCt(mm-1)) );
  %  Cck3=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck2/2)) - PS*(interp1(Catot_curve,Cpa_curve,CCc(mm-1)+Cck2/2)-CCt(mm-1)) );
  %  Cck4=(dt/Vc)*( Fc*2*(Ca-(CCc(mm-1)+Cck3)) - PS*(interp1(Catot_curve,Cpa_curve,CCc(mm-1)+Cck3)-CCt(mm-1)) );
  %  CCc(mm) = CCc(mm-1) + Cck1/6 + Cck2/3 + Cck2/3 + Cck4/6;

  %  Ctk1=(dt/Vt)*( PS*(CCp - CCt(mm-1)) - CMRO2a );
  %  Ctk2=(dt/Vt)*( PS*(CCp - (CCt(mm-1)+Ctk1/2)) - CMRO2b );
  %  Ctk3=(dt/Vt)*( PS*(CCp - (CCt(mm-1)+Ctk2/2)) - CMRO2b );
  %  Ctk4=(dt/Vt)*( PS*(CCp - (CCt(mm-1)+Ctk3)) - CMRO2c );
  %  CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;
  %end;

  EE1(mm) = 2*( 1 - CCc1(mm)/Ca );
  EE(mm) = 2*( 1 - CCc2(mm)/Ca2(mm) );

  %EE(mm)=EE(1)*( Ek1*(EE(mm)/EE(1)-1) +1);
  %[EEs(mm-1),CMRO2s(mm-1)]=valabregue3ff(Fin(mm-1),PS,Pt,Pa);
end;
VV(mm)=VV(mm-1);
Fout(mm)=Fout(mm-1);



if (size(data,2)>2),
  error_flag=1;
  %size(t), size(data), size(tdata),
  PO2ti=interp1(tdata',data(:,3)',t);
  zz=PO2ti-CCt2/Ct;
  if (nargout==0),
    plot(t,PO2ti,t,CCt2/Ct)
  end;    
  zz=zz+bbeta*sum(abs(diff(sparms(12:end))));
  %zz=zz+bbeta*sum(abs(diff(diff(sparms(12:end)))));
  [x sum(zz.*zz)],
elseif (nargout==0),
  subplot(411)
  plot(t,Fin)
  ylabel('Fin')
  axis('tight'); grid('on'); fatlines;
  subplot(412)
  plot(t,CCc1,t,CCc2)
  ylabel('Cc')
  axis('tight'); grid('on'); fatlines;
  subplot(413)
  plot(t,CCt1,t,CCt2)
  ylabel('Ct')
  axis('tight'); grid('on'); fatlines;
  subplot(414)
  plot(t,CMRO2)
  ylabel('CMRO2')
  axis('tight'); grid('on'); fatlines;
end;

if (error_flag),
  CCt2=zz;
  sum(zz.*zz),
end;


etime=toc;
disp(sprintf('  etime= %f',etime));

