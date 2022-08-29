
clear all
load cohenData

dt=1/3;
tt=[1:length(hypercapnia)]'*dt;

ti=[tt(1):.1:tt(end)]';
hypoi=interp1(tt,hypocapnia,ti);
prehypoi=interp1(tt,prehypocapnia,ti);
hyperi=interp1(tt,hypercapnia,ti);
prehyperi=interp1(tt,prehypercapnia,ti);

stimdur=4.0+1.2;
stimdel=3.667+0.333;

parmsU1=[stimdur stimdel];
parmsA1=[+0.017 0.21 5e13 1e15 8e12 2e14 -0.35 15 28e-6];
parmsB1=[1 0.4 1e-10 1 1 383];

parmsU2=[stimdur stimdel];
parmsA2=[+0.017 3.34 5e13 3e15 8e12 2e14 -0.35 15 28e-6];
parmsB2=[1 0.4 1e-10 1 1 376];

opt2=optimset('lsqnonlin');
opt2.MaxIter=500;
opt2.TolX=1e-10;

x01=[0.05 2.0 400];
x02=[0.05 2.0 400];
xlb=[1e-4 1e-4 0];
xub=[5e+2 1e+2 1e6];
fitparms=[3 4 17];
%x01=[0.02 0.2 8e12 400];
%x02=[0.02 3.0 8e12 400];
%xlb=[1e-4 1e-4 1e12 0];
%xub=[5e+2 1e+2 1e16 1e6];
%fitparms=[3 4 6 17];

xx1=lsqnonlin(@mybold,x01,xlb,xub,opt2,ti,[parmsU1 parmsA1 parmsB1],fitparms,hypoi,[30 250]);
xx2=lsqnonlin(@mybold,x02,xlb,xub,opt2,ti,[parmsU2 parmsA2 parmsB2],fitparms,prehypoi,[30 250]);
[y1,qin1,qout1,v1,e1,q1,mtt1]=mybold(xx1,ti,[parmsU1 parmsA1 parmsB1],fitparms);
[y2,qin2,qout2,v2,e2,q2,mtt2]=mybold(xx2,ti,[parmsU2 parmsA2 parmsB2],fitparms);

subplot(211)
plot(ti,prehypoi,ti,y1)
subplot(212)
plot(ti,hypoi,ti,y2)

%mybold([],ti,[6 4 0.017 3 5e13 3e15 8e12 2e14 -0.5 15 28e-6 1 0.4 1e-10 1 1 375],[],0.5*(prehyperi+prehypoi));

