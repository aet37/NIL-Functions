function f=gammafun(t,t0,tau,b,amp,type)
% Usage ... f=gammafun(t,t0,tau,b,amp,type)

% There are 2 flavors of gamma functions for BOLD fMRI
% impulse responses being used: 1- b=8.6 t0=2.5 tau=0.55
% 2- b=2.0 t0=2.5 tau=1.25

% The is a numerical error when t0>360s !!!

% taylored to bold hemodynamics
if nargin<6, type=0; end;
if nargin<5, amp=1.0; end;
if nargin<4, b=8.60; end;
if nargin<3, tau=0.55; end;
if nargin<2, t0=2.00; end;

t=t(:);
ii=find(t>=t0);
if isempty(ii), f=zeros(size(t)); return; end;

if type==2,
  f(ii)=((t(ii)-t0)./tau).^b;
  f(ii)=f(ii).*exp(-(t(ii)-t0)./tau);
  f=f.*((t-t0)>=0);
elseif type==1,
  f(ii)=((t(ii)-t0).^b);
  f(ii)=f(ii).*exp(-(t(ii)-t0)./tau);
  f=f.*((t-t0)>=0);
elseif type==3,
  al=1;
  f(ii)=((t(ii)-t0)/b).^al;
  f(ii)=f(ii).*exp(-(t(ii)-t0-b)/tau);	% exp(-(t-t0)-b/tau)
  f=f.*((t-t0)>=0);
elseif type==4,
  a=tau;
  f(ii)=(t(ii)-t0).^a;   % a/b=mean or expectation or MTT, sqrt(a)/b=std or sqrt(a+1)/b
  f(find((t-t0)<0))=0;
  f(ii)=f(ii).*exp(-(t(ii)-t0)*b);    
else,                     % assumes an ordered time vector, mtt=b*tau, cth=sqrt(tau)*b
  tmp=find(t>=t0);
  if isempty(tmp), tmp=1; end;
  tt=t(tmp(1):length(t));
  nt=t(1:tmp(1)-1);
  ff=(((tt-t0).^b).*exp(-(tt-t0)./tau));
  f=[zeros(size(nt));ff];
end;

if max(f)>0,
  f=amp*f./max(f);
end;

