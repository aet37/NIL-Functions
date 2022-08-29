function [Cc_min,Cca] = CcO2min(x,parms,Hparms,neglectplasmaflag)
% Usage ... [Cc_min,Cca] = CcO2min(x,parms,Hparms,neglectplasmaflag)

cHb=Hparms(1);
PO=Hparms(2);
alpha=Hparms(3);
P50=Hparms(4);
hill=Hparms(5);

F0=parms(1);
PS=parms(2);
Ct=alpha*parms(3);
Cpa=alpha*parms(4);


Cc = x;

if neglectplasmaflag,
  Cca = cHb*PO/(1+(alpha*P50/Cpa)^hill);
else,
  Cca = Cpa + cHb*PO/(1+(alpha*P50/Cpa)^hill);
end;

Cc_min = 2*F0*(Cca-Cc) - PS*(H_inv1(Cc,Hparms)-Ct);
Cc_min=abs(Cc_min);

