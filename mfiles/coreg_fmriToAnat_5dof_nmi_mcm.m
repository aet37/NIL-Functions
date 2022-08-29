function [rsrcimg,mp]=coreg_fmriToAnat_5dof_nmi(refimg,srcimg,guess,kernel)

center=ones(size(refimg));
center=convn(center,ones(5),'same');
center=single(center==max(center(:)));
mask=center;

if ~exist('kernel','var')
    kernel=11;
end
if ~exist('guess','var')
    guess = [0 0 0 1 1];
end

[~,p] = mycoreg(convn(refimg,romano_filt(kernel,kernel,1),'same'),convn(srcimg,romano_filt(kernel,kernel,1),'same'),mask,guess);
% p=guess;
rsrcimg=applyAffine_5dof(srcimg,p(1),p(2),p(3),p(4),p(5),refimg);
mp=p;


%%%%%%%%%%%%%%%%%%%%
% sub functions
%%%%%%%%%%%%%%%%%%%%
function [rsrcimg,p] = mycoreg(refimg,srcimg,mask,x0)
p=x0;
p(1:3) = fminsearch(@coreg_cost_nmi,p(1:3),[],1:3,p,refimg,srcimg,mask);
rsrcimg=applyAffine_5dof(srcimg,p(1),p(2),p(3),p(4),p(5),refimg);

function iimg=applyAffine_5dof(img,xtrans,ytrans,zrot,xscale,yscale,space)
if ~exist('space','var')
    [nx,ny,nz,nt]=size(img);
else
    [nx,ny,nz,nt]=size(space);
end
[ii,jj,kk,ll]=ndgrid(1:nx,1:ny,1:nz,1:nt);

% z rotation matrix
zrotmat=eye(4); zrotmat(1,1)=cos(zrot); zrotmat(2,2)=cos(zrot); zrotmat(1,2)=-sin(zrot); zrotmat(2,1)=sin(zrot);
% translation matrix
transmat=eye(4); transmat(1,4)=xtrans; transmat(2,4)=ytrans;
% scale matrix
scalemat=eye(4); scalemat(1,1)=xscale; scalemat(2,2)=yscale;


T=scalemat*zrotmat*transmat;

indmat=cat(1,reshape(ii,[1 nx*ny*nz*nt]),reshape(jj,[1 nx*ny*nz*nt]),reshape(kk,[1 nx*ny*nz*nt]),reshape(ll,[1 nx*ny*nz*nt]));

indmat=T*indmat;
xx=reshape(indmat(1,:),[nx,ny,nz,nt]);
yy=reshape(indmat(2,:),[nx,ny,nz,nt]);
zz=reshape(indmat(3,:),[nx,ny,nz,nt]);

if nz>1
    iimg=interp3(img,yy,xx,zz);
elseif nz==1
    iimg=interp2(img,yy,xx);
end

function neg_nmi = coreg_cost_nmi(x,n,x0,refimg,srcimg,mask)
x0(n)=x;
intimg=applyAffine_5dof(srcimg,x0(1),x0(2),x0(3),x0(4),x0(5),refimg);
jhist=jointHistogram(intimg,refimg,16,mask);
% show(jhist)
neg_nmi=-nmi(jhist);

function filt = romano_filt(nx,ny,nz)
[xx,yy,zz]=meshgrid(-1:(2/(nx+1)):1,-1:(2/(ny+1)):1,-1:(2/(nz+1)):1);
filt = (1-xx.^2).^2 .* (1-yy.^2).^2 .* (1-zz.^2).^2;
filt = filt(2:end-1,2:end-1,2:end-1);
filt = filt/sum(filt(:));

function jhist = jointHistogram(a,b,nbins,mask)

if ~exist('mask','var')
    mask=ones(size(a));
end
ind=find(mask);

arange=range(a(ind)); abinsize=arange/nbins;
brange=range(b(ind)); bbinsize=brange/nbins;

jhist=zeros(nbins);

abinstart=min(a(ind)); abinend=abinstart+abinsize;

for ii=1:nbins
    bbinstart=min(b(ind)); bbinend=bbinstart+bbinsize;
    for jj=1:nbins
        jhist(ii,jj) = length(find(a>=abinstart & a<=abinend & b>=bbinstart & b<=bbinend & mask));
        
        bbinstart=bbinstart+bbinsize;
        bbinend=bbinend+bbinsize;
    end
    
    abinstart=abinstart+abinsize;
    abinend=abinend+abinsize;
end

function y = nmi(jhist)

jhist=jhist+eps;
jhist=jhist/sum(jhist(:));

s1=sum(jhist,1); s2=sum(jhist,2);

y = (sum(s1.*log2(s1))+sum(s2.*log2(s2)))/sum(sum(jhist.*log2(jhist)));

% disp(y)
% figure
% imagesc(jhist)