
% inflow effect simulation
%   this simulation strides to look at the effects of 
%   inflow through TRs
%
% use 3 settings for velocities:
%  1- stationary (T1 gray, T1 white, T1 blood)
%  2- small velocity (sub-voxel directional motion,
%        plugged, select 10 directions, T1 blood)
%  3- larger vessel (voxel-size directional motion,
%	 laminar, select 1 direction, T1 blood)
%
% for now doing single slice

clear all

frac_stat2mov=0.8;
frac_slow2fast=0.7;
frac_graymat=0.2;
frac_whitemat=0.4;
frac_csf=0.4;

ntotal=1e4;
nTRs=20;

flip=pi/4;
dz=5e-3;
TR=500e-3;
RO=500e-3;
T1blood=500e-3;		% 500ms
T1white=500e-3;		% 150ms
T1gray=500e-3;		% 100ms
T1csf=500e-3;		% 500ms

dvslow=2e-4; v0slowvel=0e-4;
peakfastvel=8e-4;
nslowdirs=10;

nstat=floor(frac_stat2mov*ntotal);
nmov=ntotal-nstat;
ngray=floor(frac_graymat*nstat);
nwhite=floor(frac_whitemat*nstat);
ncsf=nstat-ngray-nwhite;
nslow=floor(frac_slow2fast*nmov);
nfast=nmov-nslow;

slowvel=rand([nslowdirs 3]);
slowvel(:,1)=dvslow*slowvel(:,1)+v0slowvel;
slowvel(:,2)=pi*slowvel(:,2)-pi/2;
slowvel(:,3)=pi*slowvel(:,3)-pi/2;
lampdf=(1-[0:1e-4:1].*[0:1e-4:1])';
fastphi=[0 1]*pi/2;
fastvel(:,1)=peakfastvel*ones([nfast 1]);
fastvel(:,2)=ones([nfast 1])*fastphi(1);
fastvel(:,3)=ones([nfast 1])*fastphi(2);

% sp_stat=[T1 M0ro M0- M0+]
sp_stat=ones([nstat 4]);
sp_stat(1:ngray,1)=T1gray*ones([ngray 1]);
sp_stat(ngray+1:ngray+nwhite,1)=T1white*ones([nwhite 1]);
sp_stat(ngray+nwhite+1:end,1)=T1csf*ones([ncsf 1]);

% sp_slow=[T1 M0ro M0- M0+ z- z+ vx vy vz]
sp_slow=ones([nslow 9]);
sp_slow(:,1)=T1blood*ones([nslow 1]);
sp_slow(:,5)=dz*rand([nslow 1]);
sp_slow(:,6)=sp_slow(:,5);
for m=1:nslow,
  mm=mod(m,10)+1;
  sp_slow(m,7:9)=slowvel(mm,1)*[sin(slowvel(mm,2))*cos(slowvel(mm,3)) cos(slowvel(mm,2))*cos(slowvel(mm,3)) sin(slowvel(mm,3))];
end; 

% sp_fast=[T1 M0ro M0- M0+ z- z+ vx vy vz]
sp_fast=ones([nfast 9]);
sp_fast(:,1)=T1blood*ones([nfast 1]);
sp_fast(:,5)=dz*rand([nfast 1]);
sp_fast(:,6)=sp_fast(:,5);
sp_fast(:,7)=fastvel(:,1).*sin(fastvel(:,2)).*cos(fastvel(:,3));
sp_fast(:,8)=fastvel(:,1).*cos(fastvel(:,2)).*cos(fastvel(:,3));
sp_fast(:,9)=fastvel(:,1).*sin(fastvel(:,3));

