function f=getimval(im,pix)
% Usage ... f=getimval(im,pix)

for m=1:size(pix,1),
  f(m)=im(pix(m,1),pix(m,2));
end;

