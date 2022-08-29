function [f,window]=imsmooth(im,window,norm)
% Usage ... f=imsmooth(im,window,norm)

% default window is a Gaussian
if length(window)<=2,
  if length(window)==2, wl=window; else, wl=[window(1) window(1)]; end;
  window=zeros(size(im));
  xx=[0:size(im,1)-1]-size(im,1)/2;
  yy=[0:size(im,2)-1]-size(im,2)/2;
  for m=1:size(im,1), for n=1:size(im,2),
    window(m,n)=exp(-xx(m)*xx(m)/(2*wl(1)*wl(1)))*exp(-yy(n)*yy(n)/(2*wl(2)*wl(2)));
  end; end;
  window=window*(1/sqrt(4*pi*wl(1)*wl(2)));
end;

if nargin<3, norm=0; end;

window_fft=fft2(window);
window_norm=max(max(abs(window_fft)));

im_fft=fft2(im);
%show(fftshift(abs(im_fft))'), pause,
%show(fftshift(abs(window))'), pause,
imf=abs(im_fft).*abs(window_fft).*exp(-j*(angle(im_fft)+angle(window_fft)));
if (norm), imf=imf/window_norm; end;
f=fftshift(ifft2(imf));
%show(f'), pause,

