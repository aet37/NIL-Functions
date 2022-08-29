function y=im_thr(x,it,ct)
% Usage ... y=im_thr(image,image_thr,cont_thr)
%
% Returns a thresholded image to a particular intesity
% and contiguity threshold.

% Optimized for matlab

[xdim,ydim,zdim]=size(x);
if (~isempty(it)),
  y=(x>=it);
else,
  y=x;
end;

if nargin>2,
  z=zeros(size(x));
  for mm=1:zdim,
  for m=1:xdim, for n=1:ydim,
    neigh=0; a1=0; a2=0; b1=0; b2=0;
    if (m==1), a1=m; a2=m+1; end;
    if (m==xdim), a1=m-1; a2=m; end;
    if (n==1), b1=n; b2=n+1; end;
    if (n==ydim), b1=n-1; b2=n; end;
    if (~a1), a1=m-1; a2=m+1; end;
    if (~b1), b1=n-1; b2=n+1; end;
    %[m n a1 a2 b1 b2],
    neigh=sum(sum(y(a1:a2,b1:b2,mm)));
    if (neigh>=(ct+1))&(y(m,n,mm)),
      z(m,n,mm)=1;
    end;
  end; end;
  end;
  y=z;
end;

if (~nargout),
  show(y');
end;

