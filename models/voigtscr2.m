
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

parms=[1 dt length(uu)*dt 50 20/60 50 1e-3 0.01 1 3.5/60 10/60 .1/60 1/60 0 1.5/60];
plb=[1 1e-5 1/6 0 0 0 1e-5 1e-10 0.1 1/60 6/60 0.1/60 0.1/60 0 0.5/60];
pub=[2 1e-2 2 1e8 1e8 1e8 1e-1 1e4 10 5/60 12/60 4/60 20/60 20 5.0/60];

parms2fit=[4 5 8 10 11 13 14];
xxx1=lsqnonlin(@voigtkelvin3,parms(parms2fit),plb(parms2fit),pub(parms2fit),opt5,parms,parms2fit,avgC2i);
xxx1b=lsqnonlin(@voigtkelvin3,parms(parms2fit),plb(parms2fit),pub(parms2fit),opt5,parms,parms2fit,avgC2bi);
[Q,F,UU,FF]=voigtkelvin3(xxx1,parms,parms2fit);
[Qb,Fb,UUb,FFb]=voigtkelvin3(xxx1b,parms,parms2fit);

parms2=parms([1 2 4 5 6 7 8 9]); parms2(8)=xxx1(3);
plb2=plb([1 2 4 5 6 7 8 9]);
pub2=pub([1 2 4 5 6 7 8 9]);
parms2fit2=[3 4]; 
xxx1c=lsqnonlin(@voigtkelvin2,parms2(parms2fit2),plb2(parms2fit2),pub2(parms2fit2),opt5,parms2,parms2fit2,UU+1,avgC2bi);
xxx1d=lsqnonlin(@voigtkelvin2,parms2(parms2fit2),plb2(parms2fit2),pub2(parms2fit2),opt5,parms2,parms2fit2,UU+1,avgC2i);
[Qc,Fc,FFc]=voigtkelvin2(xxx1c,parms2,parms2fit2,UU+1);
[Qd,Fd,FFd]=voigtkelvin2(xxx1d,parms2,parms2fit2,UU+1);

parms3=parms2; parms3(parms2fit2)=xxx1d;
parms2fit3=[3];
xxx1e=lsqnonlin(@voigtkelvin2,parms3(parms2fit3),plb2(parms2fit3),pub2(parms2fit3),opt5,parms3,parms2fit3,UU+1,avgC2bi);
[Qe,Fe]=voigtkelvin2(xxx1e,parms3,parms2fit3,UU+1);

figure(1)
subplot(311)
plot(tt2,avgC2,tti,Q/Q(1),tti,Qd/Qd(1))
axis('tight'), grid('on'),
legend('data','all','2')
subplot(312)
plot(tt2,avgC2b,tti,Qb/Qb(1),tti,Qc/Qc(1),tti,Qe/Qe(1))
axis('tight'), grid('on'),
legend('data','all','2','1')
%subplot(223)
%plot(tt2,avgC2,tt2,avgC2b)
%axis('tight'), grid('on'),
subplot(313)
plot(tt2,avgC2,'b',tti,Qd/Qd(1),'b--',tt2,avgC2b,'g',tti,Qc/Qc(1),'g--')
xlabel('Time'), ylabel('Flow'), legend('Normocapnia','Hypercapnia'),
axis('tight'), grid('on'),
fatlines, dofontsize(15);

figure(2)
subplot(211)
plot(tt2,avgC2,tt2,avgC2b)
ylabel('CBF')
axis('tight'), grid('on'),
legend('Normocapnia','Hypercapnia')
fatlines, dofontsize(15);
subplot(212)
plot(tt2,avgE2,tt2,avgE2b)
ylabel('BOLD')
xlabel('Time')
axis('tight'), grid('on'),
fatlines, dofontsize(15);

