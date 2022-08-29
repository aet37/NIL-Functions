function y=myangle(x)
% Usage ... y=myangle(x)

if (~isreal(x)),
  x=angle(x);
end;

y=x+2*pi*(x<0)-pi;

if (nargout==0)
  show(y)
  clear y
end;

