function x=tshift2(x,x0)
% Usage ... y=tshift2(x,x0)
%
% 1D shift in fourier domain


x=x(:);

xx=[0:length(x)-1]/length(x);
xx=xx(:);


xf=fft(x);

xf2=abs(xf).*exp(j*angle(xf)-j*2*pi*x0*xx);

y=real(ifft(xf2));

if (nargout==0),
  ii=[1:length(y)];
  plot(ii,y,ii,x)
  clear y
end;


