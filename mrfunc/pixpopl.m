function [common,uncommon]=pixpopl(pix1,pix2,common)
% Usage ... f=pixpopl(pix1,pix2,common)
%           common=1 uncommon=0
% The comparisons are based on pix1

if nargin<3,
  common=1;
end;

mm=1; nn=1;
for m=1:size(pix1,1),
  found=0;
  for n=1:size(pix2,1),
    if ((~found)&(pix1(m,1)==pix2(n,1))&(pix1(m,2)==pix2(n,2))),
      clist(mm)=m;
      found=1;
      mm=mm+1;
    end;
  end;
  if (~found),
    ulist(nn)=m;
    nn=nn+1;
  end;
end;

if (mm==1), warning('No commmon pixels found'); end;
if (nn==1), warning('No un-commmon pixels found'); end;

if (common),
  common=pix1(clist,:);
  uncommon=pix1(ulist,:);
else,
  common=pix1(ulist,:);
  uncommon=pix1(clist,:);
end;

