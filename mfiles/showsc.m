function a=showsc(im,wlev)

if (nargin>1)
  im2=imwlevel(im,wlev);
else,
  im2=im;
end;

imagesc(im2)
axis('image')
title(sprintf('min/max= %f/%f',min(min(im2)),max(max(im2))))

