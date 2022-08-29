function mask=glinemask(im)
% Usage ... mask=glinemask(im)

imsize=size(im);
show(im)
pix=round(ginput);

mask=zeros(size(im));
pixc=[pix(:,2) pix(:,1)];
for mm=2:size(pixc,1),
  mask=mask|line2d(pixc(mm-1,1),pixc(mm-1,2),pixc(mm,1),pixc(mm,2),imsize(1),imsize(2));
end;
mask=mask|line2d(pixc(mm,1),pixc(mm,2),pixc(1,1),pixc(1,2),imsize(1),imsize(2));

mask_line=mask;
show(mask_line), pause,

mask=imfill(mask,'holes');

