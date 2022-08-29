function [BOLD,Fin,Fout,Vv,CMRO2,EE,q,U,fneu,S,t]=myBOLDf(x,tparms,sparms,parms2fit,tdata,data,iunfix,ifix)
% Usage ... [BOLD,Fin,Fout,Vv,CMRO2,EE,q,U,fneu,S,t]=myBOLD2(x,tparms,sparms,iparms,parms2fit_i,iunfix,ifix,tdata,data)
%
% x = parameters to fit
% tparms = [dt T cmro2type flowtype]
% sparms = [St0 Sdur Sramp1 Sramp2 Swex Namp Ntau Camp Ctau Utau F0 Famp Ftau Vv0 Vtau P50 Vc Va PS Pa Pt kb]
% data is in columns = [BOLD CBF]
% tdata is the time vector corresponding to data

% Example: tparms=[1/(60*20) 2 1 1]
% Example: sparms=[2/60 0.62 0.24 50 1 0.2 26 1 96 7200 90 20 0.5 1]


opt1min=optimset('fminbnd');
RK_flag=1;
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

dt=tparms(1)/60;
T=tparms(2)/60;
t=([1:round(T/dt)]-1)*(T/(round(T/dt)-1));

cmro2type=tparms(3);
flowtype=tparms(4);

if (~isempty(x)),
  sparms(parms2fit)=x;
end;
if (flowtype==0)|(cmro2type==0),
  if (nargin>7),
    calc_err=1;
  elseif (nargin>6),
    cal_cerr=0;
    ifix=iunfix;
    iunfix=data;
  else,
    error('Improper # of input parameters!');
  end;
else,
  if (nargin>4), calc_err=1; else, calc_err=0; end;
end;
   
 
grubb=0.4;
F0=sparms(11);	% 50
Ftau=sparms(13)/60;
Famp=sparms(12);
Vv0=sparms(14);	% 1
Vk=sparms(15);	% 0.20


St0=sparms(1)/60+dt; Sdur=sparms(2)/60; Sramps=[sparms(3)/60 sparms(4)/60];
S=mytrapezoid3(t,St0+Sramps(1),Sdur,Sramps);

Swex=sparms(5)/60;
Namp=sparms(6);
Ntau_lpf=sparms(7)/60;
fneu_type=[14 Namp Ntau_lpf];
fneu=mytrapezoid3(t,St0+Sramps(1),Sdur+Swex,Sramps,fneu_type);

Utau=sparms(10)/60;

cmro2amp=sparms(8);
cmro2tau=sparms(9)/60;

alpha=1.39e-3;
P50=sparms(19);		% 26
hill=2.73;
cHb=2.3;
PO=4;

Vc=sparms(20);		% 1
Vt=sparms(21);		% 96
PS=sparms(18);		% 7200
Pa=sparms(16);		% 90
Pt=sparms(17);		% 20

Cpa=Pa*alpha;
Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
Ct=Pt*alpha;
Hparms = [cHb PO alpha P50 hill];
Cc = fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,F0,Hparms);
CMRO20 = PS*( H_inv(Cc,Hparms) - Ct );
E0 = 2*(1-Cc/Ca);


beta=1.5;
kb=sparms(22);
kb2=1;


if (flowtype==0)|(cmro2type==0),
  xunfix=sparms(23:end);
end;


