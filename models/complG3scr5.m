

%load /net/stanley/home/towi/matlab/workdata/cohenData
load co2_4vals tt3 avgE3 avgE3b avgC3 avgC3b
%co2scr6,
%avgE3b=avgE3b-(avgE3b(1)-avgE3(1));

dt=1/(20*60);
tfin3=tt3(end)/60;

tt3=tt3/60;


opt2=optimset('lsqnonlin');


% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
xg=[ 1    1    3   2.5  0     1    6   0.62   0.00  1.5/60 0.0237 1.22/60 11.5 0.68];
xl=[0.1  0.1  0.2  0.1     0    0.0  5.0  0.5   0  0.1/60 0.0222 0.98/60 9.2 0.2];
xu=[100  100  100  100    100    5   7.5  0.75  2    5/60 0.0346  1.46/60 13.8 0.7];

tparms=[dt tfin3 2];
%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
parms2fit=[3 6 8 9 12 13];
%parms2fit=[3 6 7];

t=[0:tparms(1):tparms(2)];
avgC3i=interp1(tt3,avgC3,t);
avgC3bi=interp1(tt3,avgC3b,t);
avgE3i=interp1(tt3,avgE3,t);
avgE3bi=interp1(tt3,avgE3b,t);

xx=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,[avgC3;avgE3],tt3);
[yy,uu,u1,t]=complG3f(xx,tparms,xg,parms2fit);
ee=sum(sum(([avgC3i;avgE3i]-yy).^2))/(2*length(t));
een=[(avgC3i-yy(1,:))/(max(avgC3i)-1);(avgE3i-yy(2,:))/(max(avgE3i)-1)];
een=sum(sum(een.^2))/(2*length(t));

xx2=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,[avgC3b;avgE3b],tt3);
[yy2,uu2,u2,t]=complG3f(xx2,tparms,xg,parms2fit);
ee2=sum(sum(([avgC3bi;avgE3bi]-yy2).^2))/(2*length(t));
ee2n=[(avgC3bi-yy2(1,:))/(max(avgC3bi)-1);(avgE3bi-yy2(2,:))/(max(avgE3bi)-1)];
ee2n=sum(sum(ee2n.^2))/(2*length(t));

%ee=sum((avgE4i-yy).^2)/length(t);
%ee2=sum((avgE4bi-yy2).^2)/length(t);
%ee3=sum((avgE4ci-yy3).^2)/length(t);


subplot(211)
plot(tt3*60,avgC3,'b--',tt3*60,avgC3b,'r--',t*60,yy(1,:),'b-',t*60,yy2(1,:),'r-')
ylabel('FAIR Signal'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Hyper Data','Normo Fit','Hyper Fit')
subplot(212)
plot(tt3*60,avgE3,'b--',tt3*60,avgE3b,'r--',t*60,yy(2,:),'b-',t*60,yy2(2,:),'r-')
ylabel('BOLD Signal'), xlabel('Time (s)'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Hyper Data','Normo Fit','Hyper Fit')


%plot(t*60,myconv(mytrapezoid(t,0.1/60,11.9/60,0.1/60),(uu-1)/(max(uu)-1)))
%
%% input = convolution of Input*LPF and Response fiter
%plot(t*60,mytrapezoid(t,0.1/60,11.9/60,0.1/60),t*60,mytrapezoid(t,6/60,0.1/60,6/60))
%plot(t*60,myconv(mytrapezoid(t,0.1/60,0.1/60,0.1/60),mytrapezoid(t,0.1/60,8.0/60,0.1/60)))
%plot(t*60,myconv(mytrapezoid(t,0.1/60,11.9/60,0.1/60),mytrapezoid(t,0.1/60,8.0/60,0.1/60)))
%plot(t*60,myconv(mytrapezoid(t,0.1/60,11.9/60,0.1/60,[11 25 0.5/60 10/60]),mytrapezoid(t,0.1/60,8.0/60,0.1/60)))
%
%du=deconv(uu,mytrapezoid(t,0.1/60,11.9/60,0.1/60));
%

