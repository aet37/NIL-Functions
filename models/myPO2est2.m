function [CCt,CCc,CMRO2,t,Fout,VV]=myPO2est2(x,tparms,sparms,parms2fit,tdata,data)
% Usage ... [CCt,CCc,CMRO2]=myPO2est2(x,tparms,sparms,parms2fit,tdata,data)
%
% x = parameters to fit
% tparms = [dt T]
% sparms = [F0 V0 Vk1 camp P50 Vc Vct PS Pa Pt]
% parms2fit = index#'s of sparms that correspond to x
% data is in columns = [CBF PO2 FP]
% tdata is the time vector corresponding to data



if (~isempty(x)),
  sparms(parms2fit)=x;
end;

opt1min=optimset('fminbnd');


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
error_flag=tparms(5);


F0=sparms(1);	% 50
V0=sparms(2);	% 1
Vk3=sparms(3);	% 0.20
ctype=4;

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

%PS=PS*sqrt(Vc/1);

Cpa=Pa*alpha;
Ct=Pt*alpha;
Hparms = [cHb PO alpha P50 hill];
if (neglectplasma), % 1: neglect plasma
  Ca=(cHb*PO)/(1+((P50/Pa)^hill));
  Cc = fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,Fin(1),Hparms);
  CMRO20 = PS*( H_inv(Cc,Hparms) - Ct );
else, % 0: do not neglect plasma
  Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
  Cc = Cc_H_inv1(Pa,[Fin(1) PS Pt],Hparms,1);
  CMRO20 = PS*( H_inv1(Cc,Hparms) - Ct );
end;
E0 = 2*(1-Cc/Ca);
[Cc CMRO20*.0224 E0], 


%bbeta=0.002;
bbeta=sparms(11);

kfp=sparms(12);
CMRO2=CMRO20*(1+camp*kfp*interp1(tdata,data(:,2),t));


%nctype=sparms(15);
%N=sparms(16);
%ytype=[14 N 1.5/60];


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

  % problem here?  
  if (neglectplasma),
    CCp = H_inv(CCc(mm-1),Hparms);
  else,
    CCp = H_inv1(CCc(mm-1),Hparms);
  end;

  A =  Fin(mm-1)*2*( Ca - CCc(mm-1) );
  B =  PS*( CCp - CCt(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt/Vc)*( A - B );
  CCt(mm) = CCt(mm-1) + (dt/Vt)*( PS*( CCp - CCt(mm-1)) - CMRO2(mm-1) );

  if (RK_flag),
    Fa=Fin(mm-1);
    Fb=Finh;
    Fc=Finhh;

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

    CMRO2a=CMRO20*(1+camp*interp1(tdata,data(:,2),t(mm-1)));
    CMRO2b=CMRO20*(1+camp*interp1(tdata,data(:,2),t(mm-1)+dt/2));
    CMRO2c=CMRO20*(1+camp*interp1(tdata,data(:,2),t(mm-1)+dt));

    Ctk1=(dt/Vt)*( PS*( CCp - CCt(mm-1)) - CMRO2a );
    Ctk2=(dt/Vt)*( PS*( CCp - (CCt(mm-1)+Ctk1/2) ) - CMRO2b );
    Ctk3=(dt/Vt)*( PS*( CCp - (CCt(mm-1)+Ctk2/2) ) - CMRO2b );
    Ctk4=(dt/Vt)*( PS*( CCp - (CCt(mm-1)+Ctk3) ) - CMRO2c );
    CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;
  end;

  EE(mm) = 2*( 1 - CCc(mm)/Ca );
  %keyboard,
end;
VV(mm)=VV(mm-1);
Fout(mm)=Fout(mm-1);



if (error_flag),
  %size(t), size(data), size(tdata),
  PO2ti=interp1(tdata',data(:,3)',t);
  zz=PO2ti-CCt/Ct;
  if (nargout==0),
    plot(tdata,data(:,3),tdata,CCt)
  end;    
  zz=zz+bbeta*sum(abs(diff(sparms(12:end))));
  %zz=zz+bbeta*sum(abs(diff(diff(sparms(12:end)))));
  [x sum(zz.*zz)],
  CCt=zz;
elseif (nargout==0),
  subplot(411)
  plot(t,Fin)
  ylabel('F')
  axis('tight'); grid('on'); fatlines;
  subplot(412)
  plot(t,CCc)
  ylabel('Cc')
  axis('tight'); grid('on'); fatlines;
  subplot(413)
  plot(t,CCt)
  ylabel('Ct')
  axis('tight'); grid('on'); fatlines;
  subplot(414)
  plot(t,CMRO2)
  ylabel('CMR_{O2}')
  axis('tight'); grid('on'); fatlines;
end;

