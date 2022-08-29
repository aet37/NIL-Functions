function y=myttest(a,b)
% Usage ... y=myttest(a,b)
%
% a can be a vector or matrix, b is the mean to test against
% it may be a number or vector (if a is a matrix)

if iscell(a),
  if nargin==1, b=zeros(1,length(a)); end;
  for mm=1:length(a),
    am(mm)=a{mm}(1);
    as(mm)=a{mm}(2);
    an(mm)=a{mm}(3);
  end;
else,
  if length(a)==prod(size(a)), a=a(:); end;
  if nargin<2, b=zeros(1,size(a,2)); end;

  am=mean(a,2);
  as=std(a,[],2);
  an=size(a,1);
end;

t=(am-b)./(as./sqrt(an));

for mm=1:length(t), pval(mm)=1-tcdf(abs(t(mm)),an(mm)-1); end;
%for mm=1:length(t), pval(mm)=1-tcdf(t(mm),an(mm)-1); end;

y.x=a;
y.x1=b;
y.t=t;
y.p=pval;

