
Ppo2a=[0:100]+0.01;
Ppo2b=[0:500]+0.01;

alpha=1.39e-3;		% mmol/L/mmHg
cHb=2.3;		% mmol/L
PO=4;			% none

Cp1a=alpha*Ppo2a;
Cp1b=alpha*Ppo2b;

Ctotal1a = Cp1a + HbSat(Ppo2a)*cHb*PO;
Ctotal1b = Cp1b + HbSat(Ppo2b)*cHb*PO;

Ctotal2a = Cp1a + HbSat(Ppo2a,2)*cHb*PO;
Ctotal2b = Cp1b + HbSat(Ppo2b,2)*cHb*PO;

