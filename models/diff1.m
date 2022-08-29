function [n,dndt,dcdx]=diff1(t,x,D,A,c0,t_tol)
% Usage ... [n,dndt,dcdx]=diff1(t,x,D,A,c0,tol)
%
% Units: t (s), x (cm), D (cm2/s), A (cm2), c0 (nparts/cm3), tol (s)

% Problem at t=0... need to solve or look into...
% no problem at x=0 

if nargin<6, t_tol=1e-6; end;	% 1e-6 s
if nargin<5, c0=1; end;		% 1 part/cm3
if nargin<4, A=1; end;		% 1 cm2
if nargin<3, D=1e-5; end;	% 1 cm2/s (water@25C)

tau=[t_tol:t_tol:t];

dcdx = c0 ./ (( 4*pi*D*tau ).^(0.5) );
dcdx = dcdx .* exp( -(x*x) ./ (4*pi*D*tau) );
%dcdx(1) = D*A;

dndt = D*A*dcdx;

n=trapz(tau,dndt);

