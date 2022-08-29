function Cc_min=Cc_H_inv1(Pa,parms,Hparms,neglectplasmaflag)
% Usage ... Cc_min=Cc_H_inv1(Pa,[F0 PS Pt],[cHb PO alpha P50 hill],neglectplasmaflag)
%
% Returns the average capillary plasma oxygen concentration given the
% average total capillary oxygen concentration

if nargin<3,
  Hparms=[2,3 4 1.39e-3 26 2.73];
end;
if nargin<2,
  parms=[55 7000 29.7 100.0];
end;

cHb=Hparms(1);
PO=Hparms(2);
alpha=Hparms(3);
P50=Hparms(4);
hill=Hparms(5);

F0=parms(1);
PS=parms(2);
Pt=parms(3);

Ct=Pt*alpha;
Cpa=Pa*alpha;

hbsattype=1;



  % use hill eqn and assume plasma contribution negligible
  % solve for Cc
  Cca = cHb*PO/(1+(alpha*P50/Cpa)^hill);

  % setup search algotrithm
  opt1=optimset('fminbnd');
  opt1.TolX=1e-10;
  
  % find solution via minimization search
  % set upper bound to 15% above Cca found above
  [Cc_min,fval,exfl,out]=fminbnd(@CcO2min,0,1.15*Cca,opt1,[F0 PS Pt Pa],[cHb PO alpha P50 hill],neglectplasmaflag);


