function [mp,rstack]=realign_3dof(fmri_data,mask)

ndim=length(size(fmri_data));
if ndim==3
    fmri_data=permute(fmri_data,[1 2 4 3]);
end

[nx,ny,nz,nt]=size(fmri_data);
[ii,jj,kk,ll]=ndgrid(1:nx,1:ny,1:nz,1:1);
indmat=cat(1,reshape(ii,[1 nx*ny*nz]),reshape(jj,[1 nx*ny*nz]),reshape(kk,[1 nx*ny*nz]),reshape(ll,[1 nx*ny*nz]));

center=ones(nx,ny,nz);
center=convn(center,ones(5),'same');
center=single(center==max(center(:)));
if ~exist('mask','var') || isempty(mask)
    mask=center;
else
    mask=mask&center;
end
maskind=find(mask);

if nargout>1
rstack=zeros(size(fmri_data));
rstack(:,:,:,1)=fmri_data(:,:,:,1);
end
mp=zeros(nt,3);

kernel=11;
guess = [0 0 0];

rfilter=romano_filt(kernel,kernel,1);
refimg=convn(fmri_data(:,:,:,1),rfilter,'same');
% h=waitbar(0,'realigning images...');

figure;
for ii=2:nt
    tic
    
    p = fminsearch(@coreg_cost_cc,guess,[],refimg,convn(fmri_data(:,:,:,ii),rfilter,'same'),maskind,indmat,nx,ny,nz);
    
    while max(max(abs(guess-p)))>0.01
        guess=p;
        p = fminsearch(@coreg_cost_cc,guess,[],refimg,convn(fmri_data(:,:,:,ii),rfilter,'same'),maskind,indmat,nx,ny,nz);
    end
    
    guess=p;
    mp(ii,:)=p;
    
    if nargout>1
    rstack(:,:,:,ii)=applyAffine_3dof(fmri_data(:,:,:,ii),p(1),p(2),p(3),indmat,nx,ny,nz);
    end
    
    
    
        plot(mp(:,1:2)); xlim([1 ii]); drawnow
    
    
%     waitbar(ii/nt,h);

    
    disp(['done with time ' num2str(ii) ', ' num2str(toc)]);
end
% close(h);



if ndim==3 && nargout>1
    rstack=permute(rstack,[1,2,4,3]);
end

%%%%%%%%%%%%%%%%%%%%
% sub functions
%%%%%%%%%%%%%%%%%%%%
function neg_r = coreg_cost_cc(x,refimg,srcimg,maskind,indmat,nx,ny,nz)
intimg=applyAffine_3dof(srcimg,x(1),x(2),x(3),indmat,nx,ny,nz);
neg_r=sum((mynorm(refimg(maskind))-mynorm(intimg(maskind))).^2);

function iimg=applyAffine_3dof(img,xtrans,ytrans,zrot,indmat,nx,ny,nz)
% z rotation matrix
zrotmat=eye(4); zrotmat(1,1)=cos(zrot); zrotmat(2,2)=cos(zrot); zrotmat(1,2)=-sin(zrot); zrotmat(2,1)=sin(zrot);
% translation matrix
transmat=eye(4); transmat(1,4)=xtrans; transmat(2,4)=ytrans;

T=zrotmat*transmat;


transformedmat=T*indmat;
xx=reshape(transformedmat(1,:),[nx,ny,nz,1]);
yy=reshape(transformedmat(2,:),[nx,ny,nz,1]);


if nz>1
    zz=reshape(transformedmat(3,:),[nx,ny,nz,1]);
    iimg=interp3(img,yy,xx,zz); 
else
    iimg=interp2(img,yy,xx);
end
