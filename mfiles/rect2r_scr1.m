
clear all

ww=[40 40];
ang=-22;
cc=[320 320]+0.0;
dim=[640 480];
dc=[40 0];

[a,b,c,d]=rect2r(ww,ang,cc,dim);
[m,n]=meshgrid([1:dim(2)],[1:dim(1)]);
%for mm=1:dim(1), im(mm,:)=mm*ones(dim(2),1); end;
im=zeros(dim); for mm=1:dim(2)-1, im(mm,mm)=1; im(mm+1,mm)=1; im(mm,mm+1)=1; end;
e=interp2(m,n,im,a(:,1),a(:,2));
f=reshape(e,ww(1),ww(2));

imr=imrotate(im,ang,'bilinear','crop');
for mm=1:size(c,1), g(mm)=imr(c(mm,1)+cc(1)+dc(1),c(mm,2)+cc(2)+dc(2)); end;
h=reshape(g,ww(1),ww(2));

subplot(211)
show(f)
subplot(212)
show(h)


