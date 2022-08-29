function y=mtrap1(t,tstart,fwhm,slope,amplitude,delay)
% Usage .... y=mtrap1(t,tstart,fwhm,slope,amplitude,delay)
%
% Returns a scalar quantity for the value of a
% trapeziod described by the input parameter list.

if nargin<6,
  delay=0;
end;

half_mlength=(amplitude/2)/slope;

if ((t<(tstart+delay))|(t>(tstart+delay+2*half_mlength+fwhm))),
  y=0;
elseif ((t>=(tstart+delay+2*half_mlength))&(t<=(tstart+delay+fwhm))),
  y=amplitude;
elseif (t<(tstart+delay+2*half_mlength)),
  y=slope*(t-tstart-delay);
elseif (t>(tstart+delay+fwhm)),
  y=slope*(t-tstart-delay-fwhm);
  y=amplitude-y;
else,
  disp('Warning: Assigned value of amplitude to mtrap1');
  y=amplitude;
end;
