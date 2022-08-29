function Cp_min=C_Hb(x,C,cHb_parms)

if (nargin<3),
  cHb=23;
  PO=4;
  alpha=1.39e-3;
  P50=26;
  hill=2.73;
else,
  cHb=cHb_parms(1);
  PO=cHb_parms(2);
  alpha=cHb_parms(3);
  P50=cHb_parms(4);
  hill=cHb_parms(5);
end;

Cp = x;

Cp_min = Cp - C + cHb*PO./( 1 + (alpha*P50./Cp).^hill );
Cp_min = abs(Cp_min);

if (nargout==0)
  plot(Cp,Cp_min)
  xlabel('Cp')
  ylabel('Cp min')
end;

