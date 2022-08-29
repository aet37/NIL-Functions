function [xnew,xphs]=phscenter(x)
% Usage ... [xnew,xphs]=phscenter(x)
%
% Phase centers x about its mean phase xphs. If x is not complex it
% assumes the phase angle was provided.

if isreal(x),
  cplx_flag=0;
else,
  cplx_flag=1;
end;

if length(x)==prod(size(x)),
  x=x(:).';
end;

for mm=1:size(x,2),
  if (cplx_flag),
    xphs(mm)=angle(sum(x(:,mm)./abs(x(:,mm))));
    xnew(:,mm)=x(:,mm)./exp(j*xphs(mm));
  else,
    xphs(mm)=angle(sum(exp(x(:,mm))));
    xnew(:,mm)=angle(exp(j*(x(:,mm)-xphs(mm))));
  end;
end;


