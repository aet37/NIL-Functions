function iimg=applyAffine_3dof(img,xtrans,ytrans,zrot)

[nx,ny,nz,nt]=size(img);
[ii,jj,kk,ll]=ndgrid(1:nx,1:ny,1:nz,1:nt);

% figure; subplot 311; imagesc(ii); subplot 312; imagesc(jj); subplot 313; imagesc(kk)

% z rotation matrix
zrotmat=eye(4); zrotmat(1,1)=cos(zrot); zrotmat(2,2)=cos(zrot); zrotmat(1,2)=-sin(zrot); zrotmat(2,1)=sin(zrot);
% translation matrix
transmat=eye(4); transmat(1,4)=xtrans; transmat(2,4)=ytrans;

T=zrotmat*transmat;

indmat=cat(1,reshape(ii,[1 nx*ny*nz*nt]),reshape(jj,[1 nx*ny*nz*nt]),reshape(kk,[1 nx*ny*nz*nt]),reshape(ll,[1 nx*ny*nz*nt]));

indmat=T*indmat;
xx=reshape(indmat(1,:),[nx,ny,nz,nt]);
yy=reshape(indmat(2,:),[nx,ny,nz,nt]);
zz=reshape(indmat(3,:),[nx,ny,nz,nt]);

if nz>1
    iimg=interp3(img,yy,xx,zz);
else
    iimg=interp2(img,yy,xx);
end
