
clear all

tt=[0:.1:70];

u1=rect(tt,4,12.0);
u2=rect(tt,4,32.0);
u3=u1+u2;

[ya1,yb1,yc1]=bux2f(tt,u1);
[ya2,yb2,yc2]=bux2f(tt,u2);
[ya3,yb3,yc3]=bux2f(tt,u3);

subplot(211)
plot(tt,ya2(:,1),tt,ya3(:,1))
axis([30 60 -0.5 1])
subplot(212)
plot(tt,yb2(:,1),tt,yb3(:,1))
axis([30 70 -0.5 1])

