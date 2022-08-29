function ydot=fom1on(t,y)
% First order model #1

% Parameters
input=1;
a=1;
b=2;
c=1;
tau=5;
shp=10;
theta=0.25;

ydot(1)= input - a*y(1) - b*y(2);
ydot(2)= ( (1/(1+exp(-shp*(y(1)-theta)))) - c*y(2) )/tau;
