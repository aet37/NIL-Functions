function [t,v]=pair_t(x,y)
% Usage ... [t,v]=pair_t(x,y)
%
% Calculates the paired t-test for data sets x and y.
% It returns the t-value and the degrees of freedom.

d=x-y;
md=mean(d);
sd=std(d);
n=length(d);

t=sqrt(n)*md/sd,
v=n-1,
