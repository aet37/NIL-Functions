function out=volTransRot(vol,rot,trans,zero_flag)
% Usage ... y=volTransRot(vol,rot,trans,zero_flag)

if nargin<4, zero_flag=0; end;
if nargin<3, trans=[0 0 0]; end;

if length(rot)==6,
  rotLoc=rot(4:6); rot=rot(1:3);
else,
  rotLoc=[0 0 0]; rot=rot(1:3);
end;

rot=rot*pi/180;

[nx,ny,nz]=size(vol);
[xx,yy,zz]=meshgrid([-fix(ny/2):ceil(ny/2)-1]+rotLoc(1),[-fix(nx/2):ceil(nx/2)-1]+rotLoc(2),[-fix(nz/2):ceil(nz/2)-1]+rotLoc(3));

Rot_z=[cos(rot(1)) -sin(rot(1)) 0; sin(rot(1)) cos(rot(1)) 0; 0 0 1];
Rot_x=[1 0 0; 0 cos(rot(2)) -sin(rot(2)); 0 sin(rot(2)) cos(rot(2))];
Rot_y=[cos(rot(3)) 0 sin(rot(3)); 0 1 0; -sin(rot(3)) 0 cos(rot(3))];

newLoc=[xx(:) yy(:) zz(:)]*Rot_z*Rot_x*Rot_y; 
newLoc=newLoc+ones(size(newLoc,1),1)*trans;
xnew=reshape(newLoc(:,1),size(xx,1),size(xx,2),size(xx,3));
ynew=reshape(newLoc(:,2),size(yy,1),size(yy,2),size(yy,3));
znew=reshape(newLoc(:,3),size(zz,1),size(zz,2),size(zz,3));
y=interp3(xx,yy,zz,vol,xnew,ynew,znew,'linear');
if zero_flag, y(find(isnan(y)))=0; end;

out.rvol=y;
out.x_max=squeeze(max(y,[],1));
out.y_max=squeeze(max(y,[],2));
out.z_max=squeeze(max(y,[],3));
out.x_min=squeeze(min(y,[],1));
out.y_min=squeeze(min(y,[],2));
out.z_min=squeeze(min(y,[],3));
out.x_avg=squeeze(mean(y,1));
out.y_avg=squeeze(mean(y,2));
out.z_avg=squeeze(mean(y,3));

if nargout==0, 
  showProj(y); 
  clear out
end;

