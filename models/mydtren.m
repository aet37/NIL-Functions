function [f,z,h] = mydtren(lam,t,y,bias,type)
% Usage ... f = mydtren(lam,t,y,bias,type)

t=t(:);
[lr,lc]=size(lam);

if (~exist('bias'))
  bias=[1 length(t)];
end;
if (length(bias)==1)|(length(bias)==3),
if (bias==[0])|(bias==['all'])
  bias=[1 length(t)];
end;
end;

if lr==1,
  y=y(:); h=min(y);
  if min(y)<0, y=y-min(y); end;
  if size(y)~=size(t),
    error('Error: Improper t or y entries!');
  end;
  if (type==1)|(type==11),
    A = zeros(length(t),length(lam));
    for j = 1:size(lam)
       A(:,j) = exp(-lam(j)*t);
    end;
    c = A\y;
    z = A*c;
  elseif (type==2)|(type==22),
    z=0;
    for j=1:2:length(lam),
      z=z+lam(j).*exp(-lam(j+1)*t);
    end;
  end;
  tmp = y-z;
else,
  h=min(y);
  for o=1:lr,
    if min(y(:,o))<0, y(:,o)=y(:,o)-min(y(:,o)); end;
    if (type==1)|(type==11),
      A = zeros(length(t),length(lam));
      for j = 1:size(lam)
         A(:,j) = exp(-lam(o,j)*t);
      end;
      c = A\y;
      z = A*c;
    elseif (type==2)|(type==22),
      z=0;
      for j=1:2:length(lam),
        z=z+lam(o,j).*exp(-lam(o,j+1)*t);
      end;
    end;
    tmp(:,o) = y(:,o)-z;
  end;
end;

if lr==1,
  if length(bias)==4,
    f=[tmp(bias(1):bias(2))' tmp(bias(3):bias(4))']';
  else,
    f=[tmp(bias(1):bias(2))]; 
  end;
end;

plot([1:length(z)],z,[1:length(y)],y,[1:length(y)],y,'o')

if type>9,
  f=tmp;
end;
