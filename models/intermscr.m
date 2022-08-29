
clear all

dt=0.01;
tfin=60;
t=[0:dt:tfin];

sst=5;
sdur=10;
sramp=1.5;

N=0.5;
kn=1/1.5;
kk=1.5;

S=mytrapezoid(t,sst,sdur,sramp);
f=1+N*exp(-kn*(t-sst));

U=S.*f;
UP=mytrapezoid3(t,sst,sdur,sramp,[14 N kk]);

UU(1)=0;
for mm=2:length(t),
  %UU(mm) = UU(mm-1) + dt*( kn*( S(mm-1) - UU(mm-1) ) + kk*abs(S(mm)-S(mm-1))/dt );
  UU(mm) = UU(mm-1) + dt*( kn*( U(mm-1) - UU(mm-1) )  );
end;

