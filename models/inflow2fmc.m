
clear all

n_mc=20;
nspins=1e4;

T1=1000e-3;
FA=30;
TR=500e-3;
nTRs=20;
RO=50e-3;
dz=5e-3;
eFA=acos(exp(-TR/T1))*(180/pi);

% laminar flow stuff
lamvz=1e-2;
lampdf=(1-[0:1e-3:1].*[0:1e-3:1]); lampdf=lampdf/sum(lampdf);
lamdist=ran_dist([lampdf]',rand([nspins 1]));
lam=lamvz*lamdist;
% plugged flow stuff
plugvz=1e-4;
plugdist=ones([nspins 1]);
plug=plugvz*plugdist;
% stationary
stat=zeros([nspins 1]);

vz=lam;

% simulation
if (sum(vz)==0), n_mc=3; end;
s=0;
for m=1:n_mc,
  s=s+inflow2fpopl(vz,T1,FA,TR,[dz nTRs RO]);
end;
s=s/n_mc;

T1s=[700e-3 1000e-3 1300e-3];
plugvzs=[1e-4 5e-4 1e-3 2.5e-3 5e-3 1e-2];
lamvzs=[1e-3 5e-3 1e-2 5e-2 1e-1];
statvzs=[0];
vzs=plugvzs;
FAs=[30 40 50 60 70];
for n=1:length(T1s), for o=1:length(FAs), for p=1:length(vzs),
  %vz=vzs(p)*plugdist;
  vz=vzs(p)*lamdist;
  %vz=stat;
  if (sum(vz)==0), n_mc=3; end;
  s=0;
  for m=1:n_mc,
    s=s+inflow2fpopl(vz,T1s(n),FAs(o),TR,[dz nTRs RO]);
  end;
  s=s/n_mc;
  if (sum(vz)==0),
    ss(n,o)=s(end,1);
  else,
    ss(n,o,p)=s(end,1);
  end;
end; end; end;
clear m n o p
%save inflow_plugsim
save inflow_lamsim
%save inflow_statsim

