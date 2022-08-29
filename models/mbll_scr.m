
clear all
load /Users/towi/Data/OIS/20060208rat/atcvals

lambda=[570 620];

% extinction coefficients (units: 1/cm 1/M)
e_hbo2=getNIRSec(lambda,'HbO2');
e_dhb=getNIRSec(lambda,'Hbr');

L=0.01*[1 1];		% units: cm
B=1*[1 1];

cHbtotal=100;		% units: uM  (M: mol/L)
SO2=0.85;

mu_s=10.0;		% units: 1/cm  (not sure about this number)
mu_a=e_hbo2*cHbtotal*SO2 + e_dhb*cHbtotal*(1-SO2);

%B_alt=0.5*sqrt(3*mu_s./mu_a).*(1-1./(1+L*sqrt(3*mu_s*mu_a)));


tt=[1:length(atc1)]*0.2-5.0;
data570=atc1./mean(atc1(1:20))-1;
data620=atc2./mean(atc2(1:20))-1;

XX=[e_hbo2(:) e_dhb(:)].*(ones(1,2)*L(:)).*(ones(1,2)*B(:));
invXX=inv(XX);
dCC=invXX*[data570;data620];
RR=[data570;data620]-XX*dCC;

sum_XX=sum(XX);
RR2=sum_XX(2)/sum_XX(1)-atc2./atc1;
mse_RR2=sum(RR2.^2)/length(RR2);

CC=dCC+cHbtotal*([SO2 1-SO2]'*ones(1,size(dCC,2)));
CCtotal=sum(CC);


subplot(311)
plot(tt,data570,tt,data620)
subplot(312)
plot(tt,CC(1,:)/mean(CC(1,1:20)),tt,CC(2,:)/mean(CC(2,1:20)),tt,CCtotal/mean(CCtotal(1:20)))
subplot(313)
plot(tt,RR2)

