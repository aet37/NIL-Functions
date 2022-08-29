
clear all

% Chemo-mechanical model of the arterial smooth muscle
% Fp: Passive force
% Fa: Active force (generating force)
% Fx: Cross-bridge force
% Fs: Series viscoelastic force
%
% constraints:
%  Fs = Fa = Fx
%  Ftotal = Fa + Fp
%  lc = lx + ls + la

kp=0.1;		% parallel element stiffness (micro-N)
aap=0.1;	% constant for parallel element
l0=40;		% cell length for zero passive force (micro-m)

kx1=12.5;	% phosphorylated cross-bridge stiffness constant (micro-N/micro-m)
kx2=8.8;	% latch bridge stiffness constant (micro-N/micro-m)
bb=7.5;		% length modulation constant
lopt=100;	% optimal length of active contractile element (micro-m)

fAMp=1.3;	% friction constant for phosphorylated cross-bridges (micro-N ms/micro-m)
fAM=85.5;	% friction constant for latch bridges (micro-N ms/micro-m)
vx=5.0;		% velocity of cross-bridge cycling (micro-m/ms)

mms=0.01;	% viscosity of series element (micro-N ms/micro-m)
ks=0.2;		% siffness od series element (micro-N)
aas=4.5;	% constant for series element
ls0=30;		% length of series element at zero force (micro-m)

% initial conditions
ls(1)=37.05;
lx(1)=89.60;
AMp(1)=0.0627;


Fp(mm) = kp*( exp(aap*(lc(mm)-l0)/l0) - 1 );
% unknown Fp and lc

Fx(mm) = ( kx1*AMp(mm) + kx2*AM(mm) )*lx(mm)*exp(-bb*((la(mm)-lopt)/lopt)^2);
% unknown Fx, lx and la

dladt(mm) = (la(mm)-la(mm-1))/dt;

Fa(mm) = ( fAMp*AMp(mm)*( vx + dladt(mm) ) + fAM*AM(mm)*dladt(mm) )*exp(-bb*((la(mm)-lopt)/lopt)^2);
% unknown Fa and la

dlsdt=(ls(mm)-ls(mm-1))/dt;

Fs(mm) = mms*dlsdt(mm) + ks*( exp(aas*(ls(mm)-ls0)/ls0) - 1 );
% unknown Fs and ls


% note that Fs=Fa=Fx so Fs can be calculated from ls and la can be calculated
%  if dladt and Fa are known; then lx can be calculated if Fx is known and la
%  finally Fp can be calculated by calculating lc

