function [f,g]=isgrdiff_te(vel,ga)
% Usage ... [w,dg]=isgrdiff_te(vel,ga)
%
% Calculates the minimum TE to use with
% isgr3D2 for the flow_spoil velocity vel
% in mm/s.

if nargin<2, 
  ga=1;  % G/cm
end;

gamma_h=26751;
anticipate=5000; % Approximate duration of refocus
threshold=11000;  % TE duration into EPI train
quiet=2000;       % Quiet time of no gradients before EPI train

pw_fc=1000000*sqrt(4.0*pi/(gamma_h*ga*0.1*vel));
pw_fc=pw_fc-rem(pw_fc,4);

f=2*(700+pw_fc+700)+anticipate+threshold+quiet;
g=[700;pw_fc;700];

if nargout==0,
  disp(['Min TE= ',int2str(f)]);
  disp(['Diff Grad PW= ',int2str(pw_fc),' 700 700']);
end;
