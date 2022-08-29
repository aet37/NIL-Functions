function [xd,xdi]=fdeconv(y,h,ff)
% Usage ... xd=fdeconv(y,h,filter)
%
% Returns the input x(t) of a system response y(t) that
% has impulse response h(t) using Fourier deconvolution.
% If y(t) is noisy, the input signal will be filtered
% using f(w).

if (nargin<3),
  ff=length(h);
else,
  if isempty(ff),
    ff=length(h);
  end;
end;

if (length(ff)==1),
  ff0=ff;
  ff=zeros(size(y));
  ff(1:ff0)=1;
  ff(end-ff0+1:end)=1;
end;

yf=fft(y);
hf=fft(h)/sum(h);

xdf=yf./hf;
xdf=ff.*xdf;

xd=ifft(xdf);

xdi=imag(xd);
xd=real(xd);

if nargout==0,
  clf, plot(xd),
  axis tight, grid on,
end;

