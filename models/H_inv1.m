function Ccp_min=H_inv1(x,parms)
% Usage ... Ccp_min=H_inv1(Cc,[cHb PO alpha P50 hill])
%
% Returns the average capillary plasma oxygen concentration given the
% average total capillary oxygen concentration

if nargin<2,
  cHb=2.3;
  PO=4;
  alpha=1.39e-3;
  P50=26;
  hill=2.73;
else,
  cHb=parms(1);
  PO=parms(2);
  alpha=parms(3);
  P50=parms(4);
  hill=parms(5);
end;

hbsattype=1;
if (length(parms)==6),
  neglectplasmaflag=parms(6);
else,
  neglectplasmaflag=0;
end;

Cc = x;

if neglectplasmaflag,

  % use hill eqn and assume plasma contribution negligible
  Ccp_min = alpha*P50 / ((cHb*PO/Cc - 1)^(1/hill));

else,

  % setup search algotrithm
  opt1=optimset('fminbnd');
  opt1.TolX=1e-10;
  
  % find solution via minimization search
  [Ccp_min,fval,exfl,out]=fminbnd(@CpO2min,0,Cc*1.2,opt1,Cc,[cHb PO alpha P50 hill hbsattype]);

end;

