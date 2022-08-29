function [t,v]=pool_t(x,y)
% Usage ... [t,v]=pool_t(x,y)
%
% Calculates the pooled t-test for the samples x and y.
% It returns the t-value and the degrees of freedom.

sx=std(x);
sy=std(y);
mx=mean(x);
my=mean(y);
m=length(x);
n=length(y);

t=(mx-my)/sqrt((sx*sx/m)+(sy*sy/n)),
v=(((sx*sx/m)+(sy*sy/n))^2)/((((sx*sx/m)^2)/(m-1))+(((sy*sy/n)^2)/(n-1))),
v=ceil(v);
