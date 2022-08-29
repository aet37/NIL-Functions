
clear all
load co2_4vals

opt5=optimset('lsqnonlin');

if (tt2(end)>2), tt2=tt2/60; end;
if (tt2(1)>0), tt2=tt2-tt2(1); end;

dt=1/(60*20);
tti=[tt2(1):dt:tt2(end)];
avgC2i=interp1(tt2,avgC2,tti);
avgC2bi=interp1(tt2,avgC2b,tti);
uu=mytrapezoid(tti,3.5/60,10.0/60,2.0/60);

parms=[1 dt 50 20/60 50 1e-3 0.01 1];
plb=[1 1e-5 0 0 0 1e-5 1e-10 0.1];
pub=[2 1e-5 1e8 1e8 1e8 1e-1 1e4 10];

parms2fit=[3 4];
xxx1=lsqnonlin(@voigtkelvin2,parms(parms2fit),plb(parms2fit),pub(parms2fit),opt5,parms,parms2fit,uu+1,avgC2i);
xxx1b=lsqnonlin(@voigtkelvin2,parms(parms2fit),plb(parms2fit),pub(parms2fit),opt5,parms,parms2fit,uu+1,avgC2bi);
%voigtkelvin2([50 100/6],parms,parms2fit,uu+1,avgC2i);
[Q,F]=voigtkelvin2(xxx1,parms,parms2fit,uu+1);
[Qb,Fb]=voigtkelvin2(xxx1b,parms,parms2fit,uu+1);

subplot(211)
plot(tt2,avgC2,tti,Q/Q(1))
subplot(212)
plot(tt2,avgC2b,tti,Qb/Qb(1))

