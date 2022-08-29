
clear all

load /net/stanley/home/towi/matlab/workdata/cohenData
tt0=-3.330;
ttf=41.292;
dtt=0.3330;

%load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b tt2
tt4=(tt-tt(1));
avgE4=1+normocapnia'/100;
avgE4b=1+hypercapnia'/100;
avgE4c=1+hypocapnia'/100;

dt=1/20;
tfin4=(ttf-tt0);

t=[0:dt:tfin4];
avgE4i=interp1(tt4,avgE4,t);
avgE4bi=interp1(tt4,avgE4b,t);
avgE4ci=interp1(tt4,avgE4c,t);
W4=ones(size(avgE4i));

u4=mytrapezoid(t,0.1,4,0.1);


opt2=optimset('lsqnonlin');



%xg=[3.7   0.1   6.0   0.070  0.200  0.270  0.0040];
%xg=[3.7   0.1   6.1   0.064  0.153  0.332  0.0016];
xg=[3.7   0.1   5.7   0.028  0.123  0.302  0.0017];
xl=[0.0   0.0   0.1    1e-5   1e-5   1e-5   1e-7];
xu=[6.0   4.0   12.0    10.0   1000   1000   10000];

%parms2fit=[1 3 4 5 6 7];
parms2fit=[1 3 7];

xtyp=xg;
opt2.TypicalX=xtyp(parms2fit);
opt2.TolX=1e-8;
opt2.TolPCG=1e-2;
opt2.TolFun=1e-8;
opt2.DiffMinChange=1e-10;

xx1=lsqnonlin(@lin41,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,u4,xg,parms2fit,[avgE4i],[W4]);
xx2=lsqnonlin(@lin41,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,u4,xg,parms2fit,[avgE4bi],[W4]);
xx3=lsqnonlin(@lin41,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,u4,xg,parms2fit,[avgE4ci],[W4]);
%xx=xg(parms2fit);

[yy1,ww1,vv1]=lin41(xx1,t,u4,xg,parms2fit);
[yy2,ww2,vv2]=lin41(xx2,t,u4,xg,parms2fit);
[yy3,ww3,vv3]=lin41(xx3,t,u4,xg,parms2fit);

err1n=sum((avgE4i'-yy1).^2)/length(t)/max(avgE4i-1);
err2n=sum((avgE4bi'-yy2).^2)/length(t)/max(avgE4bi-1);
err3n=sum((avgE4ci'-yy3).^2)/length(t)/max(avgE4ci-1);

figure(1)
subplot(211)
plot(t,avgE4i,'b--',t,yy1,'b-',t,avgE4bi,'r--',t,yy2,'r-')
ylabel('BOLD Signal'),
legend('Normo Data','Normo Fit','Hyper Data','Hyper Fit')
axis('tight'), grid('on'),
fatlines, dofontsize(15);

subplot(212)
plot(t,avgE4i,'b--',t,yy1,'b-',t,avgE4ci,'g--',t,yy3,'g-')
ylabel('BOLD Signal'), xlabel('Time (s)'),
axis('tight'), grid('on'),
legend('Normo Data','Normo Fit','Hypo Data','Hypo Fit')
fatlines, dofontsize(15);


