function y=mkquadrant2im(x,ngrid)
% Usage ... y=mkquadrant2im(x,ngrid)

y=zeros(size(x,1)*ngrid(1),size(x,2)*ngrid(2));

xx=size(x,1);
yy=size(x,2);

cnt=0;
for mm=1:ngrid(1),
  for nn=1:ngrid(2),
    cnt=cnt+1;
    y((mm-1)*xx+1:mm*xx,(nn-1)*yy+1:nn*yy)=x(:,:,cnt);
  end;
end;

if (nargout==0),
  show(y)
  clear y
end;

