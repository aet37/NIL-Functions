function fz=imzeropad(im,outres)
% Usage ... fz=imzeropad(im,outres)

[imx,imy]=size(im);
outx=outres(1);
outy=outres(2);

imf=fftshift(fft2(fftshift(im)));
fzf=zeros(size(outres));
fzf(outx/2-imx/2:outx/2+imx/2-1,outy/2-imy/2:outy/2+imy/2-1)=imf;
fz=fftshift(ifft2(fftshift(fzf)));

if (nargout==0),
  show(abs(fz)')
end;

