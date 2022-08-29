
clear all

% a better simulation is necessary to estimate the imperfections of the
% flow estimate on the inversion pulse profile. Monte Carlo???

TT=[0:1e-3:2]';

M0=1000;
alpha=0.95;
T1=1.5;

lambda=0.9;
ff=[1 1.5];

for mm=1:length(ff),
  Mns(:,mm)=M0*(1-2*alpha*exp(-TT*(1/T1)));
  Mss(:,mm)=M0*(1-2*alpha*exp(-TT*(1/T1+ff(mm)/lambda)));
  FAIR(:,mm)=Mss(:,mm)-Mns(:,mm);
  FAIRmax(mm)=max(FAIR(:,mm));
  FAIRtmax(mm)=TT(find(FAIR(:,mm)==FAIRmax(mm)));
end;

plot(TT,FAIR)

