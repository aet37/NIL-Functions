function [f,g,E]=relfmrif(x,data,lambda)

[nthr,MM]=size(data);	% data is N0 N1 N2 ... NM x nthr-rows
M=MM-1;

nx=2*nthr+1;		% each thr has a pa, pi and all share lambda
if (length(x)~=nx),
  warning('Size of parameters to fit may not match data!');
end;

kk=0;
if nargin<3, 
  l=x(1); oo=0;
  nx=2*nthr+1;
else,
  l=lambda; oo=-1;
  nx=2*nthr;
end;

if (length(x)~=nx),
  warning('Size of parameters to fit may not match data!');
end;

for k=1:nthr,
  pa=x(2*k+oo);
  pi=x(2*k+1+oo);
  N=sum(data(k,:));
  for m=0:M,
    [R(k,m+1),dR(:,k,m+1)]=relbinom([pa pi l],m,M,N,data(k,m+1));
    E(k,m+1)=relbinom([pa pi l],m,M,N);
    kk=kk+1;
    % calculation of the penalty so that each entry is equally
    % weighted in the calculation
    if (m==0), 
      pen=0.2;
    else,
      pen=(m+1)*k*k;
      %pen=(m+1)*k*k;
    end;
    %pen=(1-data(k,m+1)/sum(sum(data)))/(prod(size(data))-1);
    f(kk)=R(k,m+1)*pen;
    g(kk,:)=dR(:,k,m+1)';
  end;
end;


