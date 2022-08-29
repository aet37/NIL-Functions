function [y,m,s]=mynorm2(x)
% Usage ... [y,m,s]=mynorm2(x)
%
% rescales vectors in x so they are N(0,1)
% returns these values

if prod(size(x))==length(x),
  m=mean(x);
  s=std(x);
  y=x-m;
  y=s*y/max(y);
else,
  y=zeros(size(x));
  for mm=1:size(x,2),
    m(mm)=mean(x(:,mm));
    s(mm)=std(x(:,mm));
    y(:,mm)=x(:,mm)-m(mm);
    y(:,mm)=y(:,mm)*s(mm)/max(y(:,mm));
  end;
end;

