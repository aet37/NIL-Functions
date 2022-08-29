
clear all
load NIRS_extData.txt

lambda=NIRS_extData(:,1);
e_HbO2=NIRS_extData(:,2);
e_Hb=NIRS_extData(:,3);

SO2=0.85;
cHb_total=150;		% units: g/L
cHbO2=cHb_total/64500;	% units: g/L / g(Hb)/mol = mol/L = M

mu_a=2.303*e_HbO2*cHbO2;

