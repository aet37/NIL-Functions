function y=power1(p,x,data)
% Usage ... y=power(p,x,data)
%
% p = power
%

y=exp(-p(1)*x);
%keyboard,

if nargin==3,
  z=sum((y-data).^2);
  if nargout==0,
    plot(x,data,x,y)
  end;
  y=z;
  disp(sprintf('  p= %.4f  z= %.4f',p,z));
end;

