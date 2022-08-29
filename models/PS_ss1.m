function Pv_est=PS_ss1(x,hparms,F,Pa,Pt,Pv)
% Usage ... Pv_est=PS_ss1(x,hparms,F,Pa,Pt,Pv)
%
% PS_ss1(7000,[1.99 38 2.73 1.39e-3],150,Pa,Pt,Pv)
%  or
% fminbnd(@PS_ss1,1e3,1e5,optimset('fminbnd'),[1.99 38 2.73 1.39e-3],150,Pa,Pt,Pv)

PS=x;

Chb=hparms(1);
P50=hparms(2);
hill=hparms(3);
alpha=hparms(4);

Pa_max=150;
Cp_curve=[0.001:0.001:Pa_max]*alpha;
Cc_curve=Cp_curve+4*Chb./(1+(alpha*P50./Cp_curve).^hill);

Ca=interp1(Cp_curve,Cc_curve,alpha*Pa);
Ct=alpha*Pt;

dx=0.05;
xx=[0:dx:1];

C(1)=Ca;
Cpx(1)=Pa*alpha;
for mm=2:length(xx),
  C(mm) = C(mm-1) + dx*( -(PS/F)*(Cpx(mm-1)-Ct) );
  Cpx(mm)=interp1(Cc_curve,Cp_curve,C(mm));
end;
Cp_bar=mean(Cpx);
Pv_est=Cpx(end)/alpha;

if nargin==6,
  disp(sprintf('  %.2f  %.2f  %.1f',Pv_est,Pv,PS));
  Pv_est=abs(Pv_est-Pv);
end;

