function [Ccx,Ccpx,SO2x,EE,CMRO2]=valabregue5f(sparms)
% Usage ... [Cc,Cp,SO2_x,E,CMRO2]=valabregue5f(sparms)
%
% sparms=[F0 Pa Pt P50 cHb]

F0=sparms(1);
Pa=sparms(2);
Pt=sparms(3);
PS=sparms(4);
P50=sparms(5);
cHb=sparms(6);

alpha=1.39e-3;
hill=2.73;
PO=4;

Cpa=Pa*alpha;
Ct=Pt*alpha;
Hparms = [cHb PO alpha P50 hill];

Cpa_curve=[0.1:0.1:1.5*Pa]*alpha;
Catot_curve = Cpa_curve + (cHb*PO)./(1 + ((P50*alpha)./Cpa_curve).^hill );
Cpa_Ctot_curve=[Cpa_curve(:) Catot_curve(:)];

Ca=interp1(Cpa_curve,Catot_curve,Cpa);

Cc_curve=[1:1e4]*(Ca/1e4);
Ccp_curve=interp1(Catot_curve,Cpa_curve,Cc_curve);

Cc=interp1(2*F0*(Ca-Cc_curve)-PS*(Ccp_curve-Ct),Cc_curve,0);
Ccp=interp1(Catot_curve,Cpa_curve,Cc);
Cv=2*Cc-Ca;
Cvp=interp1(Catot_curve,Cpa_curve,Cv);

CMRO2=PS*(Ccp-Ct);
EE=2*(1-Cc/Ca);
SO2=1./(1 + (P50*alpha./Ccp).^hill );
SO2a=1./(1 + (P50/Pa).^hill );
SO2v=1./(1 + (P50*alpha./Cvp).^hill );

Ccx=[Cc Ca Cv];
Ccpx=[Ccp Cpa Cvp];
SO2x=[SO2 SO2a SO2v];

if (nargout==0),
  disp(sprintf(' Ca_tot= %f  Cc_tot= %f  Cv_tot= %f  EE= %f',Ca,Cc,Cv,E0));
  disp(sprintf(' SO2a= %f    SO2c= %f    SO2v= %f',SO2a,SO2,SO2v));
  disp(sprintf(' Pa= %f      Pc= %f      Pv= %f',Pa,Ccp/alpha,Cvp/alpha));
  disp(sprintf(' Pt= %f  PS= %f  FF= %f  CMRO2= %f',Pt,PS,F0,CMRO2));
end;


