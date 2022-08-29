function [f,window]=imsmooth(im,window,norm,zpad_resf)
% Usage ... f=imsmooth(im,window,norm,zpad_resf)
%
% if you provide a window it must be centered about (0,0) of the
% image in the middle of the screen defined as [-32:31] for a 64
% image, and the window must be in IMAGE domain, so it will be
% fft2'ed. So if you have it in fourier domain use 
% fftshift(ifft2(window))

if (nargin<4), zpad_flag=0; else, zpad_flag=1; end;
if (zpad_resf==ones(size(zpad_resf))), zpad_flag=0; end;
if (nargin<2), window=2; end;

if (window==0),
  f=im;
  if (nargout==0), show(f), end;
  return,
end;

imres=size(im);
if (zpad_flag),
  if (sum(zpad_resf>1)),
    if length(zpad_resf)==1, zpad_resf(2)=zpad_resf(1); end;
    imres_orig=imres;
    imres(1)=imres(1)*zpad_resf(1);
    imres(2)=imres(2)*zpad_resf(2);
  else,
    error('zero-pad factor must be > 1');
  end;
end;


% default window is a Gaussian
if length(window)<=2,
  if length(window)==2, wl=window; else, wl=[window(1) window(1)]; end;
  window=zeros(imres);
  xx=[0:imres(1)-1]-imres(1)/2;
  yy=[0:imres(2)-1]-imres(2)/2;
  for m=1:imres(1), for n=1:imres(2),
    window(m,n)=exp(-xx(m)*xx(m)/(2*wl(1)*wl(1)))*exp(-yy(n)*yy(n)/(2*wl(2)*wl(2)));
  end; end;
  window=window*(1/sqrt(4*pi*wl(1)*wl(2)));
  window=window/sqrt(wl(1)*wl(2)*pi);
end;

if nargin<3,
  norm=0;
else,
  if isempty(norm), norm=0; end;
end;

window_fft=fft2(window);
window_norm=max(max(abs(window_fft)));
if (norm==2),
  window_norm=sum(sum(abs(window_fft)));
end;

im_fft=fft2(im);
if (zpad_flag),
  zres=imres-imres_orig;
  tmp=im_fft;
  im_fft=zeros(imres);
  i1=floor(imres_orig(1)/2)+1;
  i2=floor(imres_orig(2)/2)+1;
  i3=i1+zres(1)+1;	% maybe floor here
  i4=i2+zres(2)+1;	% maybe floor here
  %[i1 i2 i3 i4],
  im_fft(1:i1,1:i2)=tmp(1:i1,1:i2);
  im_fft(i3:end,1:i2)=tmp(i1+1:end,1:i2);
  im_fft(1:i1,i4:end)=tmp(1:i1,i2+1:end);
  im_fft(i3:end,i4:end)=tmp(i1+1:end,i2+1:end);
end;
%show(fftshift(abs(im_fft))'), pause,
%show(fftshift(abs(window))'), pause,
imf=abs(im_fft).*abs(window_fft).*exp(j*(angle(im_fft)+angle(window_fft)));
if (norm), imf=imf/window_norm; end;
f=fftshift(ifft2(imf));
if (zpad_flag), f=imshift2(f,zpad_resf(1)/2-0.5,zpad_resf(2)/2-0.5)*prod(zpad_resf); end;
%show(f'), pause,

if nargout==0,
  show(real(f)),
end;

