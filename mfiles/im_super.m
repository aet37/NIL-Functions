function z=im_super(x,y,a,b)
% Usage ... z=im_super(x,y,a,b)
%
% Generates a new image z=a*x+b*y
% If y is binary it calculates the necessary
% factor to produce the superposition.

if nargin<4,
  b=1;
end;

rangex=max(max(x))-min(min(x));
rangey=max(max(y))-min(min(y));

%if (rangey<=b),
  % Binary image in y
  z=x+rangex*a*y;
%else,
%  % Otherwise
%  z=a*x+b*y;
%end;

