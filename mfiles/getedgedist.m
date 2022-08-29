function [y,pix3]=getedgedist(edgeim,mask)
% Usage ... [y,midpix]=getedgedist(edgeim,mask)
%

im2=edgeim.*mask;
[dd,ll]=bwdist(im2);
ww=watershed(dd);
im3=(~ww).*mask;
pix3=getimpix2(im3);
y=getimpixval(dd,pix3);

if (nargout==0)
  show(im_super(im2,im3,1))
  title(sprintf('Mean= %f (%f s.d.)',mean(y),std(y)))
end;

