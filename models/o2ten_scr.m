

alpha_O2=1.39e-3;
mmol2ml_O2=0.0224;

dt=0.05;
tfin=60;

Sst=1.0;
Sdur=20.0;
Sramp=2*dt;

Nlfp=1;
tau_lfp=1.5;

tau_n=2;
tau_a=2;
tau_v=12;

dF=0.60;
dCMRO2=0.25;
nctype=3;
tau_cmro2=1.0;

Vc=1.0;
Vtc=97;
Vt=Vtc-Vc;
Vv0=1;
F0=1;

PSref=6000;
PS=PSref*sqrt(Vc/1);

Pa=90;
Pt=20;
P50=26;

kb=0.5;

tparms=[dt tfin]/60;
sparms=[14 Sst/60 Sdur/60 Sramp/60 tau_a/60 dF dCMRO2 F0*60 Vv0 tau_v/60 P50 Vc Vt PS Pa Pt kb 1 Nlfp tau_lfp/60 tau_n/60 nctype tau_cmro2/60];
[St,Fin,Fout,Vv,CMRO2t,EEt,qt,Ut,t,UUt,CCt,CCc]=myBOLDnc([],tparms,sparms,[]);
t=t*60;
CCt=CCt/alpha_O2;
CCc=CCc/alpha_O2;
frac_total2pl_O2=Pa/CCc(1);
CCc=CCc*frac_total2pl_O2;
CMRO2t=CMRO2t*mmol2ml_O2;

subplot(421)
plot(t,UUt)
ylabel('f_{neu}')
axis('tight'),grid('on'),
subplot(422)
plot(t,Ut)
ylabel('U')
axis('tight'),grid('on'),
subplot(423)
plot(t,CMRO2t)
ylabel('CMR_{O2}')
axis('tight'),grid('on'),
subplot(424)
plot(t,CCt)
ylabel('PO2_t')
axis('tight'),grid('on'),
subplot(425)
plot(t,CCc)
ylabel('PO2_c')
axis('tight'),grid('on'),
subplot(426)
plot(t,Fin,t,Fout,'--')
ylabel('Flow')
axis('tight'),grid('on'),
legend('Fin','Fout')
subplot(427)
plot(t,Vv)
ylabel('V_v')
axis('tight'),grid('on'),
subplot(428)
plot(t,St)
ylabel('BOLD')
axis('tight'),grid('on'),


