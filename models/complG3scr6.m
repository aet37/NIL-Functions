

%load /net/stanley/home/towi/matlab/workdata/cohenData
load co2_4vals tt1 avgE1 avgC1 
%co2scr6,

dt=1/(20*60);
tfin1=tt1(end)/60;

tt1=tt1/60;


opt2=optimset('lsqnonlin');


% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
xg=[ 1    1    3   2.50  0     1    60   0.64   0.00  1.5/60 0.0223 1.51/60 12.8 0.54];
xl=[0.1  0.1  0.5  0.1     0    0.0  55.0  0.1   0  0.1/60 1e-5 0.1/60 0 0.2];
xu=[100  100  100  100    100    5   68.0  7.0   2    5/60 2  10/60 200 0.7];

tparms=[dt tfin1 2];
%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
parms2fit=[3 6 11 12];
%parms2fit=[3 6 7];

t=[0:tparms(1):tparms(2)];
avgC1i=interp1(tt1,avgC1,t);
avgE1i=interp1(tt1,avgE1,t);

xx=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,[avgC1;avgE1],tt1);
[yy,uu,u1,t]=complG3f(xx,tparms,xg,parms2fit);
ee=sum(sum(([avgC1i;avgE1i]-yy).^2))/(2*length(t));
een=[(avgC1i-yy(1,:))/(max(avgC1i)-1);(avgE1i-yy(2,:))/(max(avgE1i)-1)];
een=sum(sum(een.^2))/(2*length(t));

morefits=0;
if (morefits),
parms2fit2=[3 4 5 6 7 8 9];
xx2=lsqnonlin(@complG3f,xg(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,tparms(1:2),xg,parms2fit2,[avgC1],tt1);
parms2fit2b=[11 12 13 14];
xx2b=lsqnonlin(@complG3f,xg(parms2fit2b),xl(parms2fit2b),xu(parms2fit2b),opt2,[tparms(1:2) 1],xg,parms2fit2b,[avgE1],tt1);
xg2=xg;
parms2fit2c=[parms2fit2 parms2fit2b];
xx2c=[xx2 xx2b];
[yy2,uu2,u2,t]=complG3f(xx2c,tparms,xg2,parms2fit2c);
ee2=sum(sum(([avgC1i;avgE1i]-yy).^2))/(2*length(t));

parms2fit3=[3 4 5 6 7 9 11 12 13 14];
xx3=lsqnonlin(@complG3f,xg(parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,[tparms(1:2) 1],xg,parms2fit,[avgE1],tt1);
[yy3,uu3,u3,t]=complG3f(xx3,tparms,xg,parms2fit3);
ee3=sum(([avgE1i]-yy3).^2)/(length(t));
end;

%ee=sum((avgE4i-yy).^2)/length(t);
%ee2=sum((avgE4bi-yy2).^2)/length(t);
%ee3=sum((avgE4ci-yy3).^2)/length(t);


subplot(211)
plot(tt1,avgC1,'b--',t,yy(1,:),'b-')
ylabel('FAIR Signal'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Normo Fit')
subplot(212)
plot(tt1,avgE1,'b--',t,yy(2,:),'b-')
ylabel('BOLD Signal'), xlabel('Time (s)'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Normo Fit')

if (morefits),
subplot(211)
plot(tt1,avgC1,'b--',t,yy(1,:),'b-',t,yy2(1,:),'g-',t,yy3(1,:),'r-')
ylabel('FAIR Signal'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Normo Fit','Normo Fit2','Normo Fit3')
subplot(212)
plot(tt1,avgE1,'b--',t,yy(2,:),'b-',t,yy2(2,:),'g-',t,yy3(2,:),'g-')
ylabel('BOLD Signal'), xlabel('Time (s)'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Normo Fit','Normo Fit2','Normo Fit3')
end;

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

