function y=mkMaskReg(im,w,h,off)
% Usage ... y=imMaskReg(im,w,h,off)
%
% Makes mask_reg triangle regions
%
% ex. mask_reg=mkMaskReg(avgim_raw,14,20,10);
%     mask_reg=mkMaskReg(avgim_raw,20,24,4);

imsz=size(im(:,:,1));

if nargin==1,
  w=round(imsz(1)*0.07);
  h=round(imsz(2)*0.08);
  off=ceil(w*0.5);
end;

y=roipoly(im,off+[1 1 w],off+[1 h 1]);
y=y|roipoly(im,imsz(2)-off-[1 1 w],imsz(1)-off-[1 h 1]);
y=y|roipoly(im,off+[1 1 w],imsz(1)-off-[1 h 1]);
y=y|roipoly(im,imsz(2)-off-[1 1 w],off+[1 h 1]);
y=bwlabel(y>0);