yy(1)=0; yyy(1)=0; U(1)=0;
Vv(1)=Vv0; Fin(1)=F0; Fout(1)=F0;
CCt(1)=Ct; CCc(1)=Cc; EE(1)=E0;
q(1)=Ca*E0*Vv0;
for mm=2:length(t),

  % stimulus (S) already given
  % neuronal (fneu) response already given
  % intermediary response (U)
  U(mm) = U(mm-1) + dt*( (1/Utau)*( mytrapezoid3(t(mm-1),St0+Sramps(1),Sdur+Swex,Sramps,fneu_type) - U(mm-1) ));
  if (RK_flag),
    Uk1=dt*( (1/Utau)*( mytrapezoid3(t(mm-1),St0+Sramps(1),Sdur+Swex,Sramps,fneu_type) - U(mm-1) ));
    Uk2=dt*( (1/Utau)*( mytrapezoid3(t(mm-1)+dt/2,St0+Sramps(1),Sdur+Swex,Sramps,fneu_type) - (U(mm-1)+Uk1/2) ));
    U(mm)=U(mm-1)+Uk2;
    Uh=(U(mm)+U(mm-1))/2;
  end;
  if (flowtype==0),
    U(mm-1)=myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1));
    U(mm)=myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm));
    Uh=myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)+dt/2);
  end;


  % Arterial flow (Fin) and Venous volume (Vv) responses 
  yy(mm) = yy(mm-1) + dt*( (1/Ftau)*( U(mm-1) - yy(mm-1) ));
  if (RK_flag),
    yyk1=dt*( (1/Ftau)*( U(mm-1) - yy(mm-1) ));
    yyk2=dt*( (1/Ftau)*( Uh - (yy(mm-1)-yyk1/2) ));
    yy(mm)=yy(mm-1)+yyk2;
    yyh=(yy(mm)-yy(mm-1))/2;
  end;
  Fin(mm) = F0*( 1 + Famp*yy(mm) );
  Vv(mm) = Vv(mm-1) + dt*(1/(1+F0*Vk))*( Fin(mm-1) - F0*((Vv(mm-1)/Vv0)^(1/grubb)) );
  Fout(mm) = Fin(mm) - (1/dt)*( Vv(mm)-Vv(mm-1) );


  % oxygen delivery (CCc) and consumption (CCt,CMRO2) responses
  if (cmro2type==1),
    CMRO2=CMRO20*(1+cmro2amp*mytrapezoid3(t,St0+Sramps(1),Sdur+Swex,Sramps,fneu_type));
    CMRO2a=CMRO20*(1+cmro2amp*mytrapezoid3(t(mm-1),St0+Sramps(1),Sdur+Swex,Sramps,fneu_type));
    CMRO2b=CMRO20*(1+cmro2amp*mytrapezoid3(t(mm-1)+dt/2,St0+Sramps(1),Sdur+Swex,Sramps,fneu_type));
    CMRO2c=CMRO20*(1+cmro2amp*mytrapezoid3(t(mm-1)+dt,St0+Sramps(1),Sdur+Swex,Sramps,fneu_type));
  elseif (cmro2type==2),
    CMRO2(mm-1)=CMRO20*(1+cmro2amp*U(mm-1));
    CMRO2(mm)=CMRO20*(1+cmro2amp*U(mm));
    CMRO2a=CMRO20*(1+cmro2amp*U(mm-1));
    CMRO2b=CMRO20*(1+cmro2amp*Uh);
    CMRO2c=CMRO20*(1+cmro2amp*U(mm));
  elseif (cmro2type==3),
    yyy(mm)=yyy(mm-1)+dt*( (1/cmro2tau)*( mytrapezoid3(t(mm-1),St0+Sramps(1),Sdur+Swex,Sramps,fneu_type)-yyy(mm-1) ));
    if (RK_flag),
      yyyk1=dt*( (1/cmro2tau)*( mytrapezoid3(t(mm-1),St0+Sramps(1),Sdur+Swex,Sramps,fneu_type) - yyy(mm-1) ));
      yyyk2=dt*( (1/cmro2tau)*( mytrapezoid3(t(mm-1)+dt/2,St0+Sramps(1),Sdur+Swex,Sramps,fneu_type) - (yyy(mm-1)+yyyk1/2) ));
      yyy(mm)=yyy(mm-1)+yyyk2;
      yyyh=(yyy(mm)-yyy(mm-1))/2;
    end;
    CMRO2(mm-1)=CMRO20*(1+cmro2amp*yyy(mm-1));
    CMRO2(mm)=CMRO20*(1+cmro2amp*yyy(mm));
    CMRO2a=CMRO20*(1+cmro2amp*yyy(mm-1));
    CMRO2b=CMRO20*(1+cmro2amp*yyyh);
    CMRO2c=CMRO20*(1+cmro2amp*yyy(mm));
  elseif (cmro2type==0),
    CMRO2=CMRO20*(1+cmro2amp*myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t));
    if (RK_flag),
      CMRO2a=CMRO20*(1+cmro2amp*myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)));
      CMRO2b=CMRO20*(1+cmro2amp*myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)+dt/2));
      CMRO2c=CMRO20*(1+cmro2amp*myfoh(tdata,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)+dt));
    end;
  end;

  CCt(mm) = CCt(mm-1) + (dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2(mm-1) );

  A =  Fin(mm-1)*2*( Ca - CCc(mm-1) );
  B =  PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt/Vc)*( A - B );

  if (RK_flag),
    Ctk1=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2a );
    Ctk2=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk1/2) ) - CMRO2b );
    Ctk3=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk2/2) ) - CMRO2b );
    Ctk4=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk3) ) - CMRO2c );
    CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;

    Fa=Fin(mm-1);
    Fb=F0*(1+Famp*yyh);
    Fc=Fin(mm);
    Cck1=(dt/Vc)*( Fa*2*(Ca-CCc(mm-1)) - PS*(H_inv(CCc(mm-1),Hparms)-CCt(mm-1)) );
    Cck2=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck1/2)) - PS*(H_inv(CCc(mm-1)+Cck1/2,Hparms)-CCt(mm-1)) );
    Cck3=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck2/2)) - PS*(H_inv(CCc(mm-1)+Cck2/2,Hparms)-CCt(mm-1)) );
    Cck4=(dt/Vc)*( Fc*2*(Ca-(CCc(mm-1)+Cck3)) - PS*(H_inv(CCc(mm-1)+Cck3,Hparms)-CCt(mm-1)) );
    CCc(mm) = CCc(mm-1) + Cck1/6 + Cck2/3 + Cck2/3 + Cck4/6;
  end;

  % oxygen extraction fraction (EE)
  EE(mm) = 2*( 1 - CCc(mm)/Ca );
  [EEs(mm-1),CMRO2s(mm-1)]=valabregue3ff(Fin(mm-1),PS,Pt,Pa);
  EEb(mm-1) = 1 - (1-E0)^(Fin(1)/Fin(mm-1));


  % venous deoxy-hemoglobin amount (q)
  q(mm) = q(mm-1) + dt*( Ca*EE(mm-1)*Fin(mm-1) - q(mm-1)*Fout(mm-1)/Vv(mm-1) );

  BOLD(mm-1) = 1 + kb*( 1 - kb2*(q(mm-1)/q(1))^beta );

