function y=sinc(x)
% Usage y=sinc(x)
%
% y=sinc(pi*x)/pi*x

if (length(x)==1),
  if x==0,
    y=1;
  else,
    y=sin(pi*x)/(pi*x);
  end;
else,
  y=zeros(size(x));
  y(find(x==0))=1;
  ii=find(x~=0);
  y(ii)=sin(pi*x(ii))./(pi*x(ii));
end;

y(find(abs(y)<10*eps))=0;

