function f=myrevert(old)
% Usage ... f=myrevert(old)
% Reverts every column

[or,oc]=size(old);
for n=1:or,
  tmp(n,:)=old(or-n+1,:);
end;
f=tmp;