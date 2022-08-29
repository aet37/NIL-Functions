
clear all

flip=pi/6;
T1=2000e-3;

dz=5e-3;
RO=30e-3;
TR=500e-3;
tTR=[0:TR/10:TR];
nTRs=20;
n=1000+1;

vz=5e-4*ones([n 1]);
vz(1)=0;
fs2m=0.5;

mz0(:,1)=1*ones([n 1]);
z1(:,1)=rand([n 1])*dz;
for m=1:nTRs,
  % tip spin
  mz1(:,m)=mz0(:,m)*cos(flip);
  % check location at readout
  zro(:,m)=z1(:,m)+vz*RO;
  fzro=find(zro(:,m)>dz);
  if (~isempty(fzro)),
    disp(' reinserting spin for readout...');
    zro(fzro,m)=rand([length(fzro) 1]).*vz(fzro)*RO;
    mz1(fzro,m)=1*ones([length(fzro) 1]);
  end;
  mzro(:,m)=(1-mz1(:,m))*(1-exp(-RO/T1))+mz1(:,m);
  signal(m,:)=[mzro(1,m) sum(mzro(2:end,m))/(n-1)];
  % check location at TR
  ztr(:,m)=z1(:,m)+vz*TR;
  fztr=find(ztr(:,m)>dz);
  if (~isempty(fztr)),
    disp(' reinserting spin for tr...');
    ztr(fztr,m)=rand([length(fztr) 1]).*vz(fztr)*TR;
    mz1(fztr,m)=1*ones([length(fztr) 1]);
  end;
  mztr(:,m)=(1-mz1(:,m))*(1-exp(-TR/T1))+mz1(:,m);
  % reset for next iteration
  if (m<nTRs), 
    %disp(' updating...');
    mz0(:,m+1)=mztr(:,m);
    z1(:,m+1)=ztr(:,m);
  end;
end;

plot(signal)
