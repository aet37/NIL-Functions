function [mzro,mz0,tmztr,ttt]=inflow2f(vz,params)
% Usage ... [mzro,mz0]=inflow2f(vz,params)
%
% params = [FA(degs) T1 dz TR nTRs RO]

if (nargin<2), params=[60 1000e-3 5e-3 1000e-3 20 50e-3]; end;

% sim key parameters
flip=params(1)*(pi/180);
T1=params(2);

% other sim parameters
dz=params(3);
TR=params(4);
nTRs=params(5);
RO=params(6);

tTR=[0:TR/10:TR];

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

if (nargout==0),
  disp(sprintf('   vz= %f cm/s, FA= %f deg, T1= %f ms',100*vz,params(1),1e3*T1));
  disp(sprintf('      TR= %f ms (%d), RO= %f ms',1e3*TR,nTRs,1e3*RO));
  subplot(211)
  plot(t-TR,mz0,t-TR+RO,mzro,ttt,tmztr)
  subplot(212)
  plot(t,z1)
end

