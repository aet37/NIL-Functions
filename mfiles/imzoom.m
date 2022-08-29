function zim=imzoom(im,zf,itype)
% Usage ... im=imzoom(im,x,type)

if length(zf)==1, zf(2)=zf(1); end;
if (nargin<3), itype='linear'; end;

[xdim,ydim]=size(im);
[x0,y0]=meshgrid([0:size(im,2)-1]/(size(im,2)-1),[0:size(im,1)-1]/(size(im,1)-1));
[x1,y1]=meshgrid([0:zf(2)*size(im,2)-1]/(zf(2)*size(im,2)-1),[0:zf(1)*size(im,1)-1]/(zf(1)*size(im,1)-1));

%keyboard,
zim=interp2(x0,y0,im,x1,y1,itype);


