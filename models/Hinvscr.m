
clear all

alpha=1.39e-3;
P50=26;
hill=2.73;
cHb=2.3;
PO=4;

Pa=100;

P=[1:Pa];

for mm=1:length(P),
  Pp1(mm)=H_inv1(P(mm)*alpha,[cHb PO alpha P50 hill])/alpha;
  Pp2(mm)=H_inv2(P(mm)*alpha,[Pa+1 cHb PO P50 alpha hill])/alpha;

  PT1(mm)=Pp1(mm)+(1/alpha)*(cHb*PO)/(1+(P50/Pp1(mm))^(hill));
  PT2(mm)=Pp2(mm)+(1/alpha)*(cHb*PO)/(1+(P50/Pp2(mm))^(hill));
end;

subplot(311)
plot(P,Pp1,P,Pp2)
ylabel('Plasma O2')
xlabel('PaO2')
axis('tight'), grid('on'), fatlines, dofontsize(14);
subplot(312)
plot(P,(P-Pp1)./PT1(end),P,(P-Pp2)./PT2(end))
ylabel('Hb O2 / Total O2')
xlabel('PaO2')
axis('tight'), grid('on'), fatlines, dofontsize(14);
subplot(313)
plot([(P-PT1);(P-PT2)].')
ylabel('Error')
xlabel('Sample')
axis('tight'), grid('on'), fatlines, dofontsize(14);

