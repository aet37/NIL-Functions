function [g,h,f]=mysplot(order,vector,extra)
% Usage ... [g,h,f]=mysplot(order,vector,extra)
% f - gain
% g - zeros
% h - poles

if nargin==3,
  olen=length(order);
  [vr,vc]=size(vector);

  if order(1)==0,
    num=vector(1);
    den=vector(2:length(vector));
  elseif order(2)==0,
    num=vector(1:length(vector)-1);
    den=vector(length(vector));
  else,
    num=vector(1:1+order(1));
    den=vector(2+order(1):2+order(1)+order(2));
  end;
elseif nargin==2,
  num=order;
  den=vector;
elseif nargin==1,
  num=order;
  den=1;  
end;

f=den(1);
den=den./f;
num=num./f;

g=roots(num);
h=roots(den);

plot(real(g),imag(g),'o',real(h),imag(h),'x');
title('Pole-Zero Plot in S-plane')
xlabel('Real Axis')
ylabel('Imaginary Axis')
grid
