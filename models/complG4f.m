function [y,U,UU,F,t]=complG4f(x,tparms,xg,parms2fit,data,tdata)
% Usage ... y=complG4f(x,tparms,xg,parms2fit)

if (~isempty(x)),
  xg(parms2fit)=x;
end;

dt=tparms(1);
T=tparms(2);
t=[0:dt:T];

N=xg(5); taun=xg(6);
ust=xg(1); udur=xg(2);
U=mytrapezoid3(t,ust,udur,dt*10,[14 N taun]);

fdur=xg(3); framp=xg(4);
F=mytrapezoid3(t,framp,fdur,framp);
UU=myconv(U,F)/sum(F);

m0=xg(7);
m1=xg(8);
n1=xg(9);

A=(n1+n1*m0/m1);
B=(n1/m1);
C=m0;
%[A B C],

AA=xg(6);
BB=xg(7);
CC=xg(8);

y(1)=0;
y2(1)=0;
for mm=2:length(t),
  y(mm) = y(mm-1) + dt*(1/(n1+n1*m0/m1))*( UU(mm-1) + (n1/m1)*(UU(mm)-UU(mm-1))/dt - m0*y(mm-1) );
  y2(mm) = y2(mm-1) + dt*(1/AA)*( UU(mm-1) + BB*(UU(mm)-UU(mm-1))/dt - CC*y(mm-1) );
end;

y=y+1;
y2=y2+1;

if (nargin>4),
  datai=interp1(tdata,data,t);
  y=y-datai;
  y2=y2-datai;
  [x sum(y.^2)/length(t)],
end;

