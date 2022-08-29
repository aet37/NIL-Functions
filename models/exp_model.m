function [y,dyda]=exp_model(t,a)
% Usage ... [y,dyda]=exp_model(t,parms)
%
% Exponential model (test to be used with lm1).

y=a(1)*exp(-0.5*(t-a(2))*(t-a(2))/(a(3)*a(3)));

dyda(1)=exp(-0.5*(t-a(2))*(t-a(2))/(a(3)*a(3)));
dyda(2)=a(1)*(t-a(2))*(1/(a(3)*a(3)))*dyda(1);
dyda(3)=(t-a(2))*(1/a(3))*dyda(2);

