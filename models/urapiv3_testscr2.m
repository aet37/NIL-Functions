
% compare image displacement in binary vs gray-scale

oned_flag=0;
twod_flag=1;


% 1D
if (oned_flag),

xx=9.3;
l1=zeros(1,120);
l1(10:20)=1;
l2=zeros(1,120);
l2(round(xx)+[10:20])=1;

nn=0.0;
l1=gauss_window(120,41.0,4.2,1)+nn*randn(1,120);
l2=gauss_window(120,41.0+xx,6.3,1)+nn*randn(1,120);

dxx=urapiv4(l1,l2);
[xx;dxx],

%tmpx=xcorr(l1,l2);
%tmpdxx=length(l1)-find(tmpx==max(tmpx));
tmpdxx=simple_piv(l1,l2);
[xx;tmpdxx],

nn=5;

subplot(211)
plot([l1n(:,nn) l2n(:,nn)])
ylabel('Intensitity')
xlabel('Sample #')
axis('tight'), grid('on'), fatlines; dofontsize(15);

for mm=1:50,for nn=1:5,
  l1n(:,nn)=l1(:)+amp*(nn-1)*randn(size(l1(:)));
  l2n(:,nn)=l2(:)+amp*(nn-1)*randn(size(l2(:)));
  [dxn(nn,mm),xcn(:,nn)]=simple_piv(l1n(:,nn),l2n(:,nn),[1 3 0]);
end; end;

subplot(212)
plot(xcn(:,nn),'m')
ylabel('X Corr.')
xlabel('Sample #')
axis('tight'), grid('on'), fatlines; dofontsize(15);

end;


% 2D
if (twod_flag),

xx=8.7;
yy=3.4;
dxy0=xx+i*yy;

im1=zeros(40,120);
im1([10:20],[10:30])=1;
im2=zeros(40,120);
im2(round(yy)+[10:20],round(xx)+[10:30])=1;

subplot(221)
show(im1)
subplot(222)
show(im2)

dxy0h=urapiv3(im1,im2);
disp(sprintf('  top: d0=[%.2f,%.2f], e0=[%.2f,%.2f], err=%.2f',real(dxy0),imag(dxy0),real(dxy0h),imag(dxy0h),abs(dxy0-dxy0h))),


namp=0.03;
nn=namp*randn(40,120);
im1=gauss_window([40 120],[10 11],[1 2],1)+0.95*namp*randn(40,120);
im2=gauss_window([40 120],[10 11]+[yy xx],[1 2],1)+1.05*namp*randn(40,120);

subplot(223)
show(im1)
subplot(224)
show(im2)

dxy1h=urapiv3(im1,im2);
tmpdxy1h=simple_piv(im1,im2);


disp(sprintf('  bot: d0=[%.2f,%.2f], e1=[%.2f,%.2f], err=%.2f',real(dxy0),imag(dxy0),real(dxy1h),imag(dxy1h),abs(dxy0-dxy1h))),
disp(sprintf('  bot: d0=[%.2f,%.2f], e2=[%.2f,%.2f], err=%.2f',real(dxy0),imag(dxy0),real(tmpdxy1h),imag(tmpdxy1h),abs(dxy0-tmpdxy1h))),

end;

