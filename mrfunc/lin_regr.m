function f=lin_regr(y,x,range)
% Usage ... f=lin_regr(y,x,range)
%
% Linear regression of the vector x or
% matrix x (data in columns) about the
% entire range or the range specified.
% Several ranges may be used.

[xr,xc]=size(x);
rlen=length(range);

if nargin<=2,
  range=[1 xc];
end;

nr=floor(length(range)/2);

for k=1:xc,
  sum=0;
  sumx=0;
  sumy=0;
  sumxy=0;
  sumx2=0;
  b1=0;
  b0=0;
  dline=0;
  for m=1:nr,
    for n=range(2*m-1):range(2*m),
	  sum=sum+1;
      sumx=sumx+x(n);
	  sumy=sumy+y(n,k);
	  sumxy=sumxy+y(n,k)*x(n);
	  sumx2=sumx2+x(n)*x(n);
	end;
  end;
  b1=(sum*sumxy-sumx*sumy)/(n*sumx2-sumx*sumx);
  b0=(sumy-b1*sumx)/sum;
  dline=b1*x+b0;
  f(:,k)=y(:,k)-dline';
end;
