

%load /net/stanley/home/towi/matlab/workdata/cohenData
%load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b tt2
co2scr6,

dt=1/(20*60);
tfin2=tt2(end)/60;

tt2=tt2/60;


opt2=optimset('lsqnonlin');


% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
xg=[ 1    1    3   2.7   0     1    12.0   0.71   0   1.5/60 0.022 1.1/60 17.6 0.32];
xl=[0.1  0.1  0.5  0.1     0    0.0  9.0  0.1   0  0.1/60 1e-5 0.1/60 0 0.2];
xu=[100  100  100  100    100    5   16.0  7.0   2    5/60 2  10/60 200 0.7];

tparms=[dt tfin2 1];
%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
parms2fit=[3 6]; 
%parms2fit=[3 6 7];

t=[0:tparms(1):tparms(2)];
avgC2i=interp1(tt2,avgC2,t);
avgC2bi=interp1(tt2,avgC2b,t);
avgE2i=interp1(tt2,avgE2,t);
avgE2bi=interp1(tt2,avgE2b,t);

xx=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms(1:2),xg,parms2fit,[avgC2],tt2);
[yy,uu,u1,t]=complG3f(xx,tparms(1:2),xg,parms2fit);
ee=sum(sum(([avgC2i]-yy).^2))/(2*length(t));

xx2=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms(1:2),xg,parms2fit,[avgC2b],tt2);
[yy2,uu2,u2,t]=complG3f(xx2,tparms(1:2),xg,parms2fit);
ee2=sum(sum(([avgC2bi]-yy2).^2))/(2*length(t));


%parms2fit2=[11 12 13 14];
parms2fit2=[12];

xg(parms2fit)=xx;
xx3=lsqnonlin(@complG3f,xg(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,tparms,xg,parms2fit2,[avgE2],tt2);
[yy3,uu3,u3,t]=complG3f(xx3,tparms,xg,parms2fit2);
eeb=sum(sum(([avgE2i]-yy3).^2))/(2*length(t));

xg(parms2fit)=xx2;
xx4=lsqnonlin(@complG3f,xg(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,tparms,xg,parms2fit2,[avgE2b],tt2);
[yy4,uu4,u4,t]=complG3f(xx4,tparms,xg,parms2fit2);
ee2b=sum(sum(([avgE2bi]-yy4).^2))/(2*length(t));

ee=0.5*(ee+eeb);
ee2=0.5*(ee2+ee2b);


subplot(211)
plot(tt2,avgC2,'b--',tt2,avgC2b,'r--',t,yy,'b-',t,yy2,'r-')
ylabel('FAIR Signal'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Hyper Data','Normo Fit','Hyper Fit')
subplot(212)
plot(tt2,avgE2,'b--',tt2,avgE2b,'r--',t,yy3,'b-',t,yy4,'r-')
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

