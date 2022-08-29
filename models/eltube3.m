
% variation of the elastic tube stuff using tubes
% subject to a sinusiodal pressure wave (e.g. pulsatile flow)
%
% input: p(x,r,t)= B*exp(i*w*(t-x/c))
%
% To do:
%  - roots z are calculated so only one of these is
%    used in the analysis, make sure this is ok...

% input pressure parameters
B=1e5;		% units: N/m2
w=2*pi*1;	% units: rad

% tube properties
a0=100e-6;	% units: m
h0=0.2*a0;	% units: m
E0=1e4;		% units: N/m2
sigma=10;	% units: N/m2

% fluid properties
rho=1e3;	% units: kg/m3
rhow=1e3;	% units: kg/m3
mu=0.0035;	% units: Poise

L=1e-2;		% units: m
T=10;		% units: s

% independent variables
r=[0:1e-6:a0];
x=[0:1e-4:L];
t=[0:1e-1:T];

% wave properties
c0=sqrt(E0*h0/(2*rho*a0));

% solutions
omega=sqrt(rho*w/mu)*a0;
lambda=omega*(i-1)/sqrt(2);
psi=lambda*r/a0;
g=2*besselj(1,lambda)/(lambda*besselj(0,lambda));

za=(g-1)*(sigma*sigma-1);
zb=rhow*h0*(g-1)/(rho*a0)+g*(2*sigma-0.5)-2;
zc=2*rhow*h0/(rho*a0);
z_roots=roots([za zb zc]);
z=z_roots(2);

c=c0*sqrt(2/(z*(1-sigma*sigma)));

ACDden=z*(g-2*sigma);
A=(1/(rho*c*besselj(0,lambda)))*(2+z*(2*sigma-1))*B/ACDden;
C=(i/(rho*c*w))*(2-z*(1-g))*B/ACDden;
D=(a0/(rho*c*c))*(g+sigma*z*(g-1))*B/ACDden;

G=(2+z*(2*sigma-1))/(-1*ACDden);

% solutions: (note the coeffs are only a function of r)
%  u(x,r,t)= A*J0(psi)+B/rho*c exp(iw(t-x/c))
%  v(x,r,t)= A*iwaJ1(psi)/cLambda+Biwr/2rhoc2 exp(iw(t-x/c))
%  p(x,r,t)= B exp(iw(t-x/c))
%
%  u(x,r,t)= B/rho*c (1-G*besselj(0,psi)/besselj(0,lambda)) exp(iw(t-x/c)

for n=1:length(t),
  for m=1:length(x),

    u(m,:,n) = (A*besselj(0,psi) + B/(rho*c)).*exp(i*w*(t(n)-x(m)/c));
    v(m,:,n) = (A*i*w*a0*besselj(1,psi)/(c*lambda) + B*i*w*r./(rho*c*c))* ...
               exp(i*w*(t(n)-x(m)/c));
    p(m,:,n) = B*exp(i*w*(t(n)-x(m)/c));

  end;
end;

figure(1)
subplot(221)
plot(t,real(squeeze(p(1,1,:))),t,real(squeeze(p(length(x),1,:))),'r')
xlabel('Time')
ylabel('Pressure')
title('Inlet and outlet')
subplot(222)
plot(t,real(squeeze(u(1,1,:))),t,real(squeeze(u(length(x),1,:))),'r')
xlabel('Time')
ylabel('u-Velocity')
title('Inlet and outlet')
subplot(223)
plot(real(squeeze(u(1,:,1))),r)
xlabel('u-Velocity')
ylabel('r-Position')
subplot(224)
plot(real(squeeze(v(1,:,1))),r)
xlabel('v-Velocity')
ylabel('r-Position')

