function [f,window]=smooth1d(y,window,norm)
% Usage ... f=smooth1d(y,window,norm)
%
% if you provide a window it must be centered in the middle
% for example, a 64 length vector is [-32:31] 
% if you have it in fourier domain use 
% fftshift(ifft(window))

do_real=1;

if (nargin<2), window=2; end;

if (window==0),
  f=y;
  return,
end;

% default window is a Gaussian
y=y(:);
wl=window;
window=zeros(length(y),1);
xx=[0:length(y)-1]'-length(y)/2;
window=exp(-(xx.*xx)./(2*wl*wl));
window=window*(1/sqrt(4*pi*wl*wl));

if nargin<3,
  norm=0;
end;

window_fft=fft(window);
window_norm=max(abs(window_fft));
if (norm==2),
  window_norm=sum(abs(window_fft));
end;

y_fft=fft(y);
yf=abs(y_fft).*abs(window_fft).*exp(j*(angle(y_fft)+angle(window_fft)));
if (norm), yf=yf/window_norm; end;
f=fftshift(ifft(yf));

if do_real, f=real(f); end;

if nargout==0,
    clf, subplot(211), plot(window),
         subplot(212), plot([y(:) f(:)]),
end;


