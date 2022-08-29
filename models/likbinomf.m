function f=likbinomf(x,n)
% Usage ... f=likbinomf(x,n)

[nthr,MM]=size(n);
M=MM-1;

nx=nthr*2+1;
if (nx~=length(x)),
  warning('Unexpected number of parameters!');
end;

l=x(1);
for k=1:nthr,
  pa=x(2*k);
  pi=x(2*k+1);
  L(k)=likbinom([pa pi l],n(k,:),M);
end;

f=sum(L);

