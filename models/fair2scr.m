
clear all

Vbar=1e-2;
THim=5e-3;
THinvss=10e-3;
THinvns=100e-3;

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

  t2imin = ( THinvns/2 - THim/2 ) / Vbar;
  t2imout = t2imin + THim/Vbar;
  if (TI(m) < t2imin),
    finvns(m) = 1;
  elseif ((TI(m)>=t2imin)&(TI(m)<=t2imout)),
    finvns(m) = 1 - Vbar*(TI(m)-t2imin)/THim;
  else,
    finvns(m) = 0;
  end;
  fupns(m) = 1 - finvns(m);

  t2imin = ( THinvss/2 - THim/2 ) / Vbar;
  t2imout = t2imin + THim/Vbar;
  if (TI(m) < t2imin),
    finvss(m) = 1;
  elseif ((TI(m)>=t2imin)&(TI(m)<=t2imout)),
    finvss(m) = 1 - Vbar*(TI(m)-t2imin)/THim;
  else,
    finvss(m) = 0;
  end;
  fupss(m) = 1 - finvss(m);

  Mns(m) = M0ns*(1-2*alphans*exp(-TI(m)/T1))*finvns(m) + M0ns*fupns(m);
  Mss(m) = M0ss*(1-2*alphass*exp(-TI(m)/T1))*finvss(m) + M0ss*fupss(m);

end;

dM=Mns-Mss;

[dMmin,dMmini]=min(dM);
Vbarest=(THim+THinvss/2-THim/2)/TI(dMmini),

subplot(311)
plot(TI,finvns,TI,finvss)
subplot(312)
plot(TI,Mns,TI,Mss)
subplot(313)
plot(TI,dM)

