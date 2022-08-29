function [Cc,Cp,SO2x,xx,EE,CMRO2,Cpa_Catot_curve]=valabregue5f(sparms,xparms)
% Usage ... [Cc_x,Cp_x,SO2_x,xx,E,CMRO2]=valabregue5f(sparms)
%
% xparms=[dx]  sparms=[F0 Pa Pt P50 cHb]

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

Cpa_curve=[0.1:0.1:600]*alpha;
Catot_curve = Cpa_curve + (cHb*PO)./(1 + ((P50*alpha)./Cpa_curve).^hill );
Cpa_Ctot_curve=[Cpa_curve(:) Catot_curve(:)];

Ca=interp1(Cpa_curve,Catot_curve,Cpa);

dx=xparms(1);
xx=[0:dx:1];
xlen=length(xx);

Cc(1)=Ca;
Cp(1)=Cpa;
for mm=2:length(xx),
  Cc(mm) = Cc(mm-1) + dx*( -(PS/F0)*( Cp(mm-1) - Ct) );
  Cp(mm) = interp1(Catot_curve,Cpa_curve,Cc(mm));
end;

SO2x=1./(1 + (P50*alpha./Cp).^hill );
EE=1-Cc(end)/Cc(1);
CMRO2=F0*Ca*EE;

if (nargout==0),
  subplot(311)
  plot(xx,SO2x,'k')
  ylabel('S(O_2)')
  title(sprintf('E= %f   CMR_{O2}= %f ',EE,CMRO2*0.0224))
  subplot(312)
  plot(xx,Cc,'b')
  ylabel('Total O_2 Conc.')
  subplot(313)
  plot(xx,Cp/alpha,'r')
  ylabel('Plasma O_2 Conc.')
  xlabel('Norm. Axial Distance')
end;


