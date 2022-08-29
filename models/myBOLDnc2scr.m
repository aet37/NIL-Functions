
if (~exist('newflag')),
  newflag=1;
end;
if (~exist('plotflag')),
  plotflag=1;
end;

if (newflag),
dt=0.01;
tfin=120;
w=60.0;
t0=3.5;
tau_a=3.0;
rCBF=1.6;
rCMRO2=1.25;
F0=55;
Vv0=1;
tau_v=0.2;
P50=26;
Vc=1;
Vct=97;
PS=7000;
Pa=90;
Pt=26;
kb=0.5;
Nlfp=0.0;
tau_lfp=1.5;
tau_n=2.0;
tau_cmro2=2.0;
nctype=0;
end;

tparms=[dt/60 tfin/60];
sparms=[1 t0/60 w/60 0.2/60 tau_a/60 rCBF-1 rCMRO2-1 F0 Vv0 tau_v P50 Vc Vct PS Pa Pt kb 1 Nlfp tau_lfp/60 tau_n/60 nctype tau_cmro2/60];

[BOLD,Fin,Fout,VV,CMRO2t,EEt,q,Ut,t]=myBOLDnc2([],tparms,sparms,[]);

if (plotflag),
  subplot(311)
  plot(t,CMRO2t)
  axis('tight'), grid('on'),
  subplot(312)
  plot(t,Fin)
  axis('tight'), grid('on'),
  subplot(313)
  plot(t,BOLD)
  axis('tight'), grid('on'),
end;

