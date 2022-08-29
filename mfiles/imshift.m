function imz=imshift(im,x0,y0,type)
% Usage ... imz=myimshift(im,x0,y0,type)

if (nargin<4), type='linear'; end;

inres=size(im);
[xi,yi]=meshgrid([1:inres(2)],[1:inres(1)]);
xo=xi+x0;
yo=yi+y0;

imz=interp2(xi,yi,im,xo,yo,type,0);
%keyboard,

if nargout==0,
  show(imz)
  clear imz
end;

