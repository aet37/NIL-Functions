
clear all

pO2=[0.1:1:140];
pH=7.4;
T=37;

p50=26;
hill=2.73;

pHact=7.45;
pO2adj=pO2.*exp(1.1*(pHact-pH));

%Tact=35;
%Tk=0.058*((0.243*pO2/100).^(3.88) + 1).^(-1);
%pO2adj=pO2adj.*exp(-Tk*(Tact-T));			% sign? multiplicative?

sO2hillref=1./(1+(p50./pO2).^hill);
sO2ref=(((pO2.^3+150*pO2).^(-1))*23400 + 1).^(-1);

sO2=(((pO2adj.^3+150*pO2adj).^(-1))*23400 + 1).^(-1);
sO2hill=1./(1+(p50./pO2adj).^hill);

p50adj=interp1(sO2,pO2,0.5);
p50hilladj=interp1(sO2hill,pO2,0.5);
[p50adj p50hilladj],
sO2hilladj=1./(1+(p50adj./pO2).^hill);


subplot(311)
plot(pO2,sO2ref,pO2,sO2hillref)
legend('Sv','Hill',4)
subplot(312)
plot(pO2,sO2ref,pO2,sO2)
legend('Sv','Sv pH adj',4)
subplot(313)
plot(pO2,sO2,pO2,sO2hill,pO2,sO2hilladj)
legend('Sv pH adj','Hill pH adj','Hill P50 adj',4)


