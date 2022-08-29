function [xx,yy,iimg]=apply2Daffine_3dof(img,xtrans,ytrans,rot)

[nx,ny,nz]=size(img);
[ii,jj,kk]=ndgrid(1:nx,1:ny,1:nz);

% figure; subplot 311; imagesc(ii); subplot 312; imagesc(jj); subplot 313; imagesc(kk)

% rotation matrix
rotmat=eye(3); rotmat(1,1)=cos(rot); rotmat(2,2)=cos(rot); rotmat(1,2)=-sin(rot); rotmat(2,1)=sin(rot);
% translation matrix
transmat=eye(3); transmat(1,3)=xtrans; transmat(2,3)=ytrans;

T=rotmat*transmat;

indmat=cat(1,reshape(ii,[1 nx*ny*nz]),reshape(jj,[1 nx*ny*nz]),reshape(kk,[1 nx*ny*nz]));

indmat=T*indmat;
xx=reshape(indmat(1,:),[nx,ny,nz]);
yy=reshape(indmat(2,:),[nx,ny,nz]);
zz=reshape(indmat(3,:),[nx,ny,nz]);

if nargout>2
%     [ii,jj]=ndgrid(1:rny,1:rnx);
    iimg=interp3(img,yy,xx,zz);
%     figure; subplot 121; imagesc(iimg); subplot 122; imagesc(img);
end