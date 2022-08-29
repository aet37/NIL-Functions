function M=calcM(B0,B1,F0,F1,V0,V1)
% Usage ... M=calcM(B0,B1,F0,F1,V0,V1)
%
% Calculates the calibration factor for Davis computation of CMRO2

% In Davis paper (PNAS 95:1834 1998)
%
%  M = (Bh - 1)/(1 - Fh^(a-b)) = (Bh - 1)/(1 - Vh.Fh^(-b))
%

if (nargin<3),
  F1=B1;
  F0=1;
  B1=B0;
  B0=1;
end;

B1=B1./B0; B0=B0./B0;
F1=F1./F0; F0=F0./F0;

if (nargin<5),
  V1=(F1./F0).^0.4;
  V0=ones(size(V1));
else,
  V1=V1./V0; V0=V0./V0;
end;

Bh=B1./B0;
Vh=V1./V0;
Fh=F1./F0;

%M=(Bh-1)./(1-((Vh./Fh).^(1.5)));

M=(Bh-1)./(1-(Vh.*(Fh^(-1.5))));

