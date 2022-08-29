function [I,T]=lightDepth1(z,fiber_parms)
% Usage ... [I,T]=lightDepth1(z,fiber_parms)

% ThorLabs
% Single-mode fibers (narrow wavelength selectivity)
% S405-XP NA=0.12 Rad=62.5um
% SM400 NA=0.12 Rad=62.5um
% SM405 NA=0.12 Rad=62.5um
% 460HP NA=0.13 Rad=62.5um
% Multi-mode fibers (wider wavelength selectivity)
% FP200EMT LowOH NA=0.39 Rad=100um
% FP200ERT LowOH NA=0.50 Rad=100um

if length(fiber_parms)==2, fiber_parms(3)=11.2; end;

n_tissue=1.36;	% refraction index of gray matter

% S - Scatter coefficient per unit thickness
% Slices used to calculate this in rats and mice for 473nm
% 11.2 mm^-1 for mice and 10.3 mm^-1 for rats

rad=fiber_parms(1);
NA=fiber_parms(2);
S=fiber_parms(3);

theta_div = asin(NA/n_tissue);
rho = rad*sqrt( (n_tissue/NA).^2 - 1);
T = 1./( S.*z + 1 );
I = rho.^2 ./ ((S.*z + 1).*(z + rho).^2);

if nargout==1,
  str.z=z;
  str.S=S;
  str.NA=NA;
  str.rad=rad;
  str.I=I;
  str.T=T;
  clear I T
  I=str;
end;

%Ix = zeros(size(x));
%Ix(find(abs(x)<rad)) = 1;

if nargout==0,
  subplot(211), plot(z,I)
  subplot(212), plot(z,T)
end;

