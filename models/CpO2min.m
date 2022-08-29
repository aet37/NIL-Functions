function cpo2min=CpO2min(Cplasma,Ctotal,parms)
% Usage ... cpo2min=CpO2min(Cplasma,Ctotal,parms)

cHb=parms(1);
PO=parms(2);
alpha=parms(3);
P50=parms(4);
hill=parms(5);
Hbsattype=parms(6);

cpo2min = Cplasma + cHb*PO*HbSat(Cplasma/alpha,[P50 hill],Hbsattype) - Ctotal;
cpo2min=abs(cpo2min);

%[Cplasma Ctotal cpo2min],

