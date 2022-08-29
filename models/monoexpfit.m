function y=monoexpfit(x,t,z)

A=x(3);
B=x(1);
C=x(2);

y=A+B*exp(-t./C);

if nargin==3,
  y=z-y;
end;

