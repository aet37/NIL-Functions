function [signal,Cc,Ct,Cv,Ca,E,ctss,cvss]=davis2(t,ic,Vc,Vt,Vv,F,CMRO2)
% Usage ... [signal,Cc,Ct,Cv,Ca,E]=davis2(t,ic,Vc,Vt,Vv,F,CMRO2)

% This model model was obtained/presented at the San Francisco
% SMR Meeting in 1994 by TL Davis abstract #69 

% The essentials of the model
% dynamic mass conservation model where the capillaries are
% treated as a distributed compartment interacting with a well-
% mixed tissue compartment and a venous out-flow compartment
% tissue O2 compartment allows for transient disequilibrium
% between tissue O2 pool and end-capillary pO2 (half of O2 is
% bound to Hb, the rest is dissolved in tissue volume -- larger)

% F - blood flow
% V - volume (sub: c capillaries, t tissue, v venous)
% C - O2 concentrations as a function of time
% PS - resistance to diffusion of O2 from blood to tissue
% a - ratio of O2 solubility blood to tissue

% How the model actually works
% amount per unit time of O2 in capillaries depends on the amount of
% O2 flowing (function of space), the amount of O2 in the compartment
% that is not diffusing blood-to-tissue and the amount diffusing
% tissue-to-blood
% amount per unit time of O2 in tissue depends on the amount of O2
% diffusing tissue-to-blood and the amount not-diffusing blood-to-
% tissue, along with the amount being used by tissue 
% amount per unit time of O2 in venules depends on the amount carried
% by blood in the venules and the amount present at the end of the
% capillaries entering the venous side

% How to simulate activation...
% Flow increase F by 70% (trapezoid, 2s ramp)
% CMRO2 increase by 20% (step function)
% Capillary volume (Vc) proportional to F^0.4 
% no RK integration yet, uniform spacing assumed

tlen=length(t);
h=t(2)-t(1);

Ca=ic(1)*ones([length(t) 1]);
Cc(1)=ic(2);
Ct(1)=ic(3);
Cv(1)=ic(4);

x = [0:1e-2:1];
E = 1 - exp(-PS*1./F);
Ccx(1) = Ca(1) - (CMRO2(1)/(F(1)*E(1)))*(1-exp(-PS*1/(a*F(1))));
ctss(1) = (1/a)*( Ca(1) - (CMRO2(1)/(F(1))*(1/E(1)) );
cvss(1) = Ca(1) - CMRO2(1)/F(1);

for m=1:tlen,

  Ccx(m+1) = Ca(m+1) - (CMRO2(m+1)/(F(m+1)*E(m+1)))*(1-exp(-PS*1/(a*F(m+1))));

  ctss(m+1) = (1/a)*( Ca(m+1) - (CMRO2(m+1)/F(m+1))*(1/E(m+1)) );
  cvss(m+1) = Ca(m+1) - CMRO2(m+1)/F(m+1);

  dCcx(m) = (CMRO2(m)/(F(m)*E(m)))*(-PS/(a*F(m)))*exp(-PS*1/(a*F(m)));
  Cc(m+1) = h*(1/Vc(m))*(-F(m)*dCcx(m) -PS*Cc(m)/a +PS*Ct(m));
  Ct(m+1) = h*(1/Vt(m))*(+PS*Cc(m)/a -PS*Ct(m) -CMRO2(m));
  Cv(m+1) = h*(1/Vv(m))*(-F(m)*Cv(m) +F(m)*Cc(m));

end;

dCcx(m+1) = (CMRO2(m+1)/(F(m+1)*E(m+1)))*(-PS/(a*F(m+1)))*exp(-PS*1/(a*F(m+1)));

k=1;
signal=k*Cv;

