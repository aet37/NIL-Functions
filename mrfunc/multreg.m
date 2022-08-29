function [d,yhat,T,F]=multreg(x,y)
% Usage ... [d,yhat,T,F]=multreg(x,y)
%
% x - Data must be organized in columns
% y - must be vector

y=y(:)';
[xr,xc]=size(x);
if (xr>xc) x=x'; end;

x=[ones([1 length(x)]);x];
[xr,xc]=size(x);

A=x*x';

for m=1:xr,
  b(m)=sum(y.*x(m,:));
end;
b=b(:);

d=inv(A)*b;

yhat=zeros([1 xc]);
for m=1:xr,
  yhat=yhat+d(m)*x(m,:);
end;

sst=sum((y-yhat).^2); 
sse=(-1)*(b'*d)+sum(y.^2); 
R2=1-sse/sst; 
S2=sse/(length(y)-xr-1);
T=(d-0).*(1/S2);
F=(R2/xr)./((1-R2)./(length(y)-xr-1));
