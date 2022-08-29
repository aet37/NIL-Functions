function [y,mask]=mkquadrants(x,grsize)
% Usage ... [y,mask]=mkquadrants(x,grsize)

if (nargin==1),
  if ((size(x,1)>128)|(size(x,2)>128)),
    grsize(1)=ceil(size(x,1)/64);
    grsize(2)=ceil(size(x,2)/64);
  else,
    grsize=[2 2];
    if (size(x,1)<2), grsize(1)=1; end;
    if (size(x,2)<2), grsize(2)=1; end;
  end;
  disp(sprintf(' nx= %d  ny= %d',grsize(1),grsize(2)));
end;

xdim=size(x);
xx=round(xdim(1)/grsize(1));
yy=round(xdim(2)/grsize(2));

if (rem(size(x,1),grsize(1)))|(rem(size(x,2),grsize(2))),
  disp('Warning: Check sizes');
end;

cnt=0;
for mm=1:grsize(1),
  for nn=1:grsize(2),
    cnt=cnt+1;
    y(:,:,cnt)=x((mm-1)*xx+1:mm*xx,(nn-1)*yy+1:nn*yy);
    mask(:,:,cnt)=logical(tri2d(xx,yy,(mm-1)*xx+1,(nn-1)*yy+1,size(x,1),size(x,2),0));
  end;
end;

