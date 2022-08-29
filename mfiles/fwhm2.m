function y=fwhm2(im,loc,parms)
% Usage ... y=fwhm2(im,loc,parms)
%
% loc is the [row1 col1 row2 col2] for a line

if nargin<3, parms=[]; end;

im_orig=im;
loc_orig=loc;

imsz=size(im);

dy=loc(4)-loc(2);
dx=loc(3)-loc(1);

transp_flag=0;
% i think the problem is the orientation
% this < or > and transposing
if (dy<dx), 
    transp_flag=1;
    im=im'; 
    imsz=size(im);
    loc=[loc(2) loc(1) loc(4) loc(3)];
    dy=loc(4)-loc(2);
    dx=loc(3)-loc(1);
else
    %im=im';
end;

[xx,yy]=meshgrid([1:imsz(1)],[1:imsz(2)]');

tmpm=dy/dx;
tmpb=loc(2)-tmpm*loc(1);

xl=[loc(1):loc(3)];
yl=tmpm*xl + tmpb;

yline=interp2(xx,yy,im,xl,yl);

fwhm=fwhm1(yline(:),parms);

mask=zeros(size(im));
for mm=1:length(yline),
  mask(round(xl(mm)),round(yl(mm)))=1;
end;

if transp_flag,
    mask=mask';
end

if nargout==0,
    subplot(221), show(im),
    subplot(222), im_overlay4(im,mask)
    subplot(223), plot(yline)
end

    