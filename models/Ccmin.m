function cc_min = Ccmin(Cc,Pa,Pt,PS,F0)
% Usage ... cc_min = Ccmin(Cc,Pa,Pt,PS,F0)

alpha=1.39e-3;
cHb=2.3;
PO=4;

Cp = Pa*alpha;
Ct = Pt*alpha;

Ca = Cp + cHb*PO*HbSat(Pa,[26 2.73],1);

cc_min = 2*F0*(Ca - Cc) - PS*(H_inv1(Cc,[cHb PO alpha 26 2.73]) - Ct);
cc_min = abs(cc_min);

