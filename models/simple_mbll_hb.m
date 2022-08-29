function y=simple_mbll_hb(x,lambda,parms,parms2fit,data)
% Usage ... y=simple_mbll_hb(x,lambda,parms,parms2fit,data)

do_logdata=0;

if (~isempty(parms2fit)),
  parms(parms2fit)=x;
end;

nwl=length(lambda);
if do_logdata,
  data=log10(1./data);
end;

% extinction coefficients (units: 1/cm 1/M)
nsp=2;
e_hbo2=getNIRSec(lambda,'HbO2');
e_dhb=getNIRSec(lambda,'Hbr');
e_hbo2_570=getNIRSec(570,'HbO2');

L=1.0*ones(1,nwl);		% units: cm
B=1.0*ones(1,nwl);

cHbtotal=parms(1);			% 100uM (units: uM  (M: mol/L))
SO2=parms(2);				% 0.85  (units: %)
mu_s=parms(3);				% units: 1/cm  (not sure about this number)

mu_a=e_hbo2*cHbtotal*SO2 + e_dhb*cHbtotal*(1-SO2);

Lmat=L'*ones(1,nsp);
Bmat=B'*ones(1,nsp);
%B_alt=0.5*sqrt(3*mu_s./mu_a).*(1-1./(1+L*sqrt(3*mu_s*mu_a)));

emat=[e_hbo2(:) e_dhb(:)];
emat=emat/e_hbo2_570;
%emat=[1.23 0.91;1 1;0.01 0.11];

XX=emat.*Lmat.*Bmat;
XX=[XX ones(nwl,1)];
XX=XX';

invXX=inv(XX*XX')*XX;
%[tmp1,invXX,tmp2]=svd(XX);

dCC=data*invXX';
RR=data-dCC*XX;

sum_XX=sum(XX);
%RR2=sum_XX(2)/sum_XX(1)-atc2./atc1;
RR2=sum_XX(2)/sum_XX(1);
mse_RR2=sum(RR2.^2)/length(RR2);

CC=dCC(:,1:2)+cHbtotal*(ones(size(dCC,1),1)*[SO2 1-SO2]);
CCtotal=sum(CC')';

%keyboard;

y.e_hbo2=e_hbo2;
y.e_dhb=e_dhb;
y.e_hb02_570=e_hbo2_570;
y.dCC=dCC;
y.RR=RR;
y.RR2=RR2;
y.mse_RR2=mse_RR2;
y.CC=CC;
y.CCtotal=CCtotal;


