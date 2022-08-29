
clear all

Vbar=1e-2;
TH=5e-3;

M0ss=1;
alphass=1;

M0ns=1;
alphans=1;

T1=2000;
T1=T1*1e-3;

TR=10000;
TR=TR*1e-3;

TI=[0:TR/100:TR];

for m=1:length(TI),
  finv(m) = 1 - Vbar*TI(m)/TH;
  if (finv(m)<0) finv(m)=0; end;
  fup(m) = 1 - finv(m);
  Mns(m) = M0ns*(1-2*alphans*exp(-TI(m)/T1));
  Mss(m) = M0ss*(1-2*alphass*exp(-TI(m)/T1))*finv(m) + M0ss*fup(m);
end;

dM=Mns-Mss;

[dMmin,dMmini]=min(dM);
Vbarest=TH/TI(dMmini),

subplot(311)
plot(TI,finv)
subplot(312)
plot(TI,Mns,TI,Mss)
subplot(313)
plot(TI,dM)

