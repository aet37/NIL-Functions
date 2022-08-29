function ys=tshift2(x,x0)
% Usage ... y=tshift2(x,x0)
%
% 1D shift in fourier domain


     % shift the function by the transit time in Frq Domain
     xfft = fftshift(fft(x(:)));
     xphase = [-length(x)/2:length(x)/2-1]*2*pi/length(x);
     xphase = ones(length(x),1).*xphase(:);
     %plot(xphase), pause,
     xphase = x0*xphase;
     xphase = exp(-i.*xphase );
     xfft = xfft.*xphase;

     % carry out the convolution by multiplying in frq. domain
     ys = real(ifft(ifftshift(xfft)));


if (nargout==0),
  plot(ys)
  clear ys
end;


