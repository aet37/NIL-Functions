function [p,psi,eta,u,v,Vreal,Vinreal,Voutreal]=eltube4f(q,t,r,x,c0,parms)
% Usage ... [p,psi,eta,u,v,vol,vin,vout]=eltube4f(q,t,r,x,c0,parms)

if nargin<6, parms=[0.2*100e-6 100e-6 1.05e3 0.004 0.5 1e4]; end;

h0=parms(1);
a0=parms(2);
rho=parms(3);
mu=parms(4);
nu=parms(5);
E0=parms(6);

Re=(q(1)/(pi*a0*a0))*(x(length(x))-x(1))*rho/mu;
Le=0.06*Re*2*a0;
disp(sprintf('Re= %f  (Le=%f)',Re,Le));

tr=t(length(t))-t(1);
ts=t(2)-t(1);
f=[0:1/tr:1/ts];

t=t(:);
r=r(:);
x=x(:);
f=f(:);

qf=fft(q);

eta=zeros([length(x) length(t)]);
psi=zeros([length(x) length(t)]);
p=zeros([length(x) length(t)]);
u=zeros([length(x) length(r) length(t)]);
v=zeros([length(x) length(r) length(t)]);
eta_n=zeros([length(x) length(t)]);
psi_n=zeros([length(x) length(t)]);
p_n=zeros([length(x) length(t)]);
u_n=zeros([length(x) length(r) length(t)]);
v_n=zeros([length(x) length(r) length(t)]);

for m=1:length(q),
  disp(['Doing time point #',int2str(m),' ...']);
  eta_n=0; psi_n=0; p_n=0; u_n=0; v_n=0;
  [Xr,eta_n,psi_n,p_n,u_n,v_n]=eltube4f2n(qf(m),f(m),c0,parms,r,x,t);
  eta=eta+eta_n;
  psi=psi+psi_n;
  p=p+p_n;
  u=u+u_n;
  v=v+v_n;
end;

disp('Calculating volume...');
for m=1:length(t),
  Vreal(m)=sum((x(2)-x(1))*pi*(a0+real(eta(:,m))).*(a0+real(eta(:,m))));
  Vinreal(m)=(t(2)-t(1))*pi*(a0+real(eta(1,m)))*(a0+real(eta(1,m)))*mean(real(u(1,:,m)));
  Voutreal(m)=(t(length(t))-t(length(t)-1))*pi*(a0+real(eta(length(x),m)))*(a0+real(eta(length(x),m)))*mean(real(u(length(x),:,m)));
end;

disp('Done...');

%if nargout==0,
%  plot(ftinvert())
%end;

