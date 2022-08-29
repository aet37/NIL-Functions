function y=tshiftf(x,i0)
% Usage ... y=tshiftf(x,i0)
%

ii=[1:length(x)]/length(x);

xf=fft(x);
yphs=angle(xf)-2*pi*i0*ii;
yf=abs(xf).*exp(j*yphs);
y=real(ifft(yf));

