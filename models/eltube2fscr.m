
clear all

r=[0:100e-6/100:100e-6];
x=[0:100e-6:500*100e-6];

t=[0:1:100];
u1=rect(t,6,13);
ue1=rect(t,8,16);
%u1=zeros(size(t)); ue1=u1;
%u1(11:15)=ones([1 5]);
%ue1(13:19)=ones([1 7]);

[s11,v11,f11,p11,e11]=eltube2f(u1,ue1,t,x,[0 1.0]);
[s12,v12,f12,p12,e12]=eltube2f(u1,ue1,t,x,[0 0.5]);

u2=rect(t,8,14);
ue2=rect(t,10,17);
u31=rect(t,4,12);
u32=rect(t,4,16);
ue31=rect(t,6,15);
ue32=rect(t,6,21);
%u2=zeros(size(t)); ue2=u2;
%u2(11:20)=ones([1 10]);
%ue2(13:26)=ones([1 14]);
%u3=zeros(size(t)); ue3=u3;
%u3(16:20)=ones([1 5]);
%ue3(18:24)=ones([1 7]);

[s21,v21,f21,p21,e21]=eltube2f(u2,ue2,t,x,[0 1.0]);
[s31,v31,f31,p31,e31]=eltube2f(u31,ue31,t,x,[0 1.0]);
[s32,v32,f32,p32,e32]=eltube2f(u32,ue32,t,x,[0 1.0]);

u4=rect(t,6,25);
ue41=rect(t,8,28);
ue42=rect(t,8,31);
%u4=zeros(size(t)); ue41=u4; ue42=u4;
%u4(25:29)=ones([1 5]);
%ue41(27:33)=ones([1 7]);
%ue42(30:36)=ones([1 7]);

[s41,v41,f41,p41,e41]=eltube2f(u4,ue41,t,x,[0 1.0]);
[s42,v42,f42,p42,e42]=eltube2f(u1+u4,ue1+ue42,t,x,[0 1.0]);

ti=[t(1):.1:t(length(t))];
s12i=ishift(interp1(t,s12,ti),-2);

figure(1)
plot(t,s11./max(s11),ti,s12i./max(s12i),'--')
fatlines
dofontsize(16);
grid
xlabel('Time')
ylabel('Signal')
axis([5 30 -.1 1.05])
figure(2)
plot(t,s42-s11,t,s41,'--')
fatlines
dofontsize(16);
grid
xlabel('Time') 
ylabel('Signal')
axis([15 40 -5e-3 15e-3])
figure(3)
plot(t,s21./max(s21),t,(s31+s32)./max(s31+s32),'--')
fatlines
dofontsize(16);
grid
xlabel('Time')
ylabel('Signal')
axis([5 40 -.1 1.05])

