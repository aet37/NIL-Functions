function f=gammafun2(t,t0,tau,b,amp,type)
% Usage ... f=gammafun2(t,t0,tau,b,amp,type)
%
% There are 2 flavors of gamma functions for BOLD fMRI
% 1- b=8.6 t0=2.5 tau=0.55
% 2- b=2.0 t0=2.5 tau=1.25
%
% For Spike-to-GCaMP we can use:
%   gcamp_irf=gammafun2(tt,tt(1),0.2,1.2)

% The is a numerical error when t0>360s !!!

% taylored to bold hemodynamics
if nargin<6, type=0; end;
if nargin<5, amp=1.0; end;
if nargin<4, b=2.00; end;
if nargin<3, tau=1.25; end;
if nargin<2, t0=2.00; end;

t=t(:);
f=0;

for mm=1:length(t0),
if type==1,
  ff=((t-t0(mm))./tau).^b;
  ff=ff.*exp(-(t-t0(mm))./tau);
  ff=ff.*((t-t0(mm))>=0);
elseif type==2,
  ff=((t-t0(mm)).^b);
  ff=ff.*exp(-(t-t0(mm))./tau);
  ff=ff.*((t-t0(mm))>=0);
else,                     % assumes an ordered time vector
  tmp=find(t>=t0(mm));
  tt=t(tmp(1):length(t));
  nt=t(1:tmp(1)-1);
  arg=(tt(:)-t0(mm))./tau;
  ff=(arg.^b).*exp(-arg);
  ff=[zeros(size(nt(:)));ff];
end;
f=ff+f;
%plot(t,ff),drawnow,pause,
end;

if max(f)>0,
  f=amp*f./max(f);
end;

