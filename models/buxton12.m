function [y,dyda]=buxton12(t,a,ap)
% Usage ... [y,dyda]=buxton12(t,a,aprev)
%
% Balloon modeling at time t and parameters a.
% Uniform time sampling is assummed.

t0=t(1);
tf=t(length(t));
ts=t(2)-t(1);

% Calculate y
data1=buxton1(t0,tf,ts,[1 1],a);

% Calculate dyda numerically and analytically where applicable
aa=a;
for m=1:length(ap),
  aa(m)=ap(m);
  tmpdata=buxton(t0,tf,ts,[1 1],aa);
  dyda(:,m)=(data1(:,2)-tmpdata(:,2))./(a(m)-aa(m));
  aa(m)=a(m);
end; 

