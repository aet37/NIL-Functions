function Cc_min=H_inv(x,Ca,Ct,PS,F0,parms)
% Usage ... Cc_min=H_inv(Cc,Ca,Ct,PS,F0,[cHb PO alpha P50 hill])


if (nargin==6),
  cHb=parms(1);
  PO=parms(2);
  alpha=parms(3);
  P50=parms(4);
  hill=parms(5);
elseif (nargin==2),
  cHb=Ca(1);
  PO=Ca(2);
  alpha=Ca(3);
  P50=Ca(4);
  hill=Ca(5);
else,
  cHb=2.3;
  PO=4;
  alpha=1.39e-3;
  P50=26;
  hill=2.73;
end;

Cc = x;
Hinv = alpha*P50 / ((cHb*PO/Cc - 1)^(1/hill));

if (nargin>2),
  
  Cc_min = 2*F0*(Ca - Cc) - PS*(real(Hinv) - Ct);
  Cc_min = abs(Cc_min);
  
else,

  Cc_min = Hinv;

end;

