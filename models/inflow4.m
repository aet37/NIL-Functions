
clear all

ntotal=1e5;
TR=500e-3;
RO=50e-3;
nTRs=20;
FA=60;
dz=5e-3;

T1csf=1000e-3;
T1tissue=1000e-3;
T1blood=1000e-3;

eFA=acos(exp(-T1tissue/TR))*(180/pi);
%FA=eFA;

fcsf=0.2;
fblood=0.2;
ftissue=1-(fcsf+fblood);

% blood signal part
flam=0.5;
fplug=1-flam;
nplugvels=10;

lamvz=2e-2;
plugvzmin=5e-5;
plugvzmax=5e-3; 

nblood=floor(fblood*ntotal);
nlam=floor(nblood*flam);
lampdf=(1-[0:1e-3:1].*[0:1e-3:1]); lampdf=lampdf/sum(lampdf);
lam=lamvz*ran_dist([lampdf]',rand([nlam 1]));
slam=inflow2fpopl(lam,T1blood,FA,TR,[dz nTRs RO]);

nplug=nblood-nlam;
nplugs=floor(nplug/nplugvels);
plugpdf=rand([nplugvels 1]);
plug=plugpdf(1)*ones([nplugs+(nplug-nplugs*nplugvels) 1]);
for m=2:nplugvels, plug=[plug;plugpdf(m)*ones([nplugs 1])]; end;
plug=plugvzmin+plug*(plugvzmax-plugvzmin);
splug=inflow2fpopl(plugvzmin+plug*(plugvzmax-plugvzmin),T1blood,FA,TR,[dz nTRs RO]);

sblood=flam*slam+fplug*splug;

% csf signal part
ncsf=floor(ntotal*fcsf);
scsf=inflow2fpopl(zeros([ncsf 1]),T1csf,FA,TR,[dz nTRs RO]);

% tissue signal part
ntissue=ntotal-(nblood+ncsf);
stissue=inflow2fpopl(zeros([ntissue 1]),T1tissue,FA,TR,[dz nTRs RO]);

% talley-up totals
s=fcsf*scsf+fblood*sblood+ftissue*stissue;


subplot(311)
plot(s(:,[1 2]))
axis([1 nTRs 0 1])
xlabel('TRs'),ylabel('Signal')
title('Total')
subplot(334)
plot(scsf(:,[1 2]))
axis([1 nTRs 0 1])
xlabel('TRs'),ylabel('Signal')
title('CSF')
subplot(335)
plot(sblood(:,[1 2]))
axis([1 nTRs 0 1])
xlabel('TRs')
title('Blood')
subplot(336)
plot(stissue(:,[1 2]))
axis([1 nTRs 0 1])
xlabel('TRs')
title('Tissue')
subplot(325)
plot([slam(:,[7 8 9]) splug(:,[2])])
axis([1 nTRs 0 1])
xlabel('TRs'),ylabel('Blood Signal')
title('@ RO')
subplot(3,4,11)
hist([lam],floor(0.2*nlam))
xlabel('Vz')
subplot(3,4,12)
hist([plug],floor(0.2*nplug))
xlabel('Vz')
ylabel('Nspins')
