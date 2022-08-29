
clear all
close all

tt=[0:0.01:40];
t0=10.27; ww=9.63; rr=0.51;
%yy=mytrapezoid3(tt,t0,ww,rr);
yy=sin(2*pi*0.09*tt+pi/6).^4;

ta1=tt(1:50:3901);
ya1=yy(1:50:3901);
ta2=tt(24:50:3951);
ya2=yy(24:50:3951);

plot(ta1,[ya1(:) ya2(:)],tt,yy,'k')

ya2s=sincinterp1(ta2,ya2,ta1,3,2);
ya2l=interp1(ta2,ya2(:),ta1);

subplot(211),
%plot(tt,yy,ta1,ya2s,ta1,ya2l)
plot(ta1,ya1,ta1,ya2s,ta1,ya2l)
subplot(212),
plot([ya1(:)-ya2s(:) ya1(:)-ya2l(:)])



