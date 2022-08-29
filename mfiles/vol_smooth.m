function [f,window]=vol_smooth(im,window,norm)
% Usage ... f=vol_smooth(im,window,norm)
%
% if you provide a window it must be centered about (0,0,0) of the
% volume in the middle of the screen defined as [-32:31] for a 64
% image, and the window must be in IMAGE domain, so it will be
% fftn'ed. So if you have it in fourier domain use 
% fftshift(ifftn(window))

if (nargin<2), window=2; end;

if (window==0),
  f=im;
  return,
end;

% default window is a Gaussian
if length(window)<=3,
  if length(window)==3,
     wl=window;
  elseif length(window)==2,
     wl=[window(1) window(2) 1];
  elseif length(window)==1,
     wl=[1 1 1]*window;
  end;
  window=zeros(size(im));
  [xx,yy,zz]=meshgrid([0:size(im,1)-1]-size(im,1)/2, ...
               [0:size(im,2)-1]-size(im,2)/2,[0:size(im,3)-1]-size(im,3)/2);
  window=exp(-xx.*xx/(2*wl(1)*wl(1)));
  window=window.*exp(-yy.*yy/(2*wl(2)*wl(2)));
  window=window.*exp(-zz.*zz/(2*wl(3)*wl(3))); 
  window=window/sqrt(4*pi*wl(1)*wl(1)*wl(2)*wl(2)*wl(3)*wl(3));
end;

if nargin<3,
  norm=0;
end;

window_fft=fftn(window);
window_norm=max(abs(window_fft(:)));
if (norm==2),
  window_norm=sum(abs(window_fft(:)));
end;

im_fft=fftn(im);
%show(fftshift(abs(im_fft))'), pause,
%show(fftshift(abs(window))'), pause,
imf=abs(im_fft).*abs(window_fft).*exp(j*(angle(im_fft)+angle(window_fft)));
if (norm), imf=imf/window_norm; end;
f=fftshift(ifftn(imf));
%show(f'), pause,

if isreal(im), f=real(f); end;

if nargout==0,
  showProj(f)
end;

