
clear all

nspins=1e3;

TR=50e-3;
ts=40*4e-6;
tt=[0:ts:TR]';

% gradients
mydelta1=1e-3;		% gradient duration
mydelta2=3e-3;		% gradient separation (start-to-start)
Gamp=2.00;		% G/cm
Gx=zeros(size(tt));
Gy=zeros(size(tt));
Gz=Gamp*rect(tt,mydelta1,mydelta1)-Gamp*rect(tt,mydelta1,mydelta1+mydelta2);
Gz=Gz.';
%bval=(1/100)*(26752*26752/(4*pi*pi))*mydelta1*mydelta1*Gamp*Gamp*(mydelta2-mydelta1/3);	% s/mm2
bval=(1/100)*(26752*26752)*mydelta1*mydelta1*Gamp*Gamp*(mydelta2-mydelta1/3);	% s/mm2
venc=(2*pi)/(26752*Gamp*mydelta1*mydelta2);	% rad / rad/Gs G/cm s s = cm/s

%lamv_vec=[5e-3:5e-3:100e-3];
lamv_vec=[1e-3:1e-3:200e-2];	% cm/2 0.01 to 20
for mm=1:length(lamv_vec);
disp(sprintf('Vel(%d)= %f cm/s',mm,lamv_vec(mm)));

% initial position and velocity
theta=0; phi=pi/2;
lamv=lamv_vec(mm);
lampdf=(1-[0:1e-3:1].*[0:1e-3:1]); 
lampdf=(-0.5*[1:nspins]+700);
lampdf=lampdf/sum(lampdf);
lamdist=ran_dist([lampdf]',rand([nspins 1]));
radpdf=lampdf([end:-1:1]); radpdf=radpdf/sum(radpdf);
raddist=ran_dist([radpdf]',rand([nspins 1]));
dz=5e-3; rad=200e-6;
dr=rad*raddist;
dth=2*pi*rand([nspins 1]);
dax=dz*rand([nspins 1]);
r0(:,1)=(dr.*cos(dth));				% need a rotation here
r0(:,2)=(dr.*sin(dth));
r0(:,3)=(dax);
v(:,1)=lamv*cos(theta)*cos(phi)*lamdist;	% rotation may not be needed here
v(:,2)=lamv*sin(theta)*cos(phi)*lamdist;
v(:,3)=lamv*sin(phi)*lamdist;
vmag=((sum((v.^2)')).^(0.5))';

% select certain spins
if ((sum(vmag)==0)|((sum(vmag)/nspins)==vmag(1))),
  ii=[1 2 3];
else,
  [vmax,vmaxi]=max(vmag);
  [vmin,vmini]=min(vmag);
  tmp=find(vmag>=((vmax-vmin)/2+vmin));
  vmidi=tmp(1);
  vmid=vmag(vmidi);
  ii=[vmini vmidi vmaxi];
end;

% initial signal mag/phase per spin after the RF pulse
S=ones([nspins 1])+i*zeros([nspins 1]);

% numerical integration of the phase/gradient expression
disp('Simulating...');
for m=1:nspins,
  xx=movspin(tt,100*ones([length(tt) 1])*v(m,:),100*ones([length(tt) 1])*r0(m,:));
  if (m==ii(1)), xxi(:,:,1)=xx;
  elseif (m==ii(2)), xxi(:,:,2)=xx;
  elseif (m==ii(3)), xxi(:,:,3)=xx;
  end;
  phs1(:,m)=movspinphs([Gx Gy Gz],xx,tt);
  fprintf('\r%d/%d',m,nspins)
end;
St=(1/nspins)*abs( sum( exp(i*phs1') ) );
phsi=phs1(:,ii);
Sti=exp(i*phsi);

VVmax(mm)=lamv;
VVmean(mm)=mean(vmag);
Send(mm)=St(end);

disp(sprintf('\n s(t=end)= %f  venc(b-val)= %f(%f)  meanVel= %f',St(end),venc,bval,mean(vmag)));

end;

pfc=polyfit(Send,VVmax,5);
[polyval(pfc,0.15) polyval(pfc,0.50)],
pfc=polyfit(Send,VVmean,5);
[polyval(pfc,0.15) polyval(pfc,0.50)],

pfc=polyfit(VVmean,Send,5);
Sfit=polyval(pfc,VVmean);
polyval(pfc,0.01),


clear phs1 xx

figure(1),clf,
plot(VVmean,Send,VVmean,Sfit)
xlabel('Mean Velocity (m/s)')
ylabel('Signal')
grid
figure(2)
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
figure(3)
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


