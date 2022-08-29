
clear all

nspins=1e3;

TR=35e-3;
ts=40*4e-6;
tt=[0:ts:TR]';

% gradients
mydelta1=10e-3;
mydelta2=10e-3;
Gamp=2.20;              % G/cm
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
v(:,1)=cos(theta)*cos(phi)*lamdist;        % rotation may not be needed here
v(:,2)=sin(theta)*cos(phi)*lamdist;
v(:,3)=sin(phi)*lamdist;

lamv=[1e-3 5e-3 1e-2 5e-2 1e-1 5e-1];              % m/s

for m=1:length(lamv),
  St(:,m)=velspoilf(tt,lamv(m)*v,r0,[Gx Gy Gz]).';
end;

St(end,:),

clf
plot(tt,St)

