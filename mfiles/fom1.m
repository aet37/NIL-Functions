function ydot=fom1(t,y)
% First order model #1

% Parameters
input=1;
fun=1;
tau=5;
a=1;
b=1;
c=1;

ydot(1)= input - a*y(1) - b*y(2);
ydot(2)= ( fun - c*y(2) )/tau;
