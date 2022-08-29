function [m,t]=mzemul(fa,tr,t1,mz0,nex)
% Usage ... [m,t]=mzemul(fa,tr,t1,mz0,nex)
%

FS = 1e-3;

ts = [0:1e-3:tr];
tmp = mz0*(1-exp(-ts/t1)) + mz0*cos(fa)*exp(ts/t1);
m=tmp;

for k=1:nex,
  tmp = mz0*(1-exp(-ts/t1)) + m(length(m))*cos(fa)*exp(-ts/t1);
  m = [m tmp];
end;

t(1)=0;
for k=1:length(m)-1,
  t(k+1)=t(k)+FS;
end;