% at each TR-step we are at the end of the TR
for m=1:nTRs,
  % first: decay thru RO and TR
  sp_stat(:,2)=(1-cos(flip)*sp_stat(:,3)).*(1-exp(-RO./sp_stat(:,1)))+cos(flip)*sp_stat(:,3); 
  sp_slow(:,2)=(1-cos(flip)*sp_slow(:,3)).*(1-exp(-RO./sp_slow(:,1)))+cos(flip)*sp_slow(:,3);
  sp_fast(:,2)=(1-cos(flip)*sp_fast(:,3)).*(1-exp(-RO./sp_fast(:,1)))+cos(flip)*sp_fast(:,3);
  sp_stat(:,4)=(1-cos(flip)*sp_stat(:,3)).*(1-exp(-TR./sp_stat(:,1)))+cos(flip)*sp_stat(:,3); 
  sp_slow(:,4)=(1-cos(flip)*sp_slow(:,3)).*(1-exp(-TR./sp_slow(:,1)))+cos(flip)*sp_slow(:,3);
  sp_fast(:,4)=(1-cos(flip)*sp_fast(:,3)).*(1-exp(-TR./sp_fast(:,1)))+cos(flip)*sp_fast(:,3);
  % second: move it in z
  sp_slow(:,6)=sp_slow(:,5)+TR*sp_slow(:,9);
  sp_fast(:,6)=sp_fast(:,5)+TR*sp_fast(:,9);
  % third: check if in slice, replace if necessary (at RO)
  outslow=0; outslow=find((sp_slow(:,5)+RO*sp_slow(:,9))>dz);
  outfast=0; outfast=find((sp_fast(:,5)+RO*sp_fast(:,9))>dz);
  if (~isempty(outslow)),
    for mm=1:length(outslow),
      sp_slow(outslow(mm),2:4)=[1 1 1];
      sp_slow(outslow(mm),5:6)=(sp_slow(outslow(mm),6)-dz)*[1 1];
    end;    
  end;
  if (~isempty(outfast)),
    for mm=1:length(outfast),
      sp_fast(outfast(mm),2:4)=[1 1 1];
      sp_fast(outfast(mm),5:6)=(sp_fast(outfast(mm),6)-dz)*[1 1];
    end;
  end;
  % fourth: add up signal at readout
  signal_stat(m)=sum(sp_stat(:,2));
  signal_slow(m)=sum(sp_slow(:,2));
  signal_fast(m)=sum(sp_fast(:,2));
  signal(m)=sum(sp_stat(:,2))+sum(sp_slow(:,2))+sum(sp_fast(:,2));
  % fifth: check if in slice, replace if necessary (at TRend)
  outslow=0; outslow=find(sp_slow(:,6)>dz);
  outfast=0; outfast=find(sp_fast(:,6)>dz);
  if (~isempty(outslow)),
    for mm=1:length(outslow),
      sp_slow(outslow(mm),2:4)=[1 1 1];
      sp_slow(outslow(mm),5:6)=(sp_slow(outslow(mm),6)-dz)*[1 1];
    end;    
  end;
  if (~isempty(outfast)),
    for mm=1:length(outfast),
      sp_fast(outfast(mm),2:4)=[1 1 1];
      sp_fast(outfast(mm),5:6)=(sp_fast(outfast(mm),6)-dz)*[1 1];
    end;
  end;
  % fifth: update for next TR
  sp_slow(:,3)=sp_slow(:,4);
  sp_slow(:,5)=sp_slow(:,6);
  sp_fast(:,3)=sp_fast(:,4);
  sp_fast(:,5)=sp_fast(:,6);
end;

t=[1:nTRs]*TR;
subplot(311)
plot(t,signal)
subplot(312)
plot(t,signal_stat/nstat,t,signal_slow/nslow,t,signal_fast/nfast)
subplot(337)
hist(fastvel(:,1),50)
subplot(338)
hist(sp_slow(:,9),50)
subplot(339)
hist(sp_fast(:,9),50)

disp('slow vz:'), slowvel(:,1).*sin(slowvel(:,3)),
disp('fast vz:'), fastvel(1).*sin(fastphi(2)),

