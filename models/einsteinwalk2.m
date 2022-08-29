function x=einsteinwalk(x0,l,R,p)
% Usage ... x=einsteinwalk(x0,l,R,p)

% This function executes a random walk experiment as presented
% by Einstein. A particle is at position x0 (3-D vector) and after
% time tau (need not to be specified) it jumps to a new position
% x where the jump is of size l. The direction of the jump is random
% determined by either R=[theta phi] or a single value where R would
% be the seed of a uniform random number generator 0-to-2pi, or if
% not provided then R will just call the random # gen without a set
% seed 

if nargin<4,
  p=[1 1 1]*0.5;
end;

if nargin<3,
  R=rand(1,3);
end;

if length(R)==1,
  rand('seed',R);
  R=rand(1,3);
end;

if length(l)==1,
  l=[1 1 1]*l;
end;

if length(x0)==1,
  if R(1)>p(1), x1=+1; else, x1=-1; end;
else,
  x1=2*(double(R>p)-0.5);
end;

x=x0+l.*x1;


