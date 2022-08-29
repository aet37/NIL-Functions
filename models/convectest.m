
clear all

dt=0.01;
T=20;
t=[0:dt:T];

dx=0.001;
X=1;
x=[0:dx:X];

U=0.01*mytrapezoid(t,2,6,1);

kx1=1/3;
kx2=1/3;

k1=1;
k2=1;
k3=1;
k4=1;

kz1=.1;

X(1)=0;
A(1)=0; B(1)=0; C(1)=0;
Z(1,:)=zeros(size(x));
for mm=2:length(t),
  X(mm)=X(mm-1)+dt*( kx1*U(mm-1) - kx2*X(mm-1) );

  A(mm)=A(mm-1)+dt*( k1*U(mm-1) - k2*A(mm-1) );
  B(mm)=B(mm-1)+dt*( k2*A(mm-1) - k3*B(mm-1) );
  C(mm)=C(mm-1)+dt*( k3*B(mm-1) - k4*C(mm-1) );

  Z(mm,1)=U(mm);
  for nn=2:length(x),
    Z(mm,nn)=Z(mm-1,nn)+dt*( kz1*(Z(mm-1,nn)-Z(mm-1,nn-1))/dx );
  end;

end;

plot(t,[U' X' A' C'],t,[Z(:,1) Z(:,end)])
plot(t,[Z(:,1) Z(:,end)])

%for mm=2:length(t),
%  for nn=2:length(x),
%    AA(mm,nn)=A(mm,nn-1)+

