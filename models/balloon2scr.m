
clear all

F0=60/60;
Vv0=3.0*0.70;

k=1.0;
Ti=1.5;
N0=0.0;
k2=3;
Th=1.5;
f1=1.5;
n=2.5;
dtf=1.0;
dtt=0.0;
a=0.4;
Tvp=12.0;
Tvn=12.0;
Tmtt=Vv0/F0;
E0=0.4;
b=1.5;
A=1.0;

parms=[k Ti N0 k2 Th f1 n dtf dtt a Tvp Tvn Tmtt E0 b A];

dt=0.01;
t=[0:dt:150];
Sinp=mytrapezoid3(t,2.0,1.0,0.1);

[BOLD1,Bs1]=balloon2([],parms,[],Sinp,dt);

Sinp=mytrapezoid3(t,2.0,1,0.1);
Sinp=Sinp+mytrapezoid3(t,42.0,1,0.1);
Sinp=Sinp+mytrapezoid3(t,44.0,1,0.1);
Sinp=Sinp+mytrapezoid3(t,84.0,10,0.1);

[BOLD2,Bs2]=balloon2([],parms,[],Sinp,dt);
BOLD2p=BOLD1+tshift(t,BOLD1,[42 44 [84:93]]-2);

TR=1;
tTR=[0:TR:150];
BOLD1TR=interp1(t,BOLD1,TR);


