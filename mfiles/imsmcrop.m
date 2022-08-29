function y=imsmcrop(x,dim)
% Usage ... y=imsmcrop(x,dim)

[nx,ny]=size(x);
wx=hanning(dim(1));
wy=hanning(dim(2));

wwx=wx*ones(1,dim(2));
wwy=ones(dim(1),1)*(wy.');
www=wwx.*wwy;
www=www/sum(sum(www));

ww=zeros(size(x));
xi=round((nx-dim(1))/2);
yi=round((ny-dim(2))/2);
ww(xi:xi+dim(1)-1,yi:yi+dim(2)-1)=www;

xf=fftshift(fft2(x));
yf=xf.*ww;
yflr=yf(xi:xi+dim(1)-1,yi:yi+dim(2)-1);

yy=ifft2(yf);
yylr=ifft2(yflr);

y=real(yylr);
%y=abs(yylr);

%keyboard,

if nargout==0,
subplot(232)
show(ww)
subplot(233)
show(abs(xf))
subplot(234)
show(x)
subplot(235)
show(abs(yy))
subplot(236)
show(abs(yylr))
clear y
end;

