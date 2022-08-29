function x=einsteinwalk(x0,l,R)
% Usage ... x=einsteinwalk(x0,l,R)

% This function executes a random walk experiment as presented
% by Einstein. A particle is at position x0 (3-D vector) and after
% time tau (need not to be specified) it jumps to a new position
% x where the jump is of size l. The direction of the jump is random
% determined by either R=[theta phi] or a single value where R would
% be the seed of a uniform random number generator 0-to-2pi, or if
% not provided then R will just call the random # gen without a set
% seed 

% xm = l sqrt(1.5 n_jumps / pi) = sqrt(6Dt)
% xn = sqrt(4*pi*D*t)

if nargin<3,
  R=rand(2)*2*pi;
end;

if length(R)==1,
  rand('seed',R);
  R=rand(2)*2*pi;
end;

if length(x0)==1,
  if R(1)>pi, x1=+1; else, x1=-1; end;
elseif length(x0)==2,
  x1=[cos(R(1)) sin(R(1))];
else,
  x1=[cos(R(1)) sin(R(1)) sin(R(2))];
end;

x=x0+l*x1;


