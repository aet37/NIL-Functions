
cd ~/matlab/models
clear

nspins=20001;
nvdist=20001;
fspread=26752*1500*.5e-6;
pspread=pi/6;
vthr=0.05;
tvratio=0.6;
tau1=0.001;
vmean=.25;
vspread=0.15;
vdim=[0.3125 0.3125 0.3];
type=[1 1];		% [1 1]	[1 2]
parms=[1/1000e-3 1/90e-3 1e-5 tvratio];
seed1=[10 11 12 13];

Ga=1.0;
Gt=[0:4e-6:13744e-6]';
Gz=Ga*ones(size(Gt));
Gz(1:176)=(Ga/700e-6)*Gt(1:176);
Gz(3262:3437)=Ga-Gz(1:176);

randn('seed',seed1(1));
f=randn([nspins 1])*(fspread);

randn('seed',seed1(2));
p=randn([nspins 1])*(pspread);

[v,vid]=vel_dist2(nspins,nvdist,tvratio,tau1,vmean,vspread,type,vdim,seed1(3));

spins0=mrsigdist(f,p,[v vid],vdim,zeros(size(Gz)),Gt,parms,seed1(4));
spins1=mrsigdist(f,p,[v vid],vdim,Gz,Gt,parms,seed1(4));

[dv0,bx0]=hist2(v,spins0,200);
[dv1,bx1]=hist2(v,spins1,200);

bar(bx0,dv0-dv1)

dsignal=(abs(sum(spins1))-abs(sum(spins0)))/abs(sum(spins0))
dsigtiss=abs(sum(dv1(1:floor(vthr*length(dv1)))))-abs(sum(dv0(1:floor(vthr*length(dv0)))));
dsigtiss=dsigtiss/abs(sum(dv0(1:floor(vthr*length(dv0)))))
dsigvasc=abs(sum(dv1(ceil(vthr*length(dv1)):length(dv1))))-abs(sum(dv0(ceil(vthr*length(dv0)):length(dv0))));
dsigvasc=dsigvasc/abs(sum(dv0(ceil(vthr*length(dv0)):length(dv0))))

