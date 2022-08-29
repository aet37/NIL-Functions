function showvol(v,T)
% Usage ... f=showvol(v)
%
% Note: by default the output is transposed, if
% you wish not to have it like this use showvol(v,0)

if nargin<2, T=1; end;

nx=size(v,1);
ny=size(v,2);
nv=size(v,3);

sq=ceil(sqrt(size(v,3)));
nc=sq; nr=sq;
if (nv<(sq*sq-sq)), nr=nr-1; end;

ii=1;
p=zeros([nx ny]);
f=zeros([nx*nr ny*nc]); 
for cc=1:nc, for rr=1:nr,
  if (ii<=nv),
    f( (rr-1)*nx+1:rr*nx , (cc-1)*ny+1:cc*ny ) = v(:,:,ii);
  else,
    f( (rr-1)*nx+1:rr*nx , (cc-1)*ny+1:cc*ny ) = p;
  end;
  ii=ii+1;
end; end;

%tmpcmd1=sprintf('ii=1; jj=1; done=0; while(~done),');
%tmpcmd2=sprintf('r%d=f(:,:,ii); for m=2:sq, ii=ii+1; 
%tmpcmd3=sprintf('if (ii<=nv), r%d=[r%d f(:,:,ii)]; else, r%d=

if (T), show(f'), else, show(f), end;
title(sprintf('max= %f  min= %f',max(max(f)),min(min(f))));
%colorbar('vert')

