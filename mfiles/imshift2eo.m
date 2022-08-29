function y=imshift2eo(x,x0,zero_flag,transp_flag)
% Usage ... y=imshift2eo(x,x0,zero_flag)
%
% 1D shift in fourier domain

if nargin<4, transp_flag=0; end;

transp_flag=(~transp_flag);

if ~transp_flag,
  x=x.';
end;

if nargin<3, zero_flag=0; end;

y=zeros(size(x));

for mm=1:size(x,1),
  % shift the function by the transit time in Frq Domain
  xfft = fftshift(fft(x(mm,:)));
  xphase = [-size(x,2)/2:size(x,2)/2-1]*2*pi/size(x,2);
  %xphase = ones(size(x,1),1)*xphase;
  %plot(xphase), pause,

  xphase = x0*xphase*sign(rem(mm,2)-0.5);
  xphase = exp(-i.*xphase );
  xfft2 = xfft.*xphase;

  % carry out the convolution by multiplying in frq. domain
  tmpy = real(ifft(ifftshift(xfft2)));

  if zero_flag,
    if x0>1, 
      tmpy(1:floor(x0))=0;
    elseif x0<-1,
      tmpy(end+floor(x0)+1:end)=0;
    end;
  end;
  
  y(mm,:)=tmpy;
end

if ~transp_flag, y=y.'; end;

if (nargout==0),
  plot(y)
  clear y
end;


