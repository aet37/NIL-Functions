
clear all
close all

imsize=[1024 1024];
nims=30;

dt=1;
tt=[0:nims-1]*dt;

r1=243;
a1=1.2;
x0=0; y0=0;

rr=1+gammafun(tt,5,2,2,0.2);
[~,r2i]=max(rr);

r2=r1*rr;
a2=sqrt( ((r1./r2).^2)*(a1^2 - 1) + 1 );

x1=[0:imsize(1)-1]-imsize(1)/2;
y1=[0:imsize(2)-1]-imsize(2)/2;
[xx,yy]=meshgrid(x1,y1');
rd=sqrt((xx-x0).^2+(yy-y0).^2);

im1=(rd<=r1*a1)-(rd<=r1);

ims=zeros(imsize(1),imsize(2),length(tt));
for mm=1:size(ims,3),
  ims(:,:,mm)=(rd<=r2(mm)*a2(mm))-(rd<=r2(mm));
end

dh1=10;
ii=find(abs(x1)<=dh1);
sh=squeeze(mean(mean(ims(ii,:,:),1),2));
ss=squeeze(mean(mean(ims,1),2));

figure(1), clf,
subplot(222), plot(tt,rr,tt,a2), axis tight, grid on, 
xlabel('Time'), ylabel('Radius'), legend('Inner Rad','Wall Th'),
subplot(221), show(ims(:,:,1)),
subplot(223), show(ims(:,:,r2i)),
subplot(224), plot(tt,sh/sh(1),tt,ss/ss(1)), axis tight, grid on,
xlabel('Time'), ylabel('Signal'), legend('slice','all'),

figure(2), clf,
subplot(311), plot(sh/sh(1),rr,'x'), axis tight, grid on,
xlabel('Signal'), ylabel('Radius (Inner)'),
subplot(312), plot(tt,ss/ss(1),tt,sh/sh(1),tt,(sh(:)/sh(1)).*[rr(:) rr(:).^2 sqrt(rr(:))]), axis tight, grid on,
xlabel('Time'), ylabel('Signal'), legend('all','actual','corr 1','corr 2','corr 1/2'),
subplot(313), plot(tt,sh/sh(1),tt,(sh(:)/sh(1))./[rr(:) rr(:).^2 sqrt(rr(:))]), axis tight, grid on,
xlabel('Time'), ylabel('Signal'), legend('actual','corr -1','corr -2','corr -1/2'),



dh=[10:20:500];
for nn=1:length(dh),
  ii=find(abs(x1)<=dh(nn)); iin(nn)=length(ii);
  ssh(:,nn)=squeeze(mean(mean(ims(ii,:,:),1),2));
  sss(:,nn)=squeeze(sum(sum(ims(ii,:,:),1),2));
  sse1=repmat(ssh(:,nn)/ssh(1,nn),[1 7]).*[ones(size(rr)) rr(:) rr(:).^2 rr(:).^0.5 rr(:).^-1 rr(:).^-2 rr(:).^-0.5];
  sse2(:,nn)=sum((ones(size(sse1))-sse1).^2,1)';
end;
ssh1=ssh./(ones(size(ssh,1),1)*ssh(1,:));
sss1=sss./(ones(size(sss,1),1)*sss(1,:));

figure(3), clf,
subplot(121), plot(tt,ssh1), axis tight, grid on,
subplot(122), plot(tt,sss1), axis tight, grid on,

for nn=1:length(dh),
figure(4), clf,
subplot(211), plot(tt,ss/ss(1),tt,ssh1(:,nn),tt,ssh1(:,nn).*[rr(:) rr(:).^2 sqrt(rr(:))]), axis tight, grid on,
xlabel('Time'), ylabel('Signal'), legend('all','actual','corr 1','corr 2','corr 1/2'),
subplot(212), plot(tt,ssh1(:,nn),tt,ssh1(:,nn)./[rr(:) rr(:).^2 sqrt(rr(:))]), axis tight, grid on,
xlabel('Time'), ylabel('Signal'), legend('actual','corr -1','corr -2','corr -1/2'),
drawnow,
pause,
end;

figure(5), clf,
plot(dh/r1,sse2'), axis tight, grid on, fatlines(1.5),
legend('no','1','2','+1/2','-1','-2','-1/2'), 


