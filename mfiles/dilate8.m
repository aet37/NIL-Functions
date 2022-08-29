function y=dilate8(im)
% Usage ... y=dilate8(im)
%
% Dilates 8 neighbors of every ON pixel

xdim=size(im,1);
ydim=size(im,2);

%im=abs(im)>0;
y=zeros(size(im));
for m=1:xdim, 
  if (m==1), xs=0; else, xs=1; end;
  if (m==xdim), xe=0; else, xe=1; end;
  for n=1:ydim,
    if (n==1), ys=0; else, ys=1; end;
    if (n==ydim), ye=0; else, ye=1; end;
    if (im(m,n)),
      y(m-xs:m+xe,n-ys:n+ye)=ones([3 3]);
    end;
  end;
end;


