function [CCt,CCc,CMRO2,t,Fout,VV]=myPO2est3(x,tparms,sparms,parms2fit,iunfix,ifix,ttt,tdata,data)
% Usage ... [CCt,CCc,CMRO2]=myPO2est3(x,tparms,sparms,parms2fit,iunfix,ifix,ttt,tdata,data)
%
% x = parameters to fit
% tparms = [dt T]
% sparms = [F0 V0 Vk1 camp P50 Vc Vct PS Pa Pt]
% parms2fit = index#'s of sparms that correspond to x
% data is in columns = [CBF PO2normchange]
% tdata is the time vector corresponding to data



if (~isempty(x)),
  sparms(parms2fit)=x;
end;

opt1min=optimset('fminbnd');

RK_flag=1;
plots_flag=2;
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


F0=sparms(1);	% 50
V0=sparms(2);	% 1
Vk1=20;
Vk2=0.0080;
Vk3=sparms(3);	% 0.20
ctype=4;
Ek1=1.0;


camp=sparms(4);

Fin=F0*interp1(tdata,data(:,1),t);

alpha=1.39e-3;
P50=sparms(5);		% 26
hill=2.73;
cHb=2.3;
PO=4;

Vc=sparms(6);		% 1
Vct=sparms(7);		% 98
PS=sparms(8);		% 7200
Pa=sparms(9);		% 90
Pt=sparms(10);		% 20
Vt=Vct-Vc;
PS=PS*sqrt(Vc/1);

Cpa=Pa*alpha;
Ct=Pt*alpha;
Hparms = [cHb PO alpha P50 hill];
if (neglectplasma),
  Ca=(cHb*PO)/(1+((P50/Pa)^hill));
  Cc = fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,Fin(1),Hparms);
  CMRO20 = PS*( H_inv(Cc,Hparms) - Ct );
else,
  Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
  Cc = Cc_H_inv1(Pa,[Fin(1) PS Pt],Hparms,1);
  CMRO20 = PS*( H_inv1(Cc,Hparms) - Ct );
end;
E0 = 2*(1-Cc/Ca);
[Cc CMRO20 E0], 


%bbeta=0.002;
bbeta=sparms(11);


xunfix=sparms(12:end);

CMRO2=CMRO20*(1+camp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t));




sb1=4.3*(42.57*1e-6*3.0*1.0e-6);
sb2=2.0;
sb3=0.6;

%nctype=sparms(15);
%N=sparms(16);
%ytype=[14 N 1.5/60];
%y2st=sparms(17); y2dur=sparms(18); y2ramp=sparms(19); u2tau(20)=sparms(20);

VV(1)=V0; Fin(1)=F0; Fout(1)=F0;
CCt(1)=Ct; CCc(1)=Cc; EE(1)=E0;
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

  A =  Fin(mm-1)*2*( Ca - CCc(mm-1) );
  B =  PS*( CCp - CCt(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt/Vc)*( A - B );

  D =  PSm*( CCt(mm-1) - CCm(mm-1) );
  CCt(mm) = CCt(mm-1) + (dt/Vt)*( B - D );
  %CCt(mm) = CCt(mm-1) + (dt/Vt)*( B - CMRO2(mm-1) );

  CCm(mm) = CCm(mm-1) + (dr/Vm)*( D - CMRO2(mm-1) );

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
    Cck1=(dt/Vc)*( Fa*2*(Ca-CCc(mm-1)) - PS*(CCp-CCt(mm-1)) );
    if (neglectplasma),
      Cck2=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck1/2)) - PS*(H_inv(CCc(mm-1)+Cck1/2,Hparms)-CCt(mm-1)) );
      Cck3=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck2/2)) - PS*(H_inv(CCc(mm-1)+Cck2/2,Hparms)-CCt(mm-1)) );
      Cck4=(dt/Vc)*( Fc*2*(Ca-(CCc(mm-1)+Cck3)) - PS*(H_inv(CCc(mm-1)+Cck3,Hparms)-CCt(mm-1)) );
    else,
      Cck2=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck1/2)) - PS*(H_inv1(CCc(mm-1)+Cck1/2,Hparms)-CCt(mm-1)) );
      Cck3=(dt/Vc)*( Fb*2*(Ca-(CCc(mm-1)+Cck2/2)) - PS*(H_inv1(CCc(mm-1)+Cck2/2,Hparms)-CCt(mm-1)) );
      Cck4=(dt/Vc)*( Fc*2*(Ca-(CCc(mm-1)+Cck3)) - PS*(H_inv1(CCc(mm-1)+Cck3,Hparms)-CCt(mm-1)) );
    end;
    CCc(mm) = CCc(mm-1) + Cck1/6 + Cck2/3 + Cck2/3 + Cck4/6;

    CMRO2a=CMRO20*(1+camp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)));
    CMRO2b=CMRO20*(1+camp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)+dt/2));
    CMRO2c=CMRO20*(1+camp*myfoh(ttt,iunfix,xunfix,ifix(:,1),ifix(:,2),t(mm-1)+dt));
    Ctk1=(dt/Vt)*( PS*( CCp - CCt(mm-1)) - CMRO2a );
    Ctk2=(dt/Vt)*( PS*( CCp - (CCt(mm-1)+Ctk1/2) ) - CMRO2b );
    Ctk3=(dt/Vt)*( PS*( CCp - (CCt(mm-1)+Ctk2/2) ) - CMRO2b );
    Ctk4=(dt/Vt)*( PS*( CCp - (CCt(mm-1)+Ctk3) ) - CMRO2c );
    CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;
  end;

  EE(mm) = 2*( 1 - CCc(mm)/Ca );

end;
VV(mm)=VV(mm-1);
Fout(mm)=Fout(mm-1);


if (nargout==0), plots_flag=2; else, plots_flag=0; end;
if (plots_flag==2),

  subplot(311)
  plot(t*60,Fin,'b-')
  ylabel('CBF')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  subplot(312)
  plot(t*60,CMRO2,'b-',t*60,CMRO2s,'g-')
  ylabel('rCMRO2')
  axis('tight'), grid('on'),
  xlabel('Time')
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  legend('Dynamic','Steady')
  subplot(313)
  plot(t*60,EE,'b-',t*60,EEs,'g-',t*60,EEb,'c-')
  ylabel('E')
  xlabel('Time')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  legend('Dynamic','Steady','Steady2',4)

end;

%time-shift?
%PO2=???


if (size(data,2)>1),
  %size(t), size(data), size(tdata),
  PO2ti=interp1(tdata',data(:,2)',t);
  zz=PO2ti-CCt/Ct;
  if (nargout==0),
    plot(tdata,data(:,2),tdata,CCt)
  end;    
  zz=zz+bbeta*sum(abs(diff(sparms(12:end))));
  %zz=zz+bbeta*sum(abs(diff(diff(sparms(12:end)))));
  [x sum(zz.*zz)],
  CCt=zz;
end;

