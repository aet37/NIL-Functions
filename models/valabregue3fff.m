function [CMRO2,E,Cc]=valabregue3ff(F0,PS,Pt,Pa)
% Usage ... [CMRO2,E,Cc]=valabregue3ff(F0,PS,Pt,Pa)

if (Pt<0),
  disp('Warning: Pt < 0 !!!');
end;
if (Pt>Pa),
  disp('Warning: Pt > Pa !!!');
end;

opt1min=optimset('fminbnd');
dtol=1e-10;

L=400e-4;	% units: cm
dx=L/100;
x=[0:dx:L];	% units: cm

alpha=1.39e-3;	% units: mmol/L/mmHg
P50=26;		% units: mmHg
hill=2.73;
cHb=2.3;	% units: mmol/L
PO=4;

if (nargin<4), Pa0=100; end;
if (nargin<3), Pt=0; end;
if (nargin<2), PS=3000; end;
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
Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
Ct=Pt*alpha;


Hparms = [cHb PO alpha P50 hill];
for mm=1:length(F0),

  Cc(mm) = fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,F0(mm),Hparms);
  CMRO2(mm) = PS*( H_inv(Cc(mm),Hparms) - Ct );
  E(mm) = 2*(1-Cc(mm)/Ca);

end;



%Ea = 2*(1-fminbnd(@H_inv,1e-8,1e3,opt1min,Ca,Ct,PS,F0*(1+famp),Hparms)/Ca);
%
%if (BOLD_flag),
%  F1=F/F(1);
%  V1(1)=0; vtau=2/60; V1b(1)=0; for mm=2:length(t), V1(mm)=V1(mm-1)+(dt/vtau)*((F1(mm-1)-1)-V1(mm-1)); V1b(mm)=V1b(mm-1)+(dt/(vtau*5))*((F1(mm-1)-1)-V1b(mm-1)); end; V1=0.15*V1+0.15*V1b+1;
%  [B1,F1o,Q1]=simpleBOLD(F1,V1,EE,[dt 1 1/60]);
%end;
%
%if (plots_flag),
%  subplot(311)
%  plot(t*60-4.0,0.5*B1+1,tt1,avgE1)
%  ylabel('BOLD')
%  axis('tight'), grid('on'),
%  ax=axis; axis([0 118 ax(3:4)]);
%  dofontsize(15), fatlines,
%  legend('Est.','Meas.')
%  subplot(312)
%  plot(t*60-1.5,5*(CMRO2/CMRO2(1)-1)+1,tt1,CMRO2c/CMRO2c(1))
%  ylabel('rCMRO2')
%  axis('tight'), grid('on'),
%  ax=axis; axis([0 118 ax(3:4)]);
%  dofontsize(15), fatlines,
%  legend('Dynamic','Steady')
%  subplot(313)
%  plot(t*60-3.0,0.78*(EE/EE(1)-1)+.405,tt1,EEc)
%  ylabel('E')
%  xlabel('Time')
%  axis('tight'), grid('on'),
%  ax=axis; axis([0 118 ax(3:4)]);
%  dofontsize(15), fatlines,
%  legend('Dynamic','Steady',4)
%  %subplot(311)
%  %plot(t*60-4.0,0.5*B1+1,tt1,avgE1)
%  %ylabel('BOLD')
%  %axis('tight'), grid('on'),
%  %ax=axis; axis([0 118 ax(3:4)]);
%  %dofontsize(15), fatlines,
%  %subplot(312)
%  %plot(t*60-1.0,5*(CMRO2/CMRO2(1)-1)+1,tt1,CMRO2c/CMRO2c(1))
%  %ylabel('rCMRO2')
%  %axis('tight'), grid('on'),
%  %ax=axis; axis([0 118 ax(3:4)]);
%  %dofontsize(15), fatlines,
%  %subplot(313)
%  %plot(t*60-3.0,0.78*(EE/EE(1)-1)+.405,tt1,EEc)
%  %ylabel('E')
%  %xlabel('Time')
%  %axis('tight'), grid('on'),
%  %ax=axis; axis([0 118 ax(3:4)]);
%  %dofontsize(15), fatlines,
%end;

