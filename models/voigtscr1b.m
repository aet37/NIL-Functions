
clear all
load cbvres1b

opt2=optimset('lsqnonlin');

if (tv3(1)~=0), tv3=tv3-tv3(1); end;
tv3=tv3/60;

tparms=[1/(60*20) tv3(end)];
t=[0:tparms(1):tparms(2)];
avgVV3ai=interp1(tv3,avgVV3a,t);

%[mu0 mu1 nu1 famp fst fdur framp N Ntau ftau]
parms=[1.5  1.0  20/60  0.1  3/60  60/60 0.1/60 3.0 1.5/60 3.0/60];
plb=  [1/60 0.01 0.1/60 1e-4 0.1/60 50/60 0.1/60 0.0 0.5/60 0.1/60];
pub=  [60   20   600    100  8/60  64/60 10/60  100  5.0/60 20/60];

parms2fit=[1 2 3 4 5 6 8 10];
x1=lsqnonlin(@voigtkelvin1f,parms(parms2fit),plb(parms2fit),pub(parms2fit),opt2,tparms,parms,parms2fit,avgVV3a,tv3);
[yy,uu,u1]=voigtkelvin1f(x1,tparms,parms,parms2fit);
err1=sum((yy-avgVV3ai).^2)/length(t);
err1n=err1/(max(avgVV3a)-1);

plot(tv3,avgVV3a,t,yy)

