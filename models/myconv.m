function f=myconv(a,b,do_bnorm)
% Usage ... f=myconv(a,b)
% Same as conv but f will be the same siz as the size of a 
% If a is a matrix, it will return the conv of columns of a with b

if nargin<3, do_bnorm=0; end;

if do_bnorm, b=b/sum(b); end;

if prod(size(a))==length(a),
  tmp=conv(a,b);
  %for n=1:length(a), f(n)=tmp(n); end;
  f=tmp(1:length(a));
else,
  for mm=1:size(a,2),
    tmp=conv(a(:,mm),b(:));
    f(:,mm)=tmp(1:length(b));
  end;
end;

