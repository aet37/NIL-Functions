function [spins,s,spin_info,vessel_info]=mrsigdist(freqdist,phasedist,veldist,voxeldim,Gz,Gt,parms,seeds)
% Usage ... y=mrsigdist(freqdist,phasedist,veldist,voxeldim,G,Gt,parms,seeds)
%
% Calculates de final vector given the distribution of spins which
% makes up the signal. The corresponding frequency, phase and velocity
% distributions are assigned to the spin population.
% units:
% hgamma rad/Gs
% voxeldim = [xdim(cm) ydim(cm) zdim(cm)]
% vel cm/s
% G G/cm
% Gt s
% parms = [R1=1/T1 R2=1/T2 D(cm*cm/s) TF(ratio)]

HGAMMA=26752; %rad/Gs

if nargin<7,
  R1=0/1000e-3;
  R2=1/40e-3;
  D=1e-5;
  TF=0.6;
else,
  R1=parms(1);
  R2=parms(2);
  D=parms(3);
  TF=parms(4);
end;

if nargin<8,
  seed1=seeds(1);
  seed2=seeds(2);
  seed3=seeds(3);
else,
  seed1=0;
  seed2=0;
  seed3=0;
end;

% spin variable information content
% freq (1/s), phase (rad), velocity (cm/s), position (cm), in?out, rot (rad), result
% use discontinued

gradduration=Gt(length(Gt))-Gt(1);

% initially some dephasing, most spins aligned (Gaussian distribution?)
% also each spin is attributed a frequency distribution due to field
% inhomogeneity,such as susceptibility differences, etc.

% velocity distribution of the spin density, it has tissue and vascular
% distributions (exponential, gaussian or linear, respectively?)
% direction should be 3D in discrete orientations (assume z-dir for B0)
% to simulate a distribution of vasculature in a voxel with particular
% geometry (flow propreties) for thoe in larger vasculature
n_dirs=max(veldist(:,2));
if ~seed1, seed1=sum(100*clock); end;
rand('seed',seed1);
vel_phi=rand(size(freqdist))*2*pi;
vel_psi=rand(size(freqdist))*2*pi;
if n_dirs,
  discrete_phi=rand([n_dirs 1])*2*pi;
  discrete_psi=rand([n_dirs 1])*2*pi;
  for m=1:n_dirs,
    tmp=find(veldist(:,2)==m);
    if isempty(tmp), disp('Warning: no more flowing spins'); break; end;
    vel_phi(tmp(1))=discrete_phi(m);
    vel_psi(tmp(1))=discrete_psi(m);
    veldist(tmp(1),2)=-m;
  end;
end;

% the position of each spin the voxel should be uniformly distributed in
% the voxel, if the spin is calculated to leave the voxel then its
% contribution is discarded, however all spins are assumed to stay within
% the voxel for now...

% assume velocity is time-independent during the application of
% the gradient... the pulse and refocus assumed instantaneous for now...
% for time-dependent velocities replace int(v(t))=x(t)=v*t with int(v(t))
if size(Gz,2)==1,
  gradint(1:2)=[0 0];
  gradint(3)=trapz(Gt,Gz(:,1).*Gt);
else,
  gradint(1)=trapz(Gt,Gz(:,1).*Gt);
  gradint(2)=trapz(Gt,Gz(:,2).*Gt);
  gradint(3)=trapz(Gt,Gz(:,3).*Gt);
end;
velphase=zeros(size(freqdist));
for m=1:size(veldist,1),
  v2(m,:)=veldist(m,1)*[cos(vel_phi(m)).*cos(vel_psi(m)) sin(vel_phi(m)).*cos(vel_psi(m)) sin(vel_psi(m))];
  velphase(m)=HGAMMA*dot(v2(m,:),gradint); 	% should this be abs value???
end;

% A more general case for velocities, the velocities as a function of
% time in each direction must be given or else assumed constant 
%if size(veldist,2)<3,
%  for m=1:length(Gt),
%    vx(m,:)=veldist(m,1)*(cos(vel_phi(m))*cos(vel_psi(m)))*ones([1 length(Gt)]);
%    vy(m,:)=veldist(m,1)*(sin(vel_phi(m))*cos(vel_psi(m)))*ones([1 length(Gt)]);
%    vz(m,:)=veldist(m,1)*(sin(vel_psi(m)))*ones([1 length(Gt)]);
%  end;
%end;
%for m=1:length(freqdist),
%  for n=1:length(Gt),
%    r(n)=trapz(Gt(1:n),[vx(m,1:n) vy(m,1:n) vz(m,1:n)]');
%  end;
%  velphase(m)=trapz(Gt,HGAMMA*dot(Gz,r));
%end;

% since we are assuming a gradient echo acquisition, T1 will affect the
% magnitude of the vector in the transverse plane
% T1 will affect the magnitude of the vector while T2 effects should
% worsen the phase distribution (the actual dephasing is expressed as an
% amplitude term also)
%if ~seed2, seed2=sum(100*clock); end;
%rand('seed',seed2);
%spins=spins.*exp(+j*rand(size(phasedist))*((1-exp(-gradduration/T2))*2*pi-pi));
spins=ones(size(freqdist))*exp(-gradduration*R1);
spins=spins.*exp(-gradduration*R2);

b=HGAMMA*HGAMMA*(gradint(3)^2)*gradduration/(4*pi*pi*12);
DR=b*D/gradduration;
spins=spins.*exp(-b*D);

% accumulate the phase due to spin motion in the presence of the gradient
% for now, only accumulations in the z-dir are good...
spins=spins.*exp(+j*(2*pi*freqdist*gradduration + phasedist));
spins=spins.*exp(+j*velphase);

s=abs(sum(spins));

