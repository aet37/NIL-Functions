
clear 
load con_model_test

t=[1:.1:64];

u80=zeros(size(t));
u80(201:201+85)=ones([1 85+1]);
s80=buxton3(t,u80,[1 1 1],parms80);

u10=zeros(size(t));
u10(191:191+85)=ones([1 85+1]);
s10=buxton3(t,u10,[1 1 1],parms10);

plot([1:64],ad32_24(:,4),[1:64],ad32_24(:,1))
plot(t,100*0.08*s10(:,1),[1:64],100*ad32_24(:,1))
axis([1 64 -2 5])
xlabel('Time (s)')
ylabel('% Signal Change')
dofontsize(16),fatlines,grid
plot(t,100*0.08*s80(:,1),[1:64],100*ad32_24(:,4))
axis([1 64 -2 10])
xlabel('Time (s)')
ylabel('% Signal Change')
dofontsize(16),fatlines,grid,
plot(t,(0.08*s10(:,1))./max(0.08*s10(:,1)),t,0.08*s80(:,1)./max(0.08*s80(:,1)))
axis([1 64 -.4 1.1])
xlabel('Time (s)')
ylabel('Normalized Signal Change')
dofontsize(16),fatlines,grid
plot([1:64],ad32_24(:,4)./max(ad32_24(:,4)),[1:64],ad32_24(:,1)./max(ad32_24(:,1)))
axis([1 64 -.4 1.1])
xlabel('Time (s)')
ylabel('Normalized Signal Change')
dofontsize(16),fatlines,grid


clear
load temp_model_test

t=[1:.1:64];

u1=zeros(size(t));
u1(191:191+38)=ones([1 38+1]);
parms1(3)=1.0*0.64;
s1=buxton3(t,u1,[1 1 1],parms1);

u2=zeros(size(t));
u2(191:191+2*25)=ones([1 2*25+1]);
parms2(3)=0.7*0.64;
s2=buxton3(t,u2,[1 1 1],parms2);

u4=zeros(size(t));
u4(189:189+3*25)=ones([1 3*25+1]);
parms4(3)=0.7*0.87;
s4=buxton3(t,u4,[1 1 1],parms4);

u8=zeros(size(t));
u8(194:194+4*25)=ones([1 4*25+1]);
parms8(3)=0.7*1.00;
s8=buxton3(t,u8,[1 1 1],parms8);

a2to8=ishift(ad_13(:,2),0)+ishift(ad_13(:,2),2)+ishift(ad_13(:,2),4)+ishift(ad_13(:,2),6);
f2to8=ishift(s2(:,1),0)+ishift(s2(:,1),20)+ishift(s2(:,1),40)+ishift(s2(:,1),60);

plot(t,100*0.045*s2(:,1),[1:64],100*ad_13(:,2))
axis([1 64 -2 3])
xlabel('Time(s)')
ylabel('% Signal Change')
dofontsize(16),fatlines,grid
plot(t,100*0.033*s4(:,1),[1:64],100*ad_13(:,3))
axis([1 64 -1 4])
xlabel('Time(s)')
ylabel('% Signal Change')
dofontsize(16),fatlines,grid
plot(t,100*0.033*s8(:,1),[1:64],100*ad_13(:,4))
axis([1 64 -1.5 4.5])
xlabel('Time(s)')
ylabel('% Signal Change')
dofontsize(16),fatlines,grid
plot([1:64],100*ad_13(:,4),[1:64],100*a2to8)
axis([1 64 -5 6])
xlabel('Time(s)')
ylabel('% Signal Change')
dofontsize(16),fatlines,grid
plot(t,100*0.045*f2to8,t,100*0.033*s8(:,1))
axis([1 64 -3 5])
xlabel('Time(s)')
ylabel('% Signal Change')
dofontsize(16),fatlines,grid

