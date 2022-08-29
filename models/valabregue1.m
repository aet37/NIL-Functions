
% steady-state simulation of Valabregue compartmental oxygen delivery model
% as appears in JCBFM 23:536 (2003)

% issues:
%  * concentration numbers for Ct and Ca0?
%  * flow term units? F(dC/dx)dx ?

clear all


% general simulation variables

opt1min=optimset('fminbnd');

L=200e-4;	% units: cm
dx=L/100;
x=[0:dx:L];	% units: cm

alpha=1.39e-3;	% units: mmol/L/mmHg
hill=2.73;
P50=26;		% units: mmHg
PO=4;
cHb=2.3;	% units: mmol/L
Ca0=100*alpha/0.015;	% units: mmol/L (???)
PS=30;		% units: mL/min/100g
F0=50;		% units: mL/min/100g

% initialization
C(1)=Ca0;

% assume we know Ct
Ct=0*alpha;

% main loop
for mm=1:length(x),
  if (mm>1),
    C(mm)=C(mm-1)+(dx/dx)*( -(PS/F0)*(Cp(mm-1)-Ct) );
  end;
  % solves for Cp in: C = Cp + Chg  , Chg = [Hb]*PO/( 1 + (a*P50/Cp)^h )
  Cp(mm)=fminbnd(@C_Hb,1e-8,1e2,opt1min,C(mm),[cHb PO alpha P50 hill]);
end;
Cp_bar=mean(Cp);
CMRO2=PS*(Cp_bar-Ct)*0.0224;
E0=1-C(end)/C(1);

plot(x,C,x,Cp,x,Ct*ones(size(x)))
legend('C','Cp','Ct')
xlabel('Length (mm)')
ylabel('Concentration (mmol/L ?)')
title(sprintf('E0 = %f',E0))

