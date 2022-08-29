function f=int_corr(data,ref,tflag)
% Usage ... f=int_corr(data,ref,tflag)
%
% Data is assumed to organized as x,y,t

if nargin<3, tflag=0; end;

imdim=size(data);

meanim=mean(data,3);
meanref=mean(ref);
sumnxx=0;
sumnxy=0;
sumnyy=sum((ref-meanref).*(ref-meanref));
for m=1:imdim(3),
  sumnxx=sumnxx+(data(:,:,m)-meanim).*(data(:,:,m)-meanim);
  sumnxy=sumnxy+(ref(m)-meanref).*(data(:,:,m)-meanim);
end;
den=(sumnxx.^(0.5))*(sumnyy.^(0.5));

for m=1:imdim(1), for n=1:imdim(2),
  if (den(m,n)==0)|(den(m,n)<1e-6),
    f(m,n)=0;
  else,
    f(m,n)=sumnxy(m,n)/den(m,n);
  end;
end; end;

if (tflag),
  t=f*sqrt(240-2)./((1-f.*f).^(0.5));
  f=t;
end;

if nargout==0, show(f'); end;

