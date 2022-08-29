
clear all

dt=0.01;
t=[0:dt:100]; t=t(:);

nl=0.01;					% noise level
num2=[1 0.02];
den2=conv([1 0.2],[1 0.05]);

a=mytrapezoid(t,2*dt,4*dt,dt); a=a(:);		% i: impulse response approximation
u=mytrapezoid(t,2,20,dt); u=u(:);		% u: input stimulus
v=u+nl*randn(size(u));				% v: input stimulus (with noise)

tau1=1;
tau2=8;
g=zeros(size(u));
h=zeros(size(u));
x=zeros(size(u));
y=zeros(size(u));
for mm=2:length(u),
  g(mm)=g(mm-1)+(dt/tau1)*( a(mm-1) - g(mm-1) );	% g: impulse response function of measurement
  x(mm)=x(mm-1)+(dt/tau1)*( u(mm-1) - x(mm-1) );	% x: desired measurement
  h(mm)=h(mm-1)+(dt/tau2)*( a(mm-1) - h(mm-1) );	% h: impulse response function of system
  y(mm)=y(mm-1)+(dt/tau2)*( x(mm-1) - y(mm-1) );	% y: output response
end;
w=x+nl*randn(size(x));					% w: measurement (with noise)
z=y+nl*randn(size(y));					% z: output response (with noise)

x2=x;
w2=w;
h2=mysol(num2,den2,a,t);		% h2: impulse response function of higher-order system
y2=myconv(x2,h2); y2=y2(:);	 	% y2: higher-order output response
z2=y2+nl*randn(size(y2));		% z2: higher-order output response (with noise)

% fourier transform
zf=fft(z);
hf=fft(h);
xf=fft(x);

z2f=fft(z2);
h2f=fft(h2);
x2f=fft(x2);

% estimate h by fourier deconvolutionn
xdf=zf./hf;
x2df=z2f./h2f;

% filter estimate
fpp=100;
filt1=[ones(1,fpp) zeros(1,length(xdf)-2*fpp) ones(1,fpp)]; filt1=filt1(:);
xdf=xdf.*filt1;
x2df=x2df.*filt1;

xd=real(ifft(xdf));
x2d=real(ifft(x2df));


% plot 
figure(1)
subplot(311)
plot(t,h,t,u*max(h))
%plot(t,h2,t,u*max(h2))
grid('on'); axis('tight');
ylabel('H')
subplot(312)
plot(t,z)
%plot(t,z2)
grid('on'); axis('tight');
ylabel('Y_n')
subplot(313)
plot(t,xd/max(xd),t,x/max(x))
%plot(t,x2d/max(x2d),t,x2/max(x2))
ylabel('X_D')
grid('on'); axis('tight');

figure(2)
subplot(311)
plot([abs(zf)])
%plot([abs(z2f)])
ax=axis; ax(2)=round(ax(2)/2); ax(4)=1; 
axis(ax); grid('on');
ylabel('F[ Y ]')
subplot(312)
plot([abs(hf)])
%plot([abs(h2f)])
ax=axis; ax(2)=round(ax(2)/2); ax(4)=1; 
axis(ax); grid('on');
ylabel('F[ H ]')
subplot(313)
plot([abs(xdf) abs(xf)])
%plot([abs(x2f) abs(xf)])
ax=axis; ax(2)=round(ax(2)/2); ax(4)=10; 
axis(ax); grid('on');
ylabel('F[ X_D ]')


