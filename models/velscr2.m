
cd ~/matlab/models
clear

nspins=20001;
nvdist=20001;
fspread=26752*1500*.5e-6;
pspread=pi/6;
vthr=0.05;
tvratio=0.6;
tau1=0.001;
vdim=[0.3125 0.3125 0.3];
vavg=.25;
vdev=.15;
vmindiam=50e-6;
vmaxdiam=5e-3;
vdtau=.25;
parms=[1/1000e-3 1/90e-3 1e-5 tvratio];

Ga=1.0;
Gt=[0:4e-6:13744e-6]';
Gz=Ga*ones(size(Gt));
Gz(1:176)=(Ga/700e-6)*Gt(1:176);
Gz(3262:3437)=Ga-Gz(1:176);

reps=10;
rand('seed',sum(100*clock))
which_type=rand([reps 2]);
for nn=1:reps,

  seed1=[10 11 12]+nn*10;

  randn('seed',seed1(1));
  f=randn([nspins 1])*(fspread);
  p=randn([nspins 1])*(pspread);

  if which_type(nn,1)>0.2,
    type=[1 1];
    vmean=.2+.4*which_type(nn,2);
    vspread=vdev;
  else,
    type=[1 2];
    vmean=[vmindiam vmaxdiam];
    vspread=[vdtau];
  end;
 
  [v,vid]=vel_dist2(nspins,nvdist,tvratio,tau1,vmean,vspread,type,vdim,seed1(2));

  spins0=mrsigdist(f,p,[v vid],vdim,zeros(size(Gz)),Gt,parms,seed1(3));
  spins1=mrsigdist(f,p,[v vid],vdim,Gz,Gt,parms,seed1(3));

  [dv0,bx0]=hist2(v,spins0,200);
  [dv1,bx1]=hist2(v,spins1,200);

  bar(bx0,dv1-dv0)

  dsignal(nn)=(abs(sum(spins1))-abs(sum(spins0)))/abs(sum(spins0));
  dsigtiss(nn)=abs(sum(dv1(1:floor(vthr*length(dv1)))))-abs(sum(dv0(1:floor(vthr*length(dv0)))));
  dsigtiss(nn)=dsigtiss(nn)/abs(sum(dv0(1:floor(vthr*length(dv0)))));
  dsigvasc(nn)=abs(sum(dv1(ceil(vthr*length(dv1)):length(dv1))))-abs(sum(dv0(ceil(vthr*length(dv0)):length(dv0))));
  dsigvasc(nn)=dsigvasc(nn)/abs(sum(dv0(ceil(vthr*length(dv0)):length(dv0))));
  s0(nn)=abs(sum(spins0));
  s1(nn)=abs(sum(spins1));

end;

