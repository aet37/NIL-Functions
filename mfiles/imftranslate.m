function y=imftranslate(x,x0,y0)
% Usage ... y=imftranslate(x,x0,y0)
%


xx=[0:size(x,1)-1]/size(x,1);
yy=[0:size(x,2)-1]/size(x,2);

xx=(ones(size(x,2),1)*xx)';
yy=(ones(size(x,1),1)*yy);

xf=fft2(x);

xf2=abs(xf).*exp(j*angle(xf)-j*2*pi*x0*xx);
xf2=abs(xf).*exp(j*angle(xf2)-j*2*pi*y0*yy);

y=real(ifft2(xf2));

if (nargout==0),
  show(y)
  clear y
end;


