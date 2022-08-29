
clear all

a0=100e-6;
h0=0.15*a0;
rho=1.05e3;
visc=0.004;
E0=5e4;
sigma=0.5;

rhow=rho;
Esigma=E0/(1-sigma*sigma);

f0=1;
w=2*pi*f0;

r=[0:a0/20:a0]; r=r(:);
x=[0:a0:100*a0]; x=x(:);
t=[0:1/(20*f0):2/f0]; t=t(:);

omega=sqrt(rho*w/visc)*a0;
lambda=omega*(i-1)/sqrt(2);
psi=lambda*r./a0;

g=(2/lambda)*(besselj(1,lambda)/besselj(0,lambda));
z2=(g-1)*(sigma*sigma-1);
z1=(rhow*h0*(g-1)/(rho*a0)+(2*sigma-1/2)*g-2);
z0=(2*rhow*h0/(rho*a0)+g);
zs=roots([z2 z1 z0]);
z=zs(1);

c=sqrt(Esigma*h0/(rho*a0*z));
c0=E0*h0/(2*rho*a0);

P0=5000;
B=P0;

A=(1/(rho*c*besselj(0,lambda)))*((2+z*(2*sigma-1))/(z*(g-2*sigma)))*B;
C=(i/(rho*c*w))*((2-z*(1-g))/(z*(2*sigma-g)))*B;
D=(a0/(rho*c*c))*((g+sigma*z*(g-1))/(z*(g-2*sigma)));

G=(2+z*(2*sigma-1))/(z*(2*sigma-g));

G,zs,c,c0,

Ur=A*besselj(0,psi)+B*(1/(rho*c0));
Vr=A*(i*w*a0/(c0*lambda))*besselj(1,lambda)+B*(i*w*r./(2*rho*c0*c0));
Pr=B;
ETAr=C;
PSIr=D;

gamma=i*w*a0/c0;

for n=1:length(t),
  for m=1:length(x),
    U(:,m,n)=Ur*exp(i*w*(t(n)-x(m)./c0));
    V(:,m,n)=Vr*exp(i*w*(t(n)-x(m)./c0));
    P(m,n)=Pr*exp(i*w*(t(n)-x(m)./c0));
    PSI(m,n)=PSIr*exp(i*w*(t(n)-x(m)./c0));
    ETA(m,n)=ETAr*exp(i*w*(t(n)-x(m)./c0));
  end;
end;

for n=1:length(t),
  VOL(n)=
end;
