function s=mrsignal(t,rf,g)
% Usage ... s=mrsignal(t,rf,g)
%
% MR signal evolution given the 1-channel rf and 3-channel gradient
% waveforms with their correspondent time scale

H_GAMMA=26752;		% rad/Gs

nspins=1e5;
B0=1500;		% G
R1=0/1000e-3;		% 1/ms
R2=1/40e-3;		% 1/ms
R2p=0/20e-3;		% 1/ms, function of ...

freq_spread_ppm=0e-6;	% ppm-Hz 
angl_spread=0*pi/6;	% rad

seed1=sum(100*clock);
randn('seed',seed1);
w=randn([nspins 1])*H_GAMMA*B0*freq_spread_ppm;
phi=randn([nspins 1])*angl_spread;

if rf(1),
  rf_init=1;
  rfoff_t=t(1);
else,
  rf_init=0;
end; 

z_xy(:,1) = ones([nspins 1]) .* exp(+j*rf(1));
xy_xy(:,1) = imag(z_xy(:,1));

for m=2:length(t),

  if (rf_init)&(~rf(m)),

    seed2=sum(100*clock);
    rand('seed',seed2);
    tt=t(m)-rfoff_t;
    d_psi=rand([nspins 1])*2*pi*R2*exp(-tt*R2);
    d_psi=d_psi-0.5*2*pi*R2*exp(-tt*R2);

    d_z=ones([nspins 1])* R1*exp(-tt*R1);
    d_xy=ones([nspins 1])* R2p*exp(-tt*R2p);

  else,

    rf_init=1;
    rfoff_t=t(m);

  end;

  z_xy(:,m) = z_xy(:,m-1) .* exp(+j*rf(m));
  xy_xy(:,m) = imag(z_xy(:,m));

end;

