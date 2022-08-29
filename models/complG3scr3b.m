
clear all

load /net/stanley/home/towi/matlab/workdata/cohenData
tt0=-3.330;
ttf=41.292;
dtt=0.3330;

%load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b tt2
tt4=(tt-tt(1))/60;
avgE4=1+normocapnia'/100;
avgE4b=1+hypercapnia'/100;
avgE4c=1+hypocapnia'/100;

dt=1/(20*60);
tfin4=(ttf-tt0)/60;

opt2=optimset('lsqnonlin');


% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
xg=[ 1    1    3   0.1   0     5    4.0  0.70   0   1.5/60 0.015 1/60 14 0.68];
xl=[0.1  0.1  0.5  0.1     0    2.0  3.0  0.4   0  0.1/60 1e-5 0.1/60 0 0.2];
xu=[100  100  100  100    100    7    8.0  0.9   2    5/60 2  10/60 200 0.7];

tparms=[dt tfin4 1];
%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
parms2fit=[3 6 13];
%parms2fit=[3 6 7];

t=[0:tparms(1):tparms(2)];
avgE4i=interp1(tt4,avgE4,t);
avgE4bi=interp1(tt4,avgE4b,t);
avgE4ci=interp1(tt4,avgE4c,t);
W4=ones(size(avgE4i));

xg1=xg;
xg2=xg;
xg3=xg;

xg2(14)=1-(1-xg(14))^(1/1.27);
xg2(12)=xg(12)*(1.27^0.4)/1.27;
xg3(14)=1-(1-xg(14))^(1/0.75);
xg3(12)=xg(12)*(0.75^0.4)/0.75;


xx=lsqnonlin(@complG3fm2,xg(parms2fit),xl(parms2fit2),xu(parms2fit2),opt2,tparms,[xg1;xg2;xg3],parms2fit,[avgE4i;avgE4bi;avgE4ci],[W4;W4;W4]);

xg1o=xg1;
xg2o=xg2;
xg3o=xg3;
xg1o(parms2fit)=xx;
xg2o(parms2fit)=xx;
xg3o(parms2fit)=xx;

yy1=complG3f(xg1(parms2fit),tparms,xg1,parms2fit(1:end-3));
yy2=complG3f(xg2(parms2fit),tparms,xg2,parms2fit(1:end-3));
yy3=complG3f(xg3(parms2fit),tparms,xg3,parms2fit(1:end-3));

ee1n=(avgE4i-yy1)/(max(avgE4i)-1);
ee1n=sum(ee1n.^2)/length(t);
ee2n=(avgE4bi-yy2)/(max(avgE4bi)-1);
ee2n=sum(ee2n.^2)/length(t);
ee3n=(avgE4ci-yy3)/(max(avgE4ci)-1);
ee3n=sum(ee3n.^2)/length(t);


subplot(211)
plot(tt4*60+tt0,avgE4,'b--',tt4*60+tt0,avgE4b,'r--',t*60+tt0,yy,'b',t*60+tt0,yy2,'r')
ylabel('BOLD Signal'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Hyper Data','Normo Fit','Hyper Fit')
subplot(212)
plot(tt4*60+tt0,avgE4,'b--',tt4*60+tt0,avgE4c,'g--',t*60+tt0,yy,'b',t*60+tt0,yy3,'g')
ylabel('BOLD Signal'), xlabel('Time (s)'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Hypo Data','Normo Fit','Hypo Fit')


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

