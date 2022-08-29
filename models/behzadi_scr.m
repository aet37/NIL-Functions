
clear all

dt=0.01;
tfin=40.0;

tparms=[dt tfin];
t=[0:dt:tfin];

Rn=35;
Rref=Rn/2;
Rmax=52;
Hn=0.2*Rn;
Pi=45;
lambda=0.15;
Cm_parms=[Rn Hn Rmax Rref Pi lambda];
Cmn=vesselCm(Rn,Cm_parms);

RR=[Rref+2:0.01:Rmax-2];
CmR=vesselCm(RR,Cm_parms);

R1=35; R2=33.1; R3=37.4;

r0=1;
eff=0.6;
ks=1.4;
gf=0.4;
fpow=4.0;
t0=0;

u=mytrapezoid(t,5,10,2*dt);

parms1=[r0 eff ks gf fpow t0];
[f1,r1,cm1,s1]=behzadi([],tparms,[],parms1,u,RR/R1,CmR/interp1(RR,CmR,R1));
parms2=[r0 eff ks gf fpow t0];
[f2,r2,cm2,s2]=behzadi([],tparms,[],parms2,u,RR/R2,CmR/interp1(RR,CmR,R2));
parms3=[r0 eff ks gf fpow t0];
[f3,r3,cm3,s3]=behzadi([],tparms,[],parms3,u,RR/R3,CmR/interp1(RR,CmR,R3));


subplot(211)
plot(t,f1,t,f2,t,f3)
ylabel('Flow')
axis('tight'), grid('on'), fatlines; dofontsize(15);
subplot(212)
plot(t,s1,t,s2,t,s3)
ylabel('Vasosignal')
xlabel('Time')
axis('tight'), grid('on'), fatlines; dofontsize(15);


