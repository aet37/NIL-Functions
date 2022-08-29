
clear all


PS=7000;
Pa0=100;

F0=[10:5:200];
Pt=[0:5:40];

for nn=1:length(Pt),
  for mm=1:length(F0),
    [E0(mm,nn),CMRO20(mm,nn)]=valabregue1f(F0(mm),PS,Pt(nn),Pa0);
  end;
end;

subplot(211)
plot(F0,CMRO20')
axis('tight'), grid('on'),
ylabel('CMRO2 (ml/min)')
title(sprintf('PS = %f   Pa0 = %f',PS,Pa0))
subplot(212)
plot(F0,E0')
axis('tight'), grid('on'),
ylabel('O2 Extraction')
xlabel('CBF (ml/min)')

