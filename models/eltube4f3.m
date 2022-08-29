function [u,v,p,psi,eta]=eltube4f3(qn,fn,k,x,r,t,parms)
% Usage ... [u,v,p,psi,eta]=eltube4f3(qn,fn,k,x,r,t,parms)

% known constants
if nargin<7,
  nu=0.5;         % Poisson's ratio (radial/axial strains)
  a0=100e-6;      % units: m
  h0=0.15*a0;     % units: m
  rho=1.05e3;     % units: kg/m3
  mu=0.004;       % units: kg/m s
  E0=2e4;         % units: N/m2
else,
  nu=parms(1);
  a0=parms(2);
  h0=parms(3);
  rho=parms(4);
  mu=parms(5);
  E0=parms(6);
end;

verbose_flag=0;

% model constants
lambda=2*pi/k;  % units: m
w=2*pi*fn;       % units: rad/s

% flow properties: Re<2300 = laminar, c ~= 8 for microvasculature
Re=(qn/(pi*a0*a0))*(x(end)-x(1))*rho/mu;
Le=0.06*Re*2*a0;
c=w/lambda;

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

  % just choose real part here?
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
    if (abs(theta1)<abs(theta2)), theta=theta1; else, theta=theta2; end;

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

  % just choose real part here?
  psir=-k*pr/(i*w*w*rho)-A*besselj(0,beta*a0)/(i*w);
  etar=k*k*a0*pr/(2*w*w*rho)+A*k*besselj(1,beta*a0)/(beta*w);

end;

if (verbose_flag),
  disp('Model parameters:')
  disp(sprintf('  Re= %e, Le= %e',Re,Le));
  disp(sprintf('  A= %e (X or theta= %e)',A,X));
  disp(sprintf('  Pr= (%e, %e) N/m2',real(pr),imag(pr)));
  disp(sprintf('  Ur= (%e, %e) m/s',real(ur(1)),imag(ur(1))));
  disp(sprintf('  Vr= (%e, %e) m/s',real(vr(1)),imag(vr(1))));
  disp(sprintf('  Ar= (%e, %e) m',real(psir),imag(psir)));
  disp(sprintf('  Br= (%e, %e) m',real(etar),imag(etar)));
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

