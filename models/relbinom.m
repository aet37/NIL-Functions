function [f,g]=relbinom(x,m,M,N,data)
% Usage ... [f,g]=relbinom(x,m,M,N,data)
%
% x = [pa pi lambder]

pa=x(1);
pi=x(2);
l=x(3);

% constraints of these parameters:  0 >= pa,pi,l >= 1

b1 = factorial(M) / ( factorial(m)*factorial(M-m) );

En = N*l*b1*(pa^m)*((1-pa)^(M-m));
En = En + N*(1-l)*b1*(pi^m)*((1-pi)^(M-m));

dEdpa = N*l*b1*( m*(pa^(m-1))*((1-pa)^(M-m)) - (pa^m)*(M-m)*((1-pa)^(M-m-1)) );
dEdpi = N*(1-l)*b1*( m*(pi^(m-1))*((1-pi)^(M-m)) - (pi^m)*(M-m)*((1-pi)^(M-m-1)) );
dEdl = N*b1*(pa^m)*((1-pa)^(M-m)) - N*b1*(pi^m)*((1-pi)^(M-m));

if nargin==5,
  f = ( En - data )^2;
  g = 2*(En-data)*(-1)*[dEdpa dEdpi dEdl];
else,
  f = En;
  g = [dEdpa dEdpi dEdl];
end;

