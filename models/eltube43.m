
clear all

% Solution for multiple harmonic

% flags
plot_flag=1;

% scales (dependent variables)
x=[0:50e-6:200e-4]';
r=[0:100e-6/20:100e-6]';
t=[0:1:120]';

% design variables (q0=2e-9 f=0, q1=2e-10 f1=0.01)
k=65;           % units: 1/m  (may want k<1/2L or k<1.35/2L)
q0=1e-10; q1=.5*q0;
%q = q0*ones(size(t));
%q = q0 + q1*sin(2*pi*0.01*t);
%q = q0 + q1*smrect(t,[0.10 10 30],1);
q = q1*smrect(t,[0.10 10 10],1) - q1*smrect(t,[0.10 10 70],1);
qf=fft(q);
ff=[0:1/(t(end)-t(1)):1/(t(2)-t(1))]';
dt=t(2)-t(1);

% known constants
nu=0.5;         % Poisson's ratio (radial/axial strains)
a0=100e-6;      % units: m
h0=0.15*a0;     % units: m
rho=1.05e3;     % units: kg/m3
mu=0.004;       % units: kg/m s
E0=1e5;         % units: N/m2

lambda=2*pi/k;  % units: m

% flow properties: Re<2300 = laminar, c ~= 8 for microvasculature
Re=(q0/(pi*a0*a0))*(x(end)-x(1))*rho/mu;
Le=0.06*Re*2*a0;

disp('Determining all dependent variables...');
% full dimensional quantities
parms=[nu a0 h0 rho mu E0];
u=zeros([length(x) length(r) length(t)]);
v=zeros([length(x) length(r) length(t)]);
p=zeros([length(x) length(t)]);
psi=zeros([length(x) length(t)]);
eta=zeros([length(x) length(t)]);
for m=1:length(qf),
  [uu,vv,pp,psii,etaa]=eltube4f3(qf(m),ff(m),k,x,r,t,parms);
  u=u+uu;
  v=v+vv;
  p=p+pp;
  psi=psi+psii;
  eta=eta+etaa;
end;
clear uu vv pp psii etaa

% signal processing -- required???
%   looks like there is a phase problem in the outdata



disp('Determining volume and outflow calculations...');
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

disp('Done...');

if (plot_flag),
  tmid=floor(length(t)/2);
  xmid=floor(length(x)/2);
  figure(1)
  subplot(321)
  title('Pressure through time')
  plot(t,real(p(1,:)),t,imag(p(1,:)),t,abs(p(1,:)))
  ylabel('Pressure @ Entry')
  subplot(323)
  plot(t,real(p(xmid,:)),t,imag(p(xmid,:)),t,abs(p(xmid,:)))
  ylabel('Pressure @ Mid')
  subplot(325)
  plot(t,real(p(end,:)),t,imag(p(end,:)),t,abs(p(end,:)))
  ylabel('Pressure @ End')
  xlabel('Time')
  subplot(322)
  title('Pressure through distance')
  plot(x,real(p(:,1)),x,imag(p(:,1)),x,abs(p(:,1)))
  ylabel('Pressure @ t=0')
  subplot(324)
  plot(x,real(p(:,tmid)),x,imag(p(:,tmid)),x,abs(p(:,tmid)))
  ylabel('Pressure @ t=mid')
  subplot(326)
  plot(x,real(p(:,end)),x,imag(p(:,end)),x,abs(p(:,end)))
  ylabel('Pressure @ t=end')
  xlabel('Distance')
  figure(2)
  subplot(331)
  title('Profiles at t=tmid')
  plot(r,real(u(1,:,tmid)),r,imag(u(1,:,tmid)),r,abs(u(1,:,tmid)))
  ylabel('U profile @ x=entry')
  subplot(334)
  plot(r,real(u(xmid,:,tmid)),r,imag(u(xmid,:,tmid)),r,abs(u(xmid,:,tmid)))
  ylabel('U profile @ x=mid')
  subplot(337)
  plot(r,real(u(end,:,tmid)),r,imag(u(end,:,tmid)),r,abs(u(end,:,tmid)))
  ylabel('U profile @ x=end')
  xlabel('Radius')
  subplot(332)
  title('Velocity at r=0 through distance')
  plot(x,real(u(:,1,1)),x,imag(u(:,1,1)),x,abs(u(:,1,1)))
  ylabel('U velocity @ t=0')
  subplot(335)
  plot(x,real(u(:,1,tmid)),x,imag(u(:,1,tmid)),x,abs(u(:,1,tmid)))
  ylabel('U velocity @ t=mid')
  subplot(338)
  plot(x,real(u(:,1,end)),x,imag(u(:,1,end)),x,abs(u(:,1,end)))
  ylabel('U velocity @ t=end')
  xlabel('Distance')
  subplot(333)
  title('Velocity')
  plot(t,real(squeeze(u(1,1,:))),t,imag(squeeze(u(1,1,:))),t,abs(squeeze(u(1,1,:))))
  ylabel('U velocity @ Entry')
  subplot(336)
  plot(t,real(squeeze(u(xmid,1,:))),t,imag(squeeze(u(xmid,1,:))),t,abs(squeeze(u(xmid,1,:))))
  ylabel('U velocity @ Mid')
  subplot(339)
  plot(t,real(squeeze(u(end,1,:))),t,imag(squeeze(u(end,1,:))),t,imag(squeeze(u(end,1,:))))
  ylabel('U velocity @ End')
  xlabel('Time')
  figure(3)
  subplot(321)
  title('Displacement through time')
  plot(t,real(eta(1,:)),t,imag(eta(1,:)),t,abs(eta(1,:)))
  ylabel('Displacement @ Entry')
  subplot(323)
  plot(t,real(eta(xmid,:)),t,imag(eta(xmid,:)),t,abs(eta(xmid,:)))
  ylabel('Displacement @ Mid')
  subplot(325)
  plot(t,real(eta(end,:)),t,imag(eta(end,:)),t,abs(eta(end,:)))
  ylabel('Displacement @ End')
  xlabel('Time')
  subplot(322)
  title('Displacement through distance')
  plot(x,real(eta(:,1)),x,imag(eta(:,1)),x,abs(eta(:,1)))
  ylabel('Displacement @ t=0')
  subplot(324)
  plot(x,real(eta(:,tmid)),x,imag(eta(:,tmid)),x,abs(eta(:,tmid)))
  ylabel('Displacement @ t=mid')
  subplot(326)
  plot(x,real(eta(:,end)),x,imag(eta(:,end)),x,abs(eta(:,end)))
  ylabel('Displacement @ t=end')
  xlabel('Distance')
  figure(4),
  subplot(311)
  plot(t,Fin)
  ylabel('Fin')
  subplot(312)
  plot(t,real(Fout),t,imag(Fout),t,abs(Fout))
  ylabel('Fout')
  subplot(313)
  plot(t,real(V),t,imag(V),t,abs(V))
  ylabel('V')
  xlabel('Time')
end;


