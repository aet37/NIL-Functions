
clear all

% Solution for multiple harmonic

% flags
plot_flag=1;

% scales (dependent variables)
x=[0:50e-6:200e-4]';
r=[0:100e-6/20:100e-6]';
t=[0:1:50]';

% design variables (q0=2e-9 f=0, q1=2e-10 f1=0.01)
k=65;           % units: 1/m  (may want k<1/2L or k<1.35/2L)
q0=0e-10;
f0=0;
dt=t(2)-t(1);

qn=q0;
fn=f0;
q=q0*ones(size(t));

% known constants
nu=0.5;         % Poisson's ratio (radial/axial strains)
a0=100e-6;      % units: m
h0=0.15*a0;     % units: m
rho=1.05e3;     % units: kg/m3
mu=0.004;       % units: kg/m s
E0=1e5;         % units: N/m2

lambda=2*pi/k;  % units: m
w=2*pi*fn;      % units: rad/s
c=w/lambda;

% flow properties: Re<2300 = laminar, c ~= 8 for microvasculature
Re=(q0/(pi*a0*a0))*(x(end)-x(1))*rho/mu;
Le=0.06*Re*2*a0;

if (fn==0),

  X=0;
  % this results may not apply?
  % results maybe 90 degs out of phase ('i' in numerator excluded)
  pr= i*qn*8*mu/(pi*k*a0*a0*a0*a0);

  ur=(1/4)*(i*k*pr/mu)*( r.*r - a0*a0 );
  i0=find(r==0); if length(i0)~=0, rr=r; rr(i0)=ones(size(i0)); end;
  vr=((k*k*pr)/(4*mu))*( rr.*rr.*rr/4 - a0*a0*rr./2 - a0*a0*a0*a0./(4*rr) );
  i0=find(r==0); if length(i0)~=0, vr(i0)=zeros(size(i0)); end;

  Apsieta=[1/(a0*a0) i*k*nu/a0; -2*nu/(a0*a0) -i*2*k/a0];
  bpr=(pr*(1-nu*nu)/(E0*h0))*ones([2 1]);
  psietar=inv(Apsieta)*bpr;
  etar=psietar(1);
  psir=psietar(2);

else,

  beta=sqrt(i*w*rho/mu);

  Acalctype=1;
  if (Acalctype==1),

    % determine A and theta
    Estar=E0*h0/((1-nu*nu)*a0);
    theta1=(Estar*k*k*(0.5-nu)/(rho*w*w)-1)/((Estar*k/w)*(besselj(1,beta*a0)/(beta*a0)-nu*besselj(0,beta*a0)));
    theta2=(k*(2-nu)/(2*w*w*i*rho))/(besselj(1,beta*a0)*(mu*beta/(Estar*a0*k*k)+i*nu/(a0*w*beta))-(i/w)*besselj(0,beta*a0));
    disp(sprintf('Choosing between thetas: %e, %e',theta1,theta2));
    if (abs(theta1)>abs(theta2)), theta=theta1; else, theta=theta2; end;

    % given Q at frequency w=2*pi*f we can calculate p -- Q*exp(-i(kx-wt))
    pr=qn/(2*pi*(k*a0*a0/(2*w*rho)-theta*a0*besselj(1,beta*a0)/beta));
    A=-pr*theta;
    X=theta;

  else,

    S=besselj(0,beta*a0)/besselj(1,beta*a0);
    t1=1-2*nu;
    t2=-2*rho;
    t3=nu/(a0*beta)-S;
    t4=rho/a0;
    t5=((2-nu)/(2*rho))*(1/(beta*a0)-S*nu);

    % determine the roots of the characteristic eqn
    %  need to choose one at a time
    %  choose the smaller one first
    Xr=roots(conv([t1 t2],[t3 t4])+[t5 0 0]);
    if (Xr(1)>Xr(2)), X=Xr(2); else, X=Xr(1); end;
    kc=sqrt(X*w*w*(1-nu*nu)*a0/(E0*h0));

    % determining A and theta
    theta_num=(X/(2*rho))*(1-2*nu)-1;
    theta_den=X*(w/k)*(besselj(1,beta*a0)/(beta*a0)-nu*besselj(0,beta*a0));
    theta=theta_num/theta_den;

    % given Q at frequency w=2*pi*f we can calculate p -- Q*exp(-i(kx-wt))
    pr=qn/(2*pi*(k*a0*a0/(2*w*rho)-theta*a0*besselj(1,beta*a0)/beta));
    A=-pr*theta;

  end;

  ur=(k/(w*rho)-theta*besselj(0,beta*r))*pr;
  vr=-(i*k*k*pr/(2*w*rho))*r-(i*k*A*besselj(1,beta*r)/beta);

  % just choose real parts here?
  psir=-k*pr/(i*w*w*rho)-A*besselj(0,beta*a0)/(i*w);
  etar=k*k*a0*pr/(2*w*w*rho)+A*k*besselj(1,beta*a0)/(beta*w);

end;

% full dimensional quantities
for n=1:length(t),
  for m=1:length(x),
    u(m,:,n)=ur.*exp(i*(k*x(m)-w*t(n)));
    v(m,:,n)=vr.*exp(i*(k*x(m)-w*t(n)));
    p(m,n)=pr.*exp(i*(k*x(m)-w*t(n)));
    psi(m,n)=psir.*exp(i*(k*x(m)-w*t(n)));
    eta(m,n)=etar.*exp(i*(k*x(m)-w*t(n)));
  end;
end;

V0=pi*(a0*a0)*(x(end)-x(1));

Fin=q;
for m=1:length(t),
  tmpr2real=(a0+real(eta(:,m))).*(a0+real(eta(:,m)));
  tmpr2imag=(a0+imag(eta(:,m))).*(a0+imag(eta(:,m)));
  tmpdx=x(2)-x(1);
  V(m) = sum( tmpdx*pi*tmpr2real ) + i* sum( tmpdx*pi*tmpr2imag );
  if (m==1),
    Fout(m) = Fin(m);
  else,
    tmpfreal= Fin(m) - (real(V(m)-real(V(m-1)))/dt);
    tmpfimag= Fin(m) - (imag(V(m)-imag(V(m-1)))/dt);
    Fout(m) = tmpfreal + i*tmpfimag;
  end;

end;
clear tmpr2real tmpr2imag tmpfreal tmpfimag

if (plot_flag),
  subplot(321)
  plot(x,real(p(:,1)),x,imag(p(:,1)),x,abs(p(:,1)))
  xlabel('x'), ylabel('P'),
  subplot(322)
  plot(t,real(p(1,:)),t,imag(p(1,:)),t,abs(p(1,:)))
  xlabel('t'), ylabel('P'),
  subplot(323)
  plot(x,real(squeeze(u(:,1,1))),x,imag(squeeze(u(:,1,1))),x,abs(squeeze(u(:,1,1))))
  xlabel('x'), ylabel('U'),
  subplot(324)
  plot(t,real(squeeze(u(1,1,:))),t,imag(squeeze(u(1,1,:))),t,abs(squeeze(u(1,1,:))))
  xlabel('t'), ylabel('U'),
  subplot(325)
  plot(x,real(eta(:,1)),x,imag(eta(:,1)),x,abs(eta(:,1)))
  xlabel('x'), ylabel('Eta'),
  subplot(326)
  plot(t,real(eta(1,:)),t,imag(eta(1,:)),t,abs(eta(1,:)))
  xlabel('t'), ylabel('Eta'),
end;

