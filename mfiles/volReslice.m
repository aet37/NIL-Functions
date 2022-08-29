function out=volReslice(vol,rot,trans,wid,ds,zero_flag)
% Usage ... y=volReslice(vol,rot,trans,width,ds,zero_flag)

if nargin<6, zero_flag=0; end;
if nargin<5, ds=[1 1 1]; end;
if nargin<4, wid=size(vol); end;
if nargin<3, trans=[0 0 0]; end;

if length(rot)==6,
  rotLoc=rot(4:6); rot=rot(1:3);
else,
  rotLoc=[0 0 0]; rot=rot(1:3);
end;

[nx,ny,nz]=size(vol);
rot=rot*(pi/180);

[xx,yy,zz]=meshgrid([-fix(ny/2):ceil(ny/2)-1]+rotLoc(2),[-fix(nx/2):ceil(nx/2)-1]+rotLoc(1),[-fix(nz/2):ceil(nz/2)-1]+rotLoc(3));

%[xs,ys,zs]=meshgrid([-fix(wid(2)/2):ds(2):ceil(wid(2)/2)-1]+rotLoc(1),[-fix(wid(1)/2):ds(1):ceil(wid(1)/2)-1]+rotLoc(1),zeros(1,nz)+rotLoc(3));
[xs,ys,zs]=meshgrid([-fix(wid(2)/2):ds(2):ceil(wid(2)/2)-1]+rotLoc(1),[-fix(wid(1)/2):ds(1):ceil(wid(1)/2)-1]+rotLoc(1),[-fix(wid(3)/2):ds(3):ceil(wid(3)/2)-1]+rotLoc(3));

Rot_z=[cos(rot(1)) -sin(rot(1)) 0; sin(rot(1)) cos(rot(1)) 0; 0 0 1];
Rot_x=[1 0 0; 0 cos(rot(2)) -sin(rot(2)); 0 sin(rot(2)) cos(rot(2))];
Rot_y=[cos(rot(3)) 0 sin(rot(3)); 0 1 0; -sin(rot(3)) 0 cos(rot(3))];

newLoc=[xs(:) ys(:) zs(:)]*Rot_z*Rot_x*Rot_y; 
newLoc=newLoc+ones(size(newLoc,1),1)*trans;
xnew=reshape(newLoc(:,1),size(xs,1),size(xs,2),size(xs,3));
ynew=reshape(newLoc(:,2),size(ys,1),size(ys,2),size(ys,3));
znew=reshape(newLoc(:,3),size(zs,1),size(zs,2),size(zs,3));
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

