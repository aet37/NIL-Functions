

%load /net/stanley/home/towi/matlab/workdata/cohenData
load co2_4vals tt1 avgE1 avgC1
load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b
load co2_4vals tt3 avgE3 avgE3b avgC3 avgC3b
%co2scr6,

dt=1/(20*60);
tfin1=tt1(end)/60;
tfin2=tt2(end)/60;
tfin3=tt3(end)/60;

tt1=tt1/60;
tt2=tt2/60;
tt3=tt3/60;


opt2=optimset('lsqnonlin');
opt2.TolX=1e-8;
opt2.TolPCG=1e-2;
opt2.TolFun=1e-8;
opt2.DiffMinChange=1e-10;


% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
%xg=[ 1    1    3   2.0    0    1    12   0.636  0.00  1.5/60 0.0347 2.0601/60 11.5 0.6807 3.0  28e-3];
%xg=[ 1    1    3   2.0    0    1    12   0.636  0.00  1.5/60 0.0339 1.3620/60 11.5 0.6995 3.0  28e-3];
xg=[ 1    1    3   2.0    0    1    12   0.636  0.00  1.5/60 0.0334 1.2929/60 11.5 0.7100 3.0  28e-3];
xl=[0.1  0.1  0.1  0.1     0    0.0  11.0  0.50   0  0.1/60 0.0010 0.20/60 0.1 0 0.2   1.5  10e-3];
xu=[100  100  100  100    100    5   13.5  0.75  2    5/60 0.1000  5.00/60 200.0 0.8   7.0  40e-3];

%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
%parms2fit=[3 6 7 8 9 11 12 13 14];
parms2fit=[3 6 7 8 9 13];			% 2nd pass parameters 
%parms2fit2=parms2fit;
parms2fit2=[3 6 13];				% Official NIMG submission
parms2fit2=[3 13];				% modification for resub
doadjust=1;

xg1=xg; xl1=xl; xu1=xu;
xg2=xg; xl2=xl; xu2=xu; xg2b=xg;
xg3=xg; xl3=xl; xu3=xu; xg3b=xg;


tparms1=[dt tfin1 1];
tparms2=[dt tfin2 1];
tparms3=[dt tfin3 1];

t1=[0:tparms1(1):tparms1(2)];
t2=[0:tparms2(1):tparms2(2)];
t3=[0:tparms3(1):tparms3(2)];

avgC1i=interp1(tt1,avgC1,t1);
avgE1i=interp1(tt1,avgE1,t1);
avgC2i=interp1(tt2,avgC2,t2);
avgC2bi=interp1(tt2,avgC2b,t2);
avgE2i=interp1(tt2,avgE2,t2);
avgE2bi=interp1(tt2,avgE2b,t2);
avgC3i=interp1(tt3,avgC3,t3);
avgC3bi=interp1(tt3,avgC3b,t3);
avgE3i=interp1(tt3,avgE3,t3);
avgE3bi=interp1(tt3,avgE3b,t3);


xg1(7)=60; xl1(7)=58; xu1(7)=64;
xx1=lsqnonlin(@complG3f,xg1(parms2fit),xl1(parms2fit),xu1(parms2fit),opt2,tparms1,xg1,parms2fit,[avgE1],tt1);
xx1new=xx1; load /Users/towi/Documents/Publications/VascularDynamics-Figures/complG3s4Bfix2 xx1
yy1=complG3f(xx1,tparms1,xg1,parms2fit);
ee1n=[(avgE1i-yy1)/(max(avgE1i)-1)];
ee1n=(sum(ee1n.^2))/(2*length(t1));
xg1(parms2fit)=xx1;

xg2(7)=12; xl2(7)=11; xu2(7)=14.0; 
xx2=lsqnonlin(@complG3f,xg2(parms2fit),xl2(parms2fit),xu2(parms2fit),opt2,tparms2,xg2,parms2fit,[avgE2],tt2);
xx2new=xx2; load /Users/towi/Documents/Publications/VascularDynamics-Figures/complG3s4Bfix2 xx2
yy2=complG3f(xx2,tparms2,xg2,parms2fit);
ee2n=[(avgE2i-yy2)/(max(avgE2i)-1)];
ee2n=(sum(ee2n.^2))/(2*length(t2));
xg2(parms2fit)=xx2;

