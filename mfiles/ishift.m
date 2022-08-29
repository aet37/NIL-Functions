function g=ishift(f,i)
% Usage ... g=ishift(f,i)
% shift is circular
% i may be positive or negative

flen=length(f);
g=zeros(size(f));

if (i>0)
  for m=1:flen-i,
    g(m+i)=f(m);
  end;
  for m=1:i,
    g(m)=f(flen-i+m);
  end;
elseif (i<0)
  for m=1-i:flen,
    g(m+i)=f(m);
  end;
  for m=1:abs(i),
    g(flen+i-m)=f(m);
  end;
else,
  g=f;
end;

