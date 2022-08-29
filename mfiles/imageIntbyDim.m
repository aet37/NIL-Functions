function y=imageIntbyDim(im,zf)
% Usage ... y=imageIntbyDim(im,zf_by_dim)

dd=size(im);

xx=([1:dd(1)]-1)/(dd(1)-1);
yy=([1:dd(2)]-1)/(dd(2)-1);

xi=([1:round(dd(1)*zf(1))]-1)/(dd(1)*zf(1)-1);
yi=([1:round(dd(2)*zf(2))]-1)/(dd(2)*zf(2)-1);

[xg,yg]=meshgrid(xx,yy);
[xgi,ygi]=meshgrid(xi,yi);
%keyboard,
y=interp2(xg,yg,im',xgi,ygi,'linear');

if nargout==0,
  show(y)
end

