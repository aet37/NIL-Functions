
clear all
load cbvscr1b

opt5=optimset('lsqnonlin');

if (tv3(end)>2), tv3=tv3/60; end;
if (tv3(1)~=0), tv3=tv3-tv3(1); end;

dt=1/(60*20);
tti=[tv3(1):dt:tv3(end)];
avgVV3ai=interp1(tv3,avgVV3a,tti);
uu=mytrapezoid(tti,3.5/60,10.0/60,2.0/60);

%[mtype dt Tf mu1 nu1 mu0 D Famp Q0 fst fdur framp utau N Ntau]
parms=[1 dt length(uu)*dt 50 20/60  50  1e-3 0.01    1   3.5/60  60/60 0.1/60  1/60  0 1.5/60];
plb=[ 1 1e-5  1/60         0    0    0  1e-5 1e-10  0.1  0.1/60  56/60 0.1/60 0.1/60 0 0.5/60];
pub=[ 2 1e-2    2        1e8  1e8  1e8  1e-1 1e4    5/60 12/60   64/60 20/60  20/60 20 5.0/60];

parms2fit=[4 5 8 10 11 13 14];
xxx1=lsqnonlin(@voigtkelvin3,parms(parms2fit),plb(parms2fit),pub(parms2fit),opt5,parms,parms2fit,avgVV3ai);
[Q,F,UU,FF]=voigtkelvin3(xxx1,parms,parms2fit);
ee1=sum((Q/Q(1)-avgVV3ai).^2)/length(Q);

parms2=parms([1 2 4 5 6 7 8 9]); parms2(8)=xxx1(3);
plb2=plb([1 2 4 5 6 7 8 9]);
pub2=pub([1 2 4 5 6 7 8 9]);
parms2fit2=[3 4]; 
xxx1d=lsqnonlin(@voigtkelvin2,parms2(parms2fit2),plb2(parms2fit2),pub2(parms2fit2),opt5,parms2,parms2fit2,UU+1,avgVV3ai);
[Qd,Fd,FFd]=voigtkelvin2(xxx1d,parms2,parms2fit2,UU+1);

figure(1)
plot(tv3,avgVV3a,tti,Q/Q(1),tti,Qd/Qd(1))
axis('tight'), grid('on'),
legend('Data','3','2')

