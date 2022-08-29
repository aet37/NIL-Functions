
clear all

dt=0.01;
T=120;
t=[0:dt:T];

N=0.0;
ust=5.0; udur=55;
U=mytrapezoid3(t,ust,udur,0.1,[14 N 3.0]);

fdur=4.0; framp=4.0;
F=mytrapezoid3(t,framp,fdur,framp);
UU=myconv(U,F)/sum(F);

m0=18.0;
m1=18.0;
n1=80;

A=(n1+n1*m0/m1);
B=(n1/m1);
C=m0;
[A B C],

AA=20;
BB=20;
CC=1;

y(1)=0;
y2(1)=0;
for mm=2:length(t),
  y(mm) = y(mm-1) + dt*(1/(n1+n1*m0/m1))*( UU(mm-1) + (n1/m1)*(UU(mm)-UU(mm-1))/dt - m0*y(mm-1) );
  y2(mm) = y2(mm-1) + dt*(1/AA)*( UU(mm-1) + BB*(UU(mm)-UU(mm-1))/dt - CC*y(mm-1) );
end;

plot(t,U,t,F,t,UU,t,y,t,y2)

load cbvres1b tv4 avgVV4b
plot(t,y+1,tv4,avgVV4b)

