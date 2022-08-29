function z=vol_super(x,y,a,b)
% Usage ... z=vol_super(x,y,a,b)
%
% Generates a new image z=a*x+b*y
% If y is binary it calculates the necessary
% factor to produce the superposition.

if nargin<4,
  b=1;
end;

rangex=mean(max(max(x)))-mean(min(min(x)));
rangey=mean(max(max(y)))-mean(min(min(y)));

%if (rangey<=b),
  % Binary image in y
  z=x+rangex*a*y;
%else,
%  % Otherwise
%  z=a*x+b*y;
%end;

