
% Solution for a single harmonic

% flags
plot_flag=1;
save_flag=0;
additive_flag=0;

if (~additive_flag),
  disp('Clearing workspace...');
  clear all
  plot_flag=1;
  save_flag=0;
  additive_flag=0;
end;

% design variables (qn=2e-9 f=0, qn=2e-10 f=0.01)
qn=2e-9;	% units: m3/s
f=0;		% units: 1/s
k=65;		% units: 1/m  (may want k<1/2L or k<1.35/2L)

% known constants
nu=0.5;		% Poisson's ratio (radial/axial strains)
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
if (f==0), t=[0:1/10:20]'; else, t=[0:1:50]'; end;

% flow properties: Re<2300 = laminar, c ~= 8 for microvasculature
Re=(qn/(pi*a0*a0))*(x(end)-x(1))*rho/mu;
Le=0.06*Re*2*a0;
c=w/lambda;


disp('Determining coefficients...');

if (f==0), 

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

  beta=i*w*rho/mu;

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

  psir=-k*pr/(i*w*w*rho)-A*besselj(0,beta*a0)/(i*w);
  etar=k*k*a0*pr/(2*w*w*rho)+A*k*besselj(1,beta*a0)/(beta*w);

end;

disp('Model parameters:')
disp(sprintf('  Re= %e, Le= %e',Re,Le));
if (f~=0), disp(sprintf('  A= %e (X or theta= %e)',A,X)); end;
disp(sprintf('  Pr= (%e, %e) N/m2',real(pr),imag(pr)));
disp(sprintf('  Ur= (%e, %e) m/s',real(ur(1)),imag(ur(1))));
disp(sprintf('  Vr= (%e, %e) m/s',real(vr(1)),imag(vr(1))));
disp(sprintf('  Ar= (%e, %e) m',real(psir),imag(psir)));
disp(sprintf('  Br= (%e, %e) m',real(etar),imag(etar)));

if (~additive_flag),
  disp('Initializing variables...');
  u=zeros([length(x) length(r) length(t)]);
  v=zeros([length(x) length(r) length(t)]);
  p=zeros([length(x) length(t)]);
  psi=zeros([length(x) length(t)]);
  eta=zeros([length(x) length(t)]);
end;

disp('Determining all dependent variables...');
% full dimensional quantities
for n=1:length(t),
  for m=1:length(x),
    u(m,:,n)=u(m,:,n)+ur.*exp(i*(k*x(m)-w*t(n)));
    v(m,:,n)=v(m,:,n)+vr.*exp(i*(k*x(m)-w*t(n)));
    p(m,n)=p(m,n)+pr.*exp(i*(k*x(m)-w*t(n)));
    psi(m,n)=psi(m,n)+psir.*exp(i*(k*x(m)-w*t(n)));
    eta(m,n)=psi(m,n)+etar.*exp(i*(k*x(m)-w*t(n)));
  end;
  Vreal(n)=sum((x(2)-x(1))*pi*(a0+real(eta(:,n))).*(a0+real(eta(:,n))));
  Vinreal(n)=(t(2)-t(1))*pi*(a0+real(eta(1,n)))*(a0+real(eta(1,n)))*mean(real(u(1,:,n)));
  Voutreal(n)=(t(length(t))-t(length(t)-1))*pi*(a0+real(eta(length(x),n)))*(a0+real(eta(length(x),n)))*mean(real(u(length(x),:,n))); 
end;

disp('Done...');

if (plot_flag),
  tmid=floor(length(t)/2);
  xmid=floor(length(x)/2);
  figure(1)
  subplot(321)
  title('Pressure through time')
  plot(t,real(p(1,:)),t,imag(p(1,:)))
  ylabel('Pressure @ Entry')
  subplot(323)
  plot(t,real(p(xmid,:)),t,imag(p(xmid,:)))
  ylabel('Pressure @ Mid')
  subplot(325)
  plot(t,real(p(end,:)),t,imag(p(end,:)))
  ylabel('Pressure @ End')
  xlabel('Time')
  subplot(322)
  title('Pressure through distance')
  plot(x,real(p(:,1)),x,imag(p(:,1)))
  ylabel('Pressure @ t=0')
  subplot(324)
  plot(x,real(p(:,tmid)),x,imag(p(:,tmid)))
  ylabel('Pressure @ t=mid')
  subplot(326)
  plot(x,real(p(:,end)),x,imag(p(:,end)))
  ylabel('Pressure @ t=end')
  xlabel('Distance')
  figure(2)
  subplot(331)
  title('Profiles at t=tmid')
  plot(r,real(u(1,:,tmid)),r,imag(u(1,:,tmid)))
  ylabel('U profile @ x=entry')
  subplot(334)
  plot(r,real(u(xmid,:,tmid)),r,imag(u(xmid,:,tmid)))
  ylabel('U profile @ x=mid')
  subplot(337)
  plot(r,real(u(end,:,tmid)),r,imag(u(end,:,tmid)))
  ylabel('U profile @ x=end')
  xlabel('Radius')
  subplot(332)
  title('Velocity at r=0 through distance')
  plot(x,real(u(:,1,1)),x,imag(u(:,1,1)))
  ylabel('U velocity @ t=0')
  subplot(335)
  plot(x,real(u(:,1,tmid)),x,imag(u(:,1,tmid)))
  ylabel('U velocity @ t=mid')
  subplot(338)
  plot(x,real(u(:,1,end)),x,imag(u(:,1,end)))
  ylabel('U velocity @ t=end')
  xlabel('Distance')
  subplot(333)
  title('Velocity')
  plot(t,real(squeeze(u(1,1,:))),t,imag(squeeze(u(1,1,:))))
  ylabel('U velocity @ Entry')
  subplot(336)
  plot(t,real(squeeze(u(xmid,1,:))),t,imag(squeeze(u(xmid,1,:))))
  ylabel('U velocity @ Mid')
  subplot(339)
  plot(t,real(squeeze(u(end,1,:))),t,imag(squeeze(u(end,1,:))))
  ylabel('U velocity @ End')
  xlabel('Time')
  figure(3)
  subplot(321)
  title('Displacement through time')
  plot(t,real(eta(1,:)),t,imag(eta(1,:)))
  ylabel('Displacement @ Entry')
  subplot(323)
  plot(t,real(eta(xmid,:)),t,imag(eta(xmid,:)))
  ylabel('Displacement @ Mid')
  subplot(325)
  plot(t,real(eta(end,:)),t,imag(eta(end,:)))
  ylabel('Displacement @ End')
  xlabel('Time')
  subplot(322)
  title('Displacement through distance')
  plot(x,real(eta(:,1)),x,imag(eta(:,1)))
  ylabel('Displacement @ t=0')
  subplot(324)
  plot(x,real(eta(:,tmid)),x,imag(eta(:,tmid)))
  ylabel('Displacement @ t=mid')
  subplot(326)
  plot(x,real(eta(:,end)),x,imag(eta(:,end)))
  ylabel('Displacement @ t=end')
  xlabel('Distance')
end;

if (save_flag), 
  save eltube4tmp 
end;

