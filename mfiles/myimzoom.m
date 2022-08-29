function imz=myimzoom(im,outres,type)
% Usage ... imz=myimzoom(im,outres)

if (nargin<3), type='linear'; end;


if prod(size(im))>prod(outres),

  imf=fftshift(fft2(im));
  %[1 outres(1)]+floor(size(im,1)/2)-floor(outres(1)/2)-1,
  %[1 outres(2)]+floor(size(im,2)/2)-floor(outres(2)/2)-1, 
  imfi=imf([1:outres(1)]+floor(size(im,1)/2)-floor(outres(1)/2)-1,[1:outres(2)]+floor(size(im,2)/2)-floor(outres(2)/2)-1);
  imfi=fftshift(imfi);
  imz=abs(ifft2(imfi));
  %keyboard,

else,

  inres=size(im);
  [xi,yi]=meshgrid([-inres(2)/2:inres(2)/2-1]/inres(2),[-inres(1)/2:inres(1)/2-1]/inres(1));
  xi=xi+(1/(2*inres(1)));
  yi=yi+(1/(2*inres(2)));

  xo=[-outres(2)/2:outres(2)/2-1]/outres(2);
  yo=[-outres(1)/2:outres(1)/2-1]'/outres(1);
  xo=xo+(1/(2*outres(1)));
  yo=yo+(1/(2*outres(2)));

  imz=interp2(xi,yi,im,xo,yo,type);

end;

