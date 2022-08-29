function y=imRegf(im1,im2,mask,ord)
% Usage ... y=imRegf(im1,im2,mask,order)
%
% Subtract the contribution from im2 to im1

if nargin<4, ord=1; end;
if nargin<3, mask=ones(size(im1)); end;

yy=zeros(size(im1));
maski=find(mask);
tmpp=polyfit(im2(maski),im1(maski),ord);
tmpv=polyval(tmpp,im2(maski));
yy(maski)=tmpv;
y=(im1-yy).*mask;

if nargout==0,
  subplot(221)
  show(im1)
  subplot(222)
  show(im2)
  subplot(223)
  show(y)
  subplot(224)
  plot(im2(maski),im1(maski),'x')
end;

