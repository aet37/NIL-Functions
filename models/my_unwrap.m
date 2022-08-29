function f=my_unwrap(x)
% Usage ... f=my_unwrap(x)
%
% Unwraps excess angle.

f=x;

for n=2:length(x),
  if ((x(n)-x(n-1))<(-1*pi)),
    for m=n:length(x), f(m)=f(m)+2*pi; end;
  elseif ((x(n)-x(n-1))>pi),
    for m=n:length(x), f(m)=f(m)-2*pi; end;
  end;
end;
