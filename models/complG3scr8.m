

%load /net/stanley/home/towi/matlab/workdata/cohenData
%load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b tt2
co2scr6,
avgV2=avgV2-avgV2(1)+1;
avgV2b=avgV2b-(avgV2b(1)-1)/2;

dt=1/(20*60);
tfin2=tt2(end)/60;

tt2=tt2/60;


opt2=optimset('lsqnonlin');


% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
xg=[ 1    1    3   2.4   0     1    12   0.65   0   1.5/60 0.022 1.1/60 13.9 0.35];
xl=[0.1  0.1  0.5  0.1     0    0.0  9.0  0.1   0  0.1/60 1e-5 0.1/60 0 0.2];
xu=[100  100  100  100    100    5   16.0  7.0   4    5/60 2  10/60 200 0.7];

tparms=[dt tfin2];
%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
parms2fit=[3 6 8 9];
%parms2fit=[3 6 7];

t=[0:tparms(1):tparms(2)];
avgV2i=interp1(tt2,avgV2,t);
avgV2bi=interp1(tt2,avgV2b,t);

xx=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,[avgV2],tt2);
[yy,uu,u1,t]=complG3f(xx,tparms,xg,parms2fit);
ee=sum(sum(([avgV2i]-yy).^2))/(2*length(t));

xx2=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,[avgV2b],tt2);
[yy2,uu2,u2,t]=complG3f(xx2,tparms,xg,parms2fit);
ee2=sum(sum(([avgV2bi]-yy2).^2))/(2*length(t));

%ee=sum((avgE4i-yy).^2)/length(t);
%ee2=sum((avgE4bi-yy2).^2)/length(t);
%ee3=sum((avgE4ci-yy3).^2)/length(t);


subplot(211)
plot(tt2,avgV2,'b--',tt2,avgV2b,'r--',t,yy(1,:),'b-',t,yy2(1,:),'r-')
ylabel('AVIS Signal'),
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

