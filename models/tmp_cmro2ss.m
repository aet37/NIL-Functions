
clear all

F0=40;
PS=7000;
Pa=500;
Pt=41.2;

alpha=1.39e-3;
P50=26;
hill=2.73;
hparms=[2.3  4  alpha  P50  hill];

Ca=Pa*alpha+(2.3*4)/(1+((P50/Pa)^hill));
Cc=Cc_H_inv1(Pa,[F0 PS Pt],hparms,0);
CMRO2=0.0224*PS*(H_inv1(Cc,hparms) - Pt*alpha);
E0=2*(1-Cc/Ca);

