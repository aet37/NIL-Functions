
clear all

nspins=1e3;

TR=35e-3;
ts=40*4e-6;
tt=[0:ts:TR]';

% gradients
mydelta1=3e-3;
mydelta2=9e-3;
Gamp=3.91;              % G/cm
Gx=zeros(size(tt));
Gy=zeros(size(tt));
Gz=Gamp*rect(tt,mydelta1,mydelta1)-Gamp*rect(tt,mydelta1,mydelta1+mydelta2);
bval=(1/100)*(26752*26752/(4*pi*pi))*mydelta1*mydelta1*Gamp*Gamp*(mydelta2-mydelta1/3); % s/mm2

% initial position and velocity
theta=0; phi=pi/2;
lamv=1e-1;              % m/s
lampdf=(1-[0:1e-3:1].*[0:1e-3:1]); lampdf=lampdf/sum(lampdf);
lamdist=ran_dist([lampdf]',rand([nspins 1]));
radpdf=lampdf([end:-1:1]); radpdf=radpdf/sum(radpdf);
raddist=ran_dist([radpdf]',rand([nspins 1]));
dz=5e-3; rad=200e-6;
dr=rad*raddist;
dth=2*pi*rand([nspins 1]);
dax=dz*rand([nspins 1]);
r0(:,1)=(dr.*cos(dth));                         % need a rotation here
r0(:,2)=(dr.*sin(dth));
r0(:,3)=(dax);
v(:,1)=lamv*cos(theta)*cos(phi)*lamdist;        % rotation may not be needed here
v(:,2)=lamv*sin(theta)*cos(phi)*lamdist;
v(:,3)=lamv*sin(phi)*lamdist;

[St,Sti,phsi,xxi]=velspoilf(tt,v,r0,[Gx Gy Gz]);

clf
figure(1)
subplot(311)
plot(tt,St)
xlabel('Time'),ylabel('Signal')
subplot(325)
plot(tt,phsi)
xlabel('Time'),ylabel('Signal')
subplot(312)
plot(tt,Gx,tt,Gy,tt,Gz)
xlabel('Time'),ylabel('Gradient Amplitude')
subplot(326)
plot(tt,xxi(:,:,1),tt,xxi(:,:,2),tt,xxi(:,:,3))
xlabel('Time'), ylabel('Position')
figure(2)
clf
subplot(231)
hist(r0(:,1),floor(0.02*nspins))
xlabel('x0')
subplot(232)
hist(r0(:,2),floor(0.02*nspins))
xlabel('y0')
subplot(233)
hist(r0(:,3),floor(0.02*nspins))
xlabel('z0')
subplot(234)
hist(v(:,1),floor(0.02*nspins))
xlabel('Vx')
subplot(235)
hist(v(:,2),floor(0.02*nspins))
xlabel('Vy')
subplot(236)
hist(v(:,3),floor(0.02*nspins))
xlabel('Vz')

