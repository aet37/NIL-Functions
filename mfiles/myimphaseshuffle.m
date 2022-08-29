function y=myimphaseshuffle(im,bands)
% Usage ... y=myimphaseshuffle(im,bands)

imdim=size(im);
reven=rem(imdim(1),2);
ceven=rem(imdim(2),2);

imf=fft2(im);
imm=abs(imf);
imp=angle(imf);


