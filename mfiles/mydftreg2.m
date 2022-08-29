function [yy]=mydftreg2(im1,im2,parms)
% Usage ... [y]=mydftreg2(im1,im2,parms)

if nargin<3, parms=[]; end;
if isempty(parms), parms=[0 4]; end;

smw=parms(1);
nn=parms(2);

if smw>0,
    im1=im_smooth(im1,smw);
    im2=im_smooth(im2,smw);
end

im1ft=fftshift(fft2(im1));
im2ft=fftshift(fft2(im2));

[tmpi1,tmpj1]=find(abs(im1ft)==max(abs(im1ft(:))));
[tmpi2,tmpj2]=find(abs(im2ft)==max(abs(im2ft(:))));

n1=-nn;
tmpr1=diff([angle(im1ft(tmpi1(1)+[n1:nn],tmpj1(1)))-angle(im2ft(tmpi1(1)+[n1:nn],tmpj1(1)))])*(size(im1ft,1)/(2*pi));
tmpc1=diff([angle(im1ft(tmpi1(1),tmpj1(1)+[n1:nn]))-angle(im2ft(tmpi1(1),tmpj1(1)+[n1:nn]))])*(size(im1ft,2)/(2*pi));
tmpr2=diff([angle(im1ft(tmpi2(1)+[n1:nn],tmpj2(1)))-angle(im2ft(tmpi2(1)+[n1:nn],tmpj2(1)))])*(size(im2ft,1)/(2*pi));
tmpc2=diff([angle(im1ft(tmpi2(1),tmpj2(1)+[n1:nn]))-angle(im2ft(tmpi2(1),tmpj2(1)+[n1:nn]))])*(size(im2ft,2)/(2*pi));

tmpii=find(abs(tmpr1)>0.5*size(im1,1));
if ~isempty(tmpii), tmpr1(tmpii)=tmpr1(tmpii)-sign(tmpr1(tmpii))*size(im1,1); end
tmpii=find(abs(tmpc1)>0.5*size(im1,2));
if ~isempty(tmpii), tmpc1(tmpii)=tmpc1(tmpii)-sign(tmpc1(tmpii))*size(im1,2); end
tmpii=find(abs(tmpr2)>0.5*size(im2,1));
if ~isempty(tmpii), tmpr2(tmpii)=tmpr2(tmpii)-sign(tmpr2(tmpii))*size(im2,1); end
tmpii=find(abs(tmpc2)>0.5*size(im2,2));
if ~isempty(tmpii), tmpc2(tmpii)=tmpc2(tmpii)-sign(tmpc2(tmpii))*size(im2,2); end

[tmpr1 tmpc1' tmpr2 tmpc2'],

tmpr1=mean(tmpr1);
tmpc1=mean(tmpc1);
tmpr2=mean(tmpr2);
tmpc2=mean(tmpc2);

yy=[tmpr1 tmpc1];

