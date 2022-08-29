function [y,dyda]=exp_model(t,a,ap)
% Usage ... [y,dyda]=exp_model(t,parms,parms_prev)
%
% Exponential model (test to be used with lm1).

for m=1:length(t),
  y(m)=a(1)*exp(-0.5*(t(m)-a(2))*(t(m)-a(2))/(a(3)*a(3)));
end;

if nargin>2,
  aa=[ap(1) a(2) a(3)];
  for m=1:length(t),
    yy(m)=aa(1)*exp(-0.5*(t(m)-aa(2))*(t(m)-aa(2))/(aa(3)*aa(3)));
    dyda(1,m)=(yy(m)-y(m))/(aa(1)-a(1));
  end;
  aa=[a(1) ap(2) a(3)];
  for m=1:length(t),
    yy(m)=aa(1)*exp(-0.5*(t(m)-aa(2))*(t(m)-aa(2))/(aa(3)*aa(3)));
    dyda(2,m)=(yy(m)-y(m))/(aa(2)-a(2));
  end;
  aa=[a(1) a(2) ap(3)];
  for m=1:length(t),
    yy(m)=aa(1)*exp(-0.5*(t(m)-aa(2))*(t(m)-aa(2))/(aa(3)*aa(3)));
    dyda(3,m)=(yy(m)-y(m))/(aa(3)-a(3));
  end;
else,
  for m=1:length(t),
    y(m)=a(1)*exp(-0.5*(t(m)-a(2))*(t(m)-a(2))/(a(3)*a(3)));

    dyda(1,m)=exp(-0.5*(t(m)-a(2))*(t(m)-a(2))/(a(3)*a(3)));
    dyda(2,m)=a(1)*(t(m)-a(2))*(1/(a(3)*a(3)))*dyda(1,m);
    dyda(3,m)=(t(m)-a(2))*(1/a(3))*dyda(2,m);
  end;
end;
