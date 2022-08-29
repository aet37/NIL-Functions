function [E0,CMRO2,C,Cp]=valabregue1f(F0,PS,Pt,Pa0)
% Usage ... [E0,CMRO2,C,Cp]=valabregue1f(F0,PS,Pt,Pa0)
%
% F0,PS in ml/100g/min
% Ca0 in mmol/L

% steady-state simulation of Valabregue compartmental oxygen delivery model
% as appears in JCBFM 23:536 (2003)

% issues:
%  * concentration of Ca0?
%      fully oxygenated blood = 0.204 mL-O2/mL-blood = 9.1 mmol/L
%      (1 mol-O2 = 22,400 mL-O2)
%  * value of PS?


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

if (nargin<4), Pa0=100; end;
if (nargin<3), Pt=0; end;
if (nargin<2), PS=3000; end;
if (nargin<1), F0=50; end;

Ca0=Pa0*alpha/0.015;
Ct=Pt*alpha;

if (length(F0)<2),
  % initialization
  C(1)=Ca0;

  % main loop
  for mm=1:length(x),
    if (mm>1),
      C(mm)=C(mm-1)+(dx/L)*( -(PS/F0)*(Cp(mm-1)-Ct) );
    end;
    % solves for Cp in: C = Cp + Chg  , Chg = [Hb]*PO/( 1 + (a*P50/Cp)^h )
    Cp(mm)=fminbnd(@C_Hb,1e-8,1e2,opt1min,C(mm),[cHb PO alpha P50 hill]);
  end;
  Cp_bar=mean(Cp); 
  CMRO2=(PS/1000)*(Cp_bar-Ct)*(22400/1000);
  E0=1-C(end)/C(1);

else,

  for nn=1:length(F0),
  % initialization
  C(1)=Ca0;
  % main loop
  for mm=1:length(x),
    if (mm>1),
      C(mm)=C(mm-1)+(dx/L)*( -(PS/F0(nn))*(Cp(mm-1)-Ct) );
    end;
    % solves for Cp in: C = Cp + Chg  , Chg = [Hb]*PO/( 1 + (a*P50/Cp)^h )
    Cp(mm)=fminbnd(@C_Hb,1e-8,1e2,opt1min,C(mm),[cHb PO alpha P50 hill]);
  end;
  Cp_bar=mean(Cp);
  CMRO2(nn)=(PS/1000)*(Cp_bar-Ct)*(22400/1000);
  E0(nn)=1-C(end)/C(1);
  end;

end;


if (nargout==0),
  plot(x,C,x,Cp,x,Ct*ones(size(x)))
  legend('C','Cp','Ct')
  xlabel('Length (mm)')
  ylabel('Concentration (mmol/L)')
  title(sprintf('CMRO2 = %f ,  E0 = %f',CMRO2,E0))
end;

