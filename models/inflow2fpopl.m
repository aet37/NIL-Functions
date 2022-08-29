function [s,mz1,mzro,mztr]=inflow2fpopl(vz,T1,FA,TR,params)
% Usage ... [s,mz1,mzro,mztr]=inflow2f(vz,T1,FA,TR,params)
%
% Inflow simulation of a population of spins (determined by
% the size of vz)
% params = [dz nTRs RO]
% s = [m0 mRO mTR] repeat m0 and mRO for spin with [minvz midvz maxvz]

% sample commands for this simulation
%lampdf=(1-[0:1e-3:1].*[0:1e-3:1]); lampdf=lampdf/sum(lampdf);
%lam=ran_dist([lampdf]',rand([1e4 1]));
%inflow2fpopl(1e-3*lam,1000e-3,60,500e-3,[5e-3 20 50e-3]);

verbose=0;
showfig=1;

if (nargin<5), params=[5e-3 20 50e-3]; end;

% sim key parameters
nspins=length(vz);
flip=FA*(pi/180);

% other sim parameters
dz=params(1);
nTRs=params(2);
RO=params(3);

tTR=[0:TR/10:TR];

% initially the magnitization is 1
mz0(:,1)=1*ones([nspins 1]);;

if (sum(vz)==0),
  disp('stationary velocity distribution');
  iivz=[1 floor(length(vz)/2) length(vz)];
  minvz=vz(iivz(1)); midvz=vz(iivz(2)); maxvz=vz(iivz(3));
elseif (sum(vz)==length(vz)*vz(1)),
  disp('all velocities in distribution equal');
  iivz=[1 floor(length(vz)/2) length(vz)];
  minvz=vz(iivz(1)); midvz=vz(iivz(2)); maxvz=vz(iivz(3));
else,
  [minvz,minvzi]=min(vz);
  [maxvz,maxvzi]=max(vz);
  midvz=(maxvz-minvz)/2 +minvz; 
  epsvz=.01*maxvz;
  found=0; while (~found),
    midvzi=find((vz<(midvz+epsvz))&(vz>(midvz-epsvz)));
    if (~isempty(midvzi)),
      midvzi=midvzi(1);
      midvz=vz(midvzi);
      found=1;
    else,
      epsvz=epsvz+0.005*maxvz;
    end;
  end;
  iivz=[minvzi midvzi maxvzi];
end;

sldist=rand([nspins 1])*dz;
z1(:,1)=sldist;
for m=1:nTRs,
  % tip spin
  mz1(:,m)=mz0(:,m)*cos(flip);
  % check location at readout
  zro(:,m)=z1(:,m)+vz*RO;
  outzro=find(zro(:,m)>dz);
  if (~isempty(outzro)),
    if (verbose), disp(' reinserting spin for readout...'); end;
    if (sum(outzro==minvzi)>0), disp(sprintf('   reinserting min (%d ro)...',m)); end;
    if (sum(outzro==midvzi)>0), disp(sprintf('   reinserting mid (%d ro)...',m)); end;
    if (sum(outzro==maxvzi)>0), disp(sprintf('   reinserting max (%d ro)...',m)); end;
    %zro(outzro,m)=rand([length(outzro) 1]).*vz(outzro)*RO;
    zro(outzro,m)=rand([length(outzro) 1]).*(zro(outzro,m)-dz);
    mz1(outzro,m)=1*ones([length(outzro) 1]);
  end;
  mzro(:,m)=(1-mz1(:,m))*(1-exp(-RO/T1))+mz1(:,m);
  % check location at TR
  ztr(:,m)=z1(:,m)+vz*TR;
  outztr=find(ztr(:,m)>dz);
  if (~isempty(outzro)),
    if (verbose), disp(' reinserting spin for tr...'); end;
    if (sum(outztr==minvzi)>0), disp(sprintf('   reinserting min (%d tr)...',m)); end;
    if (sum(outztr==midvzi)>0), disp(sprintf('   reinserting mid (%d tr)...',m)); end;
    if (sum(outztr==maxvzi)>0), disp(sprintf('   reinserting max (%d tr)...',m)); end;
    %ztr(outztr,m)=rand([length(outztr) 1]).*vz(outztr)*TR;
    ztr(outztr,m)=rand([length(outztr) 1]).*(ztr(outztr,m)-dz);
    mz1(outztr,m)=1*ones([length(outztr) 1]);
  end;
  mztr(:,m)=(1-mz1(:,m)).*(1-exp(-TR/T1))+mz1(:,m);
  % right matmult to get (spins,time,nTR)
  mmztr(:,:,m)=(1-mz1(iivz,m))*(1-exp(-tTR/T1))+mz1(iivz,m)*ones(size(tTR));
  tt(:,m)=(m-1)*TR+tTR';
  % reset for next iteration
  if (m<nTRs), 
    %disp(' updating...');
    mz0(:,m+1)=mztr(:,m);
    z1(:,m+1)=ztr(:,m);
  end;
end;

smz0=(1/nspins)*sum(mz0);
smzro=(1/nspins)*sum(mzro);
smztr=(1/nspins)*sum(mztr);
s=[smz0' smzro' smztr'];
s2=[mz0(iivz,:)'];
s3=[mzro(iivz,:)'];

% select ones to show: min mid max
t=[1:nTRs]*TR;
tmztr=[mmztr(1,:,1);mmztr(2,:,1);mmztr(3,:,1)]; ttt=tt(:,1)';
for m=2:nTRs,
  tmztr=[tmztr [mmztr(1,:,m);mmztr(2,:,m);mmztr(3,:,m)]]; 
  ttt=[ttt tt(:,m)'];
end;

if ((nargout==0)|(showfig)),
  disp(sprintf('   Nspins= %d cm/s, FA= %f deg, T1= %f ms',nspins,params(1),1e3*T1));
  disp(sprintf('      TR= %f ms (%d), RO= %f ms',1e3*TR,nTRs,1e3*RO));
  disp(sprintf('     vz(min,mid,max)= [%f %f %f] m/s',minvz,midvz,maxvz));
  subplot(321)
  plot(s)
  axis([1 nTRs 0 1])
  xlabel('TRs'), ylabel('Signal')
  subplot(322)
  plot(mz0(iivz,:)')
  axis([1 nTRs 0 1])
  xlabel('TRs'),
  subplot(334)
  plot(ttt,tmztr(1,:))
  ylabel('Selected Signals')
  subplot(335)
  plot(ttt,tmztr(2,:))
  xlabel('Time')
  subplot(336)
  plot(ttt,tmztr(3,:))
  subplot(325)
  hist(vz,floor(nspins/50))
  xlabel('Vz'), ylabel('Nspins')
  subplot(326)
  hist(sldist,floor(nspins*0.02))
  xlabel('dz'), ylabel('Nspins')
end

s=[s s2 s3];

