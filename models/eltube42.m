
clear all

% Solution for a single harmonic

% flags
save_flag=0;

% design variables
qn=2e-9;	% units: m3/s
f=1;		% units: 1/s
k=10;		% units: 1/m

% known constants
nu=1;		% Poisson's ratio (radial/axial strains)
a0=100e-6;	% units: m
h0=0.15*a0;	% units: m
rho=1.05e3;	% units: kg/m3
mu=0.004;	% units: kg/m s
E0=2e4;		% units: N/m2
lambda=2*pi/k;	% units: m
w=2*pi*f;	% units: rad/s

% scales (dependent variables)
x=[0:a0/2:200*a0]';
r=[0:a0/20:a0]';
t=[0:1/(10*f):10]';

% flow properties: Re<2300 = laminar, c ~= 8 for microvasculature
Re=(qn/(pi*a0*a0))*(x(length(x))-x(1))*rho/mu;
Le=0.06*Re*2*a0;
c=w/lambda;

beta=i*w*rho/mu;
S=besselj(0,beta*a0)/besselj(1,beta*a0);

t1=1-2*nu;
t2=-2*rho;
t3=nu/(a0*beta)-S;
t4=rho/a0;
t5=((2-nu)/(2*rho))*(1/(beta*a0)-S*nu);

% determine the roots of the characteristic eqn, may need to choose 1...
Xr=roots(conv([t1 t2],[t3 t4])+[t5 0 0]);
X=Xr(2);

kc=sqrt(X*w*w*(1-nu*nu)*a0/(E0*h0));

theta_num=(X/(2*rho))*(1-2*nu)-1;
theta_den=X*(w/k)*(besselj(1,beta*a0)/(beta*a0)-nu*besselj(0,beta*a0));
theta=theta_num/theta_den;

% given Q at frequency w=2*pi*f we can calculate p -- Q*exp(-i(kx-wt))
pr=qn/(2*pi*(k*a0*a0/(2*w*rho)-theta*a0*besselj(1,beta*a0)/beta));

A=-theta*pr;

ur=(k/(w*rho)-theta*besselj(0,beta*r))*pr;
vr=-(i*k*k*pr/(2*w*rho))*r-(i*k*A*besselj(1,beta*r)/beta);

psir=-k*pr/(i*w*w*rho)-A*besselj(0,beta*a0)/(i*w);
etar=k*k*a0*pr/(2*w*w*rho)+A*k*besselj(1,beta*a0)/(beta*w);

disp('Determining all dependent variables...');
% full dimensional quantities
for n=1:length(t),
  for m=1:length(x),
    u(m,:,n)=ur.*exp(i*(k*x(m)-w*t(n)));
    v(m,:,n)=vr.*exp(i*(k*x(m)-w*t(n)));
    p(m,n)=pr.*exp(i*(k*x(m)-w*t(n)));
    psi(m,n)=psir.*exp(i*(k*x(m)-w*t(n)));
    eta(m,n)=etar.*exp(i*(k*x(m)-w*t(n)));
  end;
  Vreal(n)=sum((x(2)-x(1))*pi*(a0+real(eta(:,n))).*(a0+real(eta(:,n))));
  Vinreal(n)=(t(2)-t(1))*pi*(a0+real(eta(1,n)))*(a0+real(eta(1,n)))*mean(real(u(1,:,n)));
  Voutreal(n)=(t(length(t))-t(length(t)-1))*pi*(a0+real(eta(length(x),n)))*(a0+real(eta(length(x),n)))*mean(real(u(length(x),:,n))); 
end;
disp('Done...');

if (save_flag), 
  save eltube4tmp 
end;

