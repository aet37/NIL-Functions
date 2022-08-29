function y=xshift2(x,x0,zero_flag)
% Usage ... y=xshift2(x,x0,zero_flag)
%
% 1D shift in fourier domain

x=x(:).';

if nargin<3, zero_flag=0; end;
  
     % shift the function by the transit time in Frq Domain
     xfft = fftshift(fft(x));
     xphase = [-size(x,2)/2:size(x,2)/2-1]*2*pi/size(x,2);
     xphase = ones(size(x,1),1)*xphase;
     %plot(xphase), pause,
     xphase = x0*xphase;
     xphase = exp(-i.*xphase );
     xfft2 = xfft.*xphase;

     % carry out the convolution by multiplying in frq. domain
     y = real(ifft(ifftshift(xfft2)));


if zero_flag,
  if x0>1, 
    y(1:floor(x0))=0;
  elseif x0<-1,
    y(end+floor(x0)+1:end)=0;
  end;
end;

y=y(:);
 
if (nargout==0),
  plot(y)
  clear y
end;


