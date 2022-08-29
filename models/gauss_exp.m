function [y,dyda]=gauss_exp(t,a)
% Usage ... [y,dyda]=gauss_exp(t,a)
%
% Exponential Guassian Model

y=a(1)*exp(-1*(t-a(2))*(t-a(2))/(2*a(3)*a(3)));

dyda(1)=exp(-1*(t-a(2))*(t-a(2))/(2*a(3)*a(3)));
dyda(2)=a(1)*(t-a(2))*(1/(a(3)*a(3)))*exp(-1*(t-a(2))*(t-a(2))/(2*a(3)*a(3)));
dyda(3)=a(1)*(t-a(2))*(t-a(2))*(1/(a(3)*a(3)*a(3)))*exp(-1*(t-a(2))*(t-a(2))/(2*a(3)*a(3)));

