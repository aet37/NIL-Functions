function Cp = H_inv2(C,parms)
% Usage ... Cp = H_inv2(C,parms)
%
% parms = [Pa Hb PO P50 alpha hill]

% similar to H_inv except that it does not assume negligible plasma O2 tension

if (nargin<2),
  parms=[100 2.3 4 26 1.39e-3 2.73];
end;

opt1=optimset('fminbnd');

cmin=1e-8;
cmax=parms(1)*parms(5);

Cp=fminbnd(@C_Hb,cmin,cmax,opt1,C,parms(2:end));

