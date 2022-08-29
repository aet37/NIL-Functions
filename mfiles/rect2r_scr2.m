
%
% Simulation/demonstration of interpolating a sub-region of a 2D image
% using an initial rectangular grid.  A cylindrical object is simulated.
% The accuracy of the interpolation is evaluated by measuring the 
% parameters of the angled cylinder against the interpolated one.
%

clear all

% dimensions and grids for simulated image
dim=[512 512];
[xg0,yg0]=meshgrid([1:dim(1)],[1:dim(2)]);

% object parameters
rad=35.5;
ctr=[254.1 17.3];
amp=1.0;
ang=57;

% interpolation area parameters
rw=[10 120];
rang=-33;
rctr=[200 240];


% re-structure for rotation
xg0r=reshape(xg0,prod(size(xg0)),1);
yg0r=reshape(yg0,prod(size(yg0)),1);
ctr0=mean([xg0r yg0r])-[0.5 0.5];

% alternate grid
[xg0i,yg0i]=meshgrid([1:0.1:rw(1)],[1:0.1:rw(2)]);
xg0ir=reshape(xg0i,prod(size(xg0i)),1);
yg0ir=reshape(yg0i,prod(size(yg0i)),1);
ctr0i=mean([xg0ir yg0ir])-0.5;

% rotate and translate
ang=ang*(pi/180);
rotm=[cos(ang) -sin(ang); sin(ang) cos(ang)];
tmpr=([xg0r yg0r]-ones(length(xg0r),1)*ctr0)*rotm + ones(length(xg0r),1)*ctr;

ang=ang-pi/2;
rotm=[cos(ang) -sin(ang); sin(ang) cos(ang)];
tmpir=([xg0ir yg0ir]-ones(length(xg0ir),1)*ctr0i)*rotm + ones(length(xg0ir),1)*rctr;

% make the simulation object and a sample of its cross-section
zz=amp*sqrt(1-([-256:255]/rad).^2);
zz(find(abs([-256:255])>rad))=0;
tmpz=amp*sqrt(1-(tmpr(:,2)/rad).^2);
tmpz(find(abs(tmpr(:,2))>rad))=0;
im1=reshape(tmpz,dim(1),dim(2));

% make grid for interpolation via rectangular object/mask
[a0,b0,c0,d0]=rect2r(rw,0,rctr,size(im1));
[a,b,c,d]=rect2r(rw,rang,rctr,size(im1));
a=imclose(a,ones(3,3));

% interpolate object 
zi0=interp2(xg0,yg0,im1,b0(:,2),b0(:,1));
zr0=reshape(zi0,rw(1),rw(2));
zi=interp2(xg0,yg0,im1,b(:,2),b(:,1));
o1r=reshape(d(:,1),rw(1),rw(2));
o2r=reshape(d(:,2),rw(1),rw(2));
zr=reshape(zi,rw(1),rw(2));
zii=interp2(xg0,yg0,im1,tmpir(:,2),tmpir(:,1));
zir=reshape(zii,size(xg0i,1),size(xg0i,2));
zri0=zeros(dim(1),dim(2));
zri0(round(xg0i),round(yg0i))=1;
zri1=zeros(dim(1),dim(2));
for mm=1:length(tmpir), zri1(round(tmpir(mm,1)),round(tmpir(mm,2)))=1; end;

% compare calculations
figure(4)
calcRadius4(1.3-im1,a,-31)
figure(5)
calcRadius2(2-mean(zr));
figure(6)
calcRadius3b(2-mean(zr));


figure(1),clf
show(im_super(im1,a+a0,0.3))
figure(2),clf
subplot(211)
show(zr0)
subplot(212)
show(zr)
figure(3),clf
plot([1:rw(2)]+dim(2)/2-rw(2)/2,mean(zr),[1:dim(2)],zz,[1:0.1:rw(2)]+dim(2)/2-rw(2)/2,mean(zir'))



