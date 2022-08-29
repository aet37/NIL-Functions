

%load /net/stanley/home/towi/matlab/workdata/cohenData
%load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b tt2
co2scr6,
load cbvscr1b tv3 avgVV3a avgVV3b
avgVV3a=avgVV3a'; avgVV3b=avgVV3b';

dt=1/(20*60);
tfin1=tt1(end)/60;

tt1=tt1/60;


opt2=optimset('lsqnonlin');


% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
xg=[ 1    1    3   2.3  0     1    60   0.68   0.00  1.5/60 0.0197 1.1/60 09.6 0.67];
xl=[0.1  0.1  0.5  0.1     0    0.0  55.0  0.1   0  0.1/60 1e-5 0.1/60 0 0.2];
xu=[100  100  100  100    100    5   68.0  7.0   2    5/60 2  10/60 200 0.7];

tparms=[dt tfin1];
%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
parms2fit=[3 6 8 9];
%parms2fit=[3 6 7];

t=[0:tparms(1):tparms(2)];
avgV1i=interp1(tt1,avgV1,t);
avgVV3ai=interp1(tt1,avgVV3a,t);

xx=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,[avgV1],tt1);
[yy,uu,u1,t]=complG3f(xx,tparms,xg,parms2fit);
ee=sum(sum(([avgV1i]-yy).^2))/(length(t));

parms2fit2=[3 4 5 6 7 8 9];
xx2=lsqnonlin(@complG3f,xg(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,tparms,xg,parms2fit2,[avgVV3a],tt1);
[yy2,uu2,u2,t]=complG3f(xx2,tparms,xg,parms2fit2);
ee2=sum(sum(([avgVV3ai]-yy).^2))/(length(t));


subplot(211)
plot(tt1,avgV1,'b--',t,yy(1,:),'b-')
ylabel('AVIS Signal'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Normo Fit')
subplot(212)
plot(tt1,avgVV3a,'b--',t,yy2(1,:),'b-')
ylabel('AVIS Signal'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Normo Fit')


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

