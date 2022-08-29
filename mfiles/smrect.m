function f=smrect(t,parms,type)
% Usage ... f=smrect(t,parms,type)
%
% Types: 1- sinusoidal ramp, 0- rectangle
%
% Parameters: 1-[f0 w0 t0], 0-[w0 t0]
%

if nargin<3, type=0; end;

if type==1,
  f0=parms(1);
  w0=parms(2);
  t0=parms(3);
  f=zeros(size(t));
  for m=1:length(t),
    if t(m)<t0,
      f(m)=0;
    elseif (t(m)>=t0)&(t(m)<=t0+0.5/f0),
      f(m)=0.5*(1+sin(2*pi*f0*(t(m)-t0)-pi/2));
    elseif (t(m)>t0+0.5/f0)&(t(m)<t0+w0),
      f(m)=1;
    elseif (t(m)>=t0+w0)&(t(m)<=t0+w0+0.5/f0),
      f(m)=0.5*(1+sin(2*pi*f0*(t(m)-t0-w0)+pi/2));
    else,
      f(m)=0;
    end;
  end;
else,
  w0=parms(1);
  t0=parms(2);
  f=rect(t,w0,t0);
end;

if nargout==0,
  plot(t,f)
end;

