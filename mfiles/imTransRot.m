function y=imTransRot(im,trans,rot,zero_flag)
% Usage ... y=imTransRot(im,trans,rot,zero_flag)

if nargin<4, zero_flag=1; end;
if nargin<3, rot=0; end;

if length(rot)==3, rotLoc=rot(2:3); else, rotLoc=[0 0]; end;
rot=rot(1);
if abs(rot)>4, rot=rot*pi/180; end;

[nx,ny]=size(im);
[xx,yy]=meshgrid([-fix(nx/2):ceil(nx/2)-1]+rotLoc(1),[-fix(ny/2):ceil(ny/2)-1]+rotLoc(2));

zz=[xx(:) yy(:)]*[cos(rot) -sin(rot); sin(rot) cos(rot)];
xnew=reshape(zz(:,1)+trans(1),size(xx,1),size(xx,2));
ynew=reshape(zz(:,2)+trans(2),size(yy,1),size(yy,2));

y=interp2(xx,yy,im,xnew,ynew,'linear');
y(find(isnan(y)))=0;

if nargout==0, show(y), end;

