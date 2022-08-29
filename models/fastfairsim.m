
clear all

T1=1.5;
T2s=50.0e-3;

alpha=1.0;

minTR=1.0;
maxTR=10.0;
dTR=1.0;

minTI=20e-3;
dTI=20e-3;

TE=0.0;
TRs=[minTR:dTR:maxTR];
nTRs=10;
dM=zeros(length(TRs),length([minTI:dTI:maxTR]));

f1=1;
f2=1;
for m=1:length(TRs),
  TIs=[minTI:dTI:TRs(m)];
  for mm=1:length(TIs)
    M01=1; M02=1;
    for mmm=1:nTRs,
      M1=f1*M01*(1-2*alpha*exp(-TIs(mm)/T1))*exp(-TE/T2s);
      M2=f2*M02*exp(-TE/T2s);
      M01=1-exp(-(TRs(m)-TIs(mm))/T1);
      M02=1;
    end;
    dM(m,mm)=M2-M1;
  end;
end;

