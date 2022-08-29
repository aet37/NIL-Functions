function [f,g]=my_linterpolate1(x,y,xs,order)
% Usage ... [f,g]=my_linterpolate1(x,y,xs,order)
%
% Finds the linearly interpolated value of
% xs (f=ys).
% g - contains a value of the success of the
% procedure (inside/outside of x - 0/1).

x=x(:)';
y=y(:)';

if (length(x)~=length(y)),
  error('Mismatching lengths in vectors x and y!');
end;
if (order>=2*length(x)),
  error('Order is too large');
end;

found_before=0; i=1; indx=0;
while (~found_before),
  if (i>=length(x)),
    break;
  elseif ((x(i)<=xs)&(x(i+1)>xs)),
    found_before=1;
    indx=i;
    break;
  end;
  i=i+1;
  if (x(i)==xs),
    indx=i;
    found_before=1;
    break;
  end;
end;

if (~indx),
  error('Value to interpolate lies out of bounds');
end;

if (indx==1),
  pt=y(1);
elseif (indx==x(length(x))),
  pt=y(length(y));
else,
  pt=((y(indx+1)-y(indx))/(x(indx+1)-x(indx)))*(xs-x(indx))+y(indx);
end;

if ((indx-order)<0),
  f=mean([y(1:indx+order) pt]);
elseif ((length(x)-indx-order)<0),
  f=mean([y(indx-order+1:length(x)) pt]);
else,
  f=mean([y(indx-order+1:indx+order) pt]);
end;

g=0;

%if (indx>0),
%  g=0;
%  f=((y(indx+1)-y(indx))/(x(indx+1)-x(indx)))*(xs-x(indx))+y(indx);
%else,
%  if (xs<=x(1)),
%    g=1;
%    f=((y(2)-y(1))/(x(2)-x(1)))*(xs-x(1))+y(1);
%  elseif (xs>=x(length(x))),
%    if (xs==x(length(x))) g=0; else g=1; end;
%    f=((y(length(y))-y(length(y)-1))/(x(length(x))-x(length(x)-1)))*(xs-x(length(x)))+y(length(y));
%  else,
%    f=0;
%  end;
%end;
%if ((size(f,1)~=1)&(size(f,2)~=1))
%  error('Invalid f value!');
%end;
