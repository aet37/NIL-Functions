
clear all

% sim key parameters
flip=pi/6;
T1=2000e-3;
vz=5e-4;

% other sim parameters
dz=5e-3;
RO=30e-3;
TR=500e-3;
tTR=[0:TR/10:TR];
nTRs=20;

% initially the magnitization is 1
mz0(1)=1;

z1(1)=rand(1)*dz;
for m=1:nTRs,
  % tip spin
  mz1(m)=mz0(m)*cos(flip);
  % check location at readout
  zro(m)=z1(m)+vz*RO;
  if (zro(m)>dz),
    disp(' reinserting spin for readout...');
    zro(m)=rand(1)*vz*RO;
    mz1(m)=1;
  end;
  mzro(m)=(1-mz1(m))*(1-exp(-RO/T1))+mz1(m);
  % check location at TR
  ztr(m)=z1(m)+vz*TR;
  if (ztr(m)>dz),
    disp(' reinserting spin for tr...');
    ztr(m)=rand(1)*vz*TR;
    mz1(m)=1;
  end;
  mztr(m,:)=(1-mz1(m))*(1-exp(-tTR/T1))+mz1(m);
  tt(m,:)=(m-1)*TR+tTR;
  % reset for next iteration
  if (m<nTRs), 
    %disp(' updating...');
    mz0(m+1)=mztr(m,end);
    z1(m+1)=ztr(m);
  end;
end;

t=[1:nTRs]*TR;
tmztr=mztr(1,:); ttt=tt(1,:);
for m=2:size(mztr,1), tmztr=[tmztr mztr(m,:)];  ttt=[ttt tt(m,:)]; end;
subplot(211)
plot(t-TR,mz0,t-TR+RO,mzro,ttt,tmztr)
subplot(212)
plot(t,z1)

