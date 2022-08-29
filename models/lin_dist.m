function f=lin_dist(u,m,b)
% Usage... f=lin_dist(u,m,b)
%
% Generates a linear distribution (or trapezoidal) with
% slope and y-intercept m and b 
% The x-axis is fixed between 0 and 1

x=[0:1e-3:1];
y=m*x+b;
y=y./trapz(x,y);

f=ran_dist([x(:) y(:)],u);

