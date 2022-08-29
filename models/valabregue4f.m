function [CMRO2,E,Cc]=valabregue4f(F0,PS,Pt,Pa)
% Usage ... [CMRO2,E,Cc]=valabregue4f(F0,PS,Pt,Pa)

if (Pt<0),
  disp('Warning: Pt < 0 !!!');
end;
if (Pt>Pa),
  disp('Warning: Pt > Pa !!!');
end;


alpha=1.39e-3;	% units: mmol/L/mmHg
P50=26;		% units: mmHg
hill=2.73;
cHb=2.3;	% units: mmol/L
PO=4;

if (nargin<4), Pa0=100; end;
if (nargin<3), Pt=0; end;
if (nargin<2), PS=7000; end;
if (nargin<1), F0=50; end;

% calculate the initial condition first from the steady state solution
%   assume CMRO2 is given (units: mmol/min)
%     we can solve for either Ct, Cp (mmol/ml) or PS (ml/min)
%     PS has been reported around to be around 3000 to 7000 ml/min!
%     but this is likely dependent on the choice of L!
%   assume Cp_bar is known
%

%CMRO20=2.7938;
%Cp_bar=0.0065;
%PS=CMRO20/(Cp_bar-Ct);



Cpa=Pa*alpha;
Ct=Pt*alpha;

% find total Ca, given Pa or Cpa
Ca=Cpa+cHb*PO*HbSat(Pa,[P50 hill],1);

for mm=1:length(F0),

  % find total average capillary O2, given Cpa Ct PS F0
  Cc(mm) = fminbnd(@Ccmin,0,Ca,optimset('TolX',1e-10),Pa,Pt,PS,F0);
  CMRO2(mm) = PS*( H_inv1(Cc(mm),[cHb PO alpha P50 hill]) - Ct );
  E(mm) = 2*(1-Cc(mm)/Ca);

end;