xg2b(7)=12; xl2(7)=11; xu2(7)=14.0;
xg2b(parms2fit)=xx2;
if (doadjust),
  xg2b(14)=1-(1-xg2b(14))^(1/1.10);
  xg2b(12)=xg2b(12)*(1.10^0.4)/1.10;
  xg2b(11)=xg2b(11)*(1.10^0.4);
end;
xx2b=lsqnonlin(@complG3f,xg2b(parms2fit2),xl2(parms2fit2),xu2(parms2fit2),opt2,tparms2,xg2b,parms2fit2,[avgE2b],tt2);
yy2b=complG3f(xx2b,tparms2,xg2b,parms2fit2);
ee2bn=[(avgE2bi-yy2b)/(max(avgE2bi)-1)];
ee2bn=(sum(ee2bn.^2))/(2*length(t2));
xg2b(parms2fit2)=xx2b;

xg3(7)=6; xl3(7)=5; xu3(7)=8.0; 
xx3=lsqnonlin(@complG3f,xg3(parms2fit),xl3(parms2fit),xu3(parms2fit),opt2,tparms3,xg3,parms2fit,[avgE3],tt3);
xx3new=xx3; load /Users/towi/Documents/Publications/VascularDynamics-Figures/complG3s4Bfix2 xx3
yy3=complG3f(xx3,tparms3,xg3,parms2fit);
ee3n=[(avgE3i-yy3)/(max(avgE3i)-1)];
ee3n=(sum(ee3n.^2))/(2*length(t3));
xg3(parms2fit)=xx3;

xg3b(7)=6; xl3(7)=5; xu3(7)=8.0; 
xg3b(parms2fit)=xx3;
if (doadjust),
  xg3b(14)=1-(1-xg3b(14))^(1/1.10);
  xg3b(12)=xg3b(12)*(1.10^0.4)/1.10;
  xg3b(11)=xg3b(11)*(1.10^0.4);
end;
xx3b=lsqnonlin(@complG3f,xg3b(parms2fit2),xl3(parms2fit2),xu3(parms2fit2),opt2,tparms3,xg3b,parms2fit2,[avgE3b],tt3);
yy3b=complG3f(xx3b,tparms3,xg3b,parms2fit2);
ee3bn=[(avgE3bi-yy3b)/(max(avgE3bi)-1)];
ee3bn=(sum(ee3bn.^2))/(2*length(t3));
xg3b(parms2fit2)=xx3b;

[xg1;xg2;xg2b;xg3;xg3b],

err1=sum((avgE1i-yy1).^2)/length(avgE1i);
err2=sum((avgE2i-yy2).^2)/length(avgE2i);
err2b=sum((avgE2bi-yy2b).^2)/length(avgE2bi);
err3=sum((avgE3i-yy3).^2)/length(avgE3i);
err3b=sum((avgE3bi-yy3b).^2)/length(avgE3bi);

%figure(1)
subplot(311)
plot(tt1*60,avgE1,'b--',t1*60,yy1,'b-')
ylabel('BOLD'), %xlabel('Time (s)'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Normo Fit')

subplot(312)
plot(tt2*60,avgE2,'b--',tt2*60,avgE2b,'m--',t2*60,yy2,'b-',t2*60,yy2b,'m-')
ylabel('BOLD'), %xlabel('Time (s)'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Hyper Data','Normo Fit','Hyper Fit')

subplot(313)
plot(tt3*60,avgE3,'b--',tt3*60,avgE3b,'m--',t3*60,yy3,'b-',t3*60,yy3b,'m-')
ylabel('BOLD'), xlabel('Time (s)'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Hyper Data','Normo Fit','Hyper Fit')



