function im=mkorthim(im1,im2,im3)
% Usage ... im=mkorthim(im1,im2,im3)

s1=size(im1);
s2=size(im2);
s3=size(im3);

g1=round(0.1*s1(2));
g2=round(0.1*s1(1));

im=im1;
im=[im zeros(s1(1),g1) im2];

ss=size(im);
im=[im;zeros(g2,ss(2))];
im=[im;[im3 zeros(s3(1),ss(2)-s3(2))]];

