function [f1,f2]=alt_tc(x,opt)
% Usage ... [f1,f2]=alt_tc(x)
%
% Separates the the columns of x into
% alternating rows with the same number
% of columns to f1 and f2.

[xr,xc]=size(x);

for m=1:xc, for n=1:xr/2,
  f1(n,m)=x(2*n-1,m);
  f2(n,m)=x(2*n,m);
end; end;

if nargin==2,
  if opt==2, f1=f2; else, f1=f1; end;
end;

