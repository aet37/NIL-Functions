
clear all
load KazutoData

%CBF6i=CBF6i-mean(CBF6i(1:100)-1);
CBF6i=1+1.0*gammafun(CBF6t,0.9,3.5,1.2);
FP6e=mytrapezoid(CBF6t,0.5,4,0.01);

tparms=[0.01 CBF6t(end)-CBF6t(1)]/60;
tparms(3)=0;
tparms(4)=0;
tparms(5)=0;

%    [ F0  V0 Vk1 camp-1 P50 Vc Vct   PS   Pa  Pt  beta  Vm  PSm  fp2cmro2]
sparms=[146 2 12/60 0.3 26  1.0 98    7000 100  40  0.003 1];
slb=[30  1  1/60  -0.5 20 0.01 97.9  2000 80   0 0.00000 0];
sub=[120 10 40/60 +2.0 31 5.00 98.1  9000 300 70 10.0000 1e6];
sparms(11)=0.000;

myPO2est2([],tparms,sparms,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);


