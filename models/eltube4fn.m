function [Xr,eta,psi,p,u,v,Vreal,Vinreal,Voutreal]=eltube4fn(qn,fn,km,parms,r,x,t)
% Usage ... [Xr,eta,psi,p,u,v,Vreal,Vinreal,Voutreal]=eltube4fn(qn,fn,km,parms,r,x,t)
% 
% This function is used to calculate the roots of the
% characteristic function used in the calculation of
% flow in an elastic tube as described by eltube4.m

if nargin<4, parms=[]; end;

if length(parms)<6, E0=1e4; else, E0=parms(6); end;
if length(parms)<5, nu=0.5; else, nu=parms(5); end;
if length(parms)<4, mu=0.004; else, mu=parms(4); end;
if length(parms)<3, rho=1.05e3; else, rho=parms(3); end;
if length(parms)<2, a0=100e-6; else, a0=parms(1); end;
if length(parms)<1, h0=0.2*a0; else, h0=parms(2); end;

lambda=2*pi/km;
w=2*pi*fn;

if (fn~=0),
  beta=i*w*rho/mu;
  S=besselj(0,beta*a0)/besselj(1,beta*a0);

  t1=1-2*nu;
  t2=-2*rho;
  t3=nu/(a0*beta)-S;
  t4=rho/a0;
  t5=((2-nu)/(2*rho))*(1/(beta*a0)-S*nu);

  % determine the roots of the characteristic eqn, may need to choose 1...
  Xr=roots(conv([t1 t2],[t3 t4])+[t5 0 0]);

else,

  Xr=[0 0];

end;

if (nargout>1),

  if (fn==0),
    % this results may not apply?
    % results maybe 90 degs out of phase ('i' in numerator excluded)
    k=km;
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

    % perhaps this should be a test of magnitude over 0...
    if abs(Xr(1))>abs(Xr(2)),
      X=Xr(1);
      XR=abs(Xr(1))/abs(Xr(2));
    else,
      X=Xr(2);
      XR=abs(Xr(2))/abs(Xr(1));
    end;
    if XR<100, disp('warning: roots are close to each other'); end;

    k=sqrt(w*w*(1-nu*nu)*a0/(E0*h0));

    theta_num=(X/(2*rho))*(1-2*nu)-1;
    theta_den=X*(w/k)*( besselj(1,beta*a0)/(beta*a0) - nu*besselj(0,beta*a0) );
    theta=theta_num/theta_den;

    % given Q at frequency w=2*pi*f we can calculate p -- Q*exp(-i(kx-wt))
    pr=qn/(2*pi*( k*a0*a0/(2*w*rho) - theta*a0*besselj(1,beta*a0)/beta ));

    A=-theta*pr;

    ur=( k/(w*rho) - theta*besselj(0,beta*r) )*pr;
    vr= -(i*k*k*pr/(2*w*rho))*r - (i*k*A*besselj(1,beta*r)/beta);

    psir= -k*pr/(i*w*w*rho) - A*besselj(0,beta*a0)/(i*w) ;
    etar= k*k*a0*pr/(2*w*w*rho) + A*k*besselj(1,beta*a0)/(beta*w) ;

  end;
  k,

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

end;

