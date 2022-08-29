function [l1,l2]=matchpix(pix1,pix2)
% Usage ... [l1,l2]=matchpix(pix1,pix2)

cnt=1;
for m=1:size(pix1,1),
  found1=0;
  for n=1:size(pix2,1),
    if ((pix1(m,1)==pix2(n,1))&(pix1(m,2)==pix2(n,2))&(~found1))
      found1=1;
      l1(cnt)=m;
      l2(cnt)=n;
      cnt=cnt+1;
    end;
  end;
end;

if (nargout==0),
  l1,
  l2,
end;