end;
Fin(mm)=Fin(mm-1);
Vv(mm)=Vv(mm-1);
Fout(mm)=Fout(mm-1);
EEb(mm)=EEb(mm-1);
EEs(mm)=EEs(mm-1);
CMRO2s(mm)=CMRO2s(mm-1);
q(mm)=q(mm-1);
BOLD(mm)=BOLD(mm-1);

keyboard,
if (nargout==0), plots_flag=1; else, plots_flag=0; end;
if (plots_flag),
  figure(1)
  subplot(211)
  plot(t*60,Fin,'b-')
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
  plot(t*60,EE,'b-',t*60,EEs,'g-',t*60,EEb,'c--')
  ylabel('E')
  xlabel('Time')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  legend('Dynamic','Steady','Steady-Buxton',4)
  subplot(212)
  plot(t*60,BOLD,'b-')
  ylabel('BOLD')
  axis('tight'), grid('on'),
  xlabel('Time')
  dofontsize(15), fatlines,
end;

if (calc_err),
  BOLD_i=interp1(t,BOLD-1,tdata);
  Fin_i=interp1(t,Fin/Fin(1)-1,tdata);
  data=data-1;
  err=[BOLD_i' Fin_i']-data(:,1:2);
  err=[err(:,1)'/max(data(:,1)-1) err(:,2)'/max(data(:,2)-1)];
  if (size(data,2)>2),
    data(:,3)=data(:,3)+1;
    err=err.*[data(:,3)' data(:,3)'];
  end;
  if (flowtype==0)|(cmro2type==0)
    bbeta=0.002;
    err=err+bbeta*sum(abs(diff(sparms(23:end))));
  end;
  [x sum(err.*err)],
  BOLD=err;
  if (nargout==0),
    figure(3)
    subplot(211)
    plot(tdata,data(:,2),tdata,Fin_i)
    subplot(212)
    plot(tdata,data(:,1),tdata,BOLD_i)
  end; 
end;

