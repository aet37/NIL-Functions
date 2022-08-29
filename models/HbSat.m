function y=HbSat(Ppo2,parms,satform)
% Usage ... y=HbSat(Ppo2,parms,satform)
%
% Ppo2 is the plasma O2 tension in mmHg and parms = [P50 hill]

if (nargin<3),
  satform=1;
end;
if (nargin<2),
  parms=[26 2.73];
end;

ii=find(Ppo2>0);

y=zeros(size(Ppo2));
Ppo2p=Ppo2(ii);

if satform==2,
  % severinghaus (satform==2)
  %
  % pH correction
  %  pHref=7.4;
  %  PO2_corrected=PO2*exp(1.1*(pH-pHref));
  %   which is d_lnPO2=d_pH*(Ppo2p/26.6).^0.08-1.52;
  %   or alternatively d_lnPO2_2=d_pH*(Ppo2p/26.7).^0.184+0.003*BohrEff-2.2;
  %
  a1=150;
  a0=23400;
  y2 = ( Ppo2p.^3 + a1*Ppo2p )./( Ppo2p.^3 + a1*Ppo2p + a0 );
else,
  % hill (satform==1)
  P50=parms(1);
  hill=parms(2);
  y2 = 1./( 1 + (P50./Ppo2p).^hill );
end;

y(ii)=y2;

