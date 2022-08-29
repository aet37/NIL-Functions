function y=myrect2drot(imsize,rc,rw,rang)
% Usage ... y=myrect2drot(imsize,rc,rw,ang)

xdim=imsize(1);
ydim=imsize(2);
rx=rc(1)-xdim/2;
ry=rc(2)-ydim/2;
wx=rw(1);
wy=rw(2);
rang=rang;

kx=[1:xdim]/xdim-0.5;
ky=[1:ydim]/ydim-0.5;

[gkx,gky]=meshgrid(kx,ky);
g1=reshape(frect2d(gky,gkx,rx,ry,wx,wy,rang,1),[xdim ydim]);

y=fftshift(abs(ifft2(g1)))>0.1;

if nargout==0,
  show(y)
  %subplot(211)
  %show(abs(g1))
  %subplot(212)
  %show(fftshift(abs(ifft2(g1))))
  clear y
end;


