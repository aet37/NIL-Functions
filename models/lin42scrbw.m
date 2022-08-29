
clear all

%load /net/stanley/home/towi/matlab/workdata/cohenData
load co2_4vals tt1 avgE1 avgC1 
load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b
load co2_4vals tt3 avgE3 avgE3b avgC3 avgC3b
%co2scr6,

dt=0.01;
tfin1=tt1(end);

t=[0:dt:tfin1];
avgC1i=interp1(tt1,avgC1,t);
avgE1i=interp1(tt1,avgE1,t);
avgC2i=interp1(tt2,avgC2,t);
avgC2bi=interp1(tt2,avgC2b,t);
avgE2i=interp1(tt2,avgE2,t);
avgE2bi=interp1(tt2,avgE2b,t);
avgC3i=interp1(tt3,avgC3,t);
avgC3bi=interp1(tt3,avgC3b,t);
avgE3i=interp1(tt3,avgE3,t);
avgE3bi=interp1(tt3,avgE3b,t);
avgC1i(find(isnan(avgC1i)))=1;
avgE1i(find(isnan(avgE1i)))=1;
avgC2i(find(isnan(avgC2i)))=1;
avgC2bi(find(isnan(avgC2bi)))=1;
avgE2i(find(isnan(avgE2i)))=1;
avgE2bi(find(isnan(avgE2bi)))=1;
avgC3i(find(isnan(avgC3i)))=1;
avgC3bi(find(isnan(avgC3bi)))=1;
avgE3i(find(isnan(avgE3i)))=1;
avgE3bi(find(isnan(avgE3bi)))=1;

W1=ones(size(t));
W2=ones(size(t));
W3=ones(size(t));
W1(find((t<tt1(1))|(t>tt1(end))))=0;
W2(find((t<tt2(1))|(t>tt2(end))))=0;
W3(find((t<tt3(1))|(t>tt3(end))))=0;
%W1=W1+mytrapezoid3(t,2*(t(2)-t(1)),60+14,2*(t(2)-t(1)));
%W2=W2+mytrapezoid3(t,2*(t(2)-t(1)),12+14,2*(t(2)-t(1)));
%W3=W3+mytrapezoid3(t,2*(t(2)-t(1)),06+14,2*(t(2)-t(1)));
%W1=W1+4*mytrapezoid3(t,2*(t(2)-t(1)),60+8,[2*(t(2)-t(1)) 8]);
%W2=W2+4*mytrapezoid3(t,2*(t(2)-t(1)),12+8,[2*(t(2)-t(1)) 8]);
%W3=W3+4*mytrapezoid3(t,2*(t(2)-t(1)),06+8,[2*(t(2)-t(1)) 8]);
W1=W1+2*mytrapezoid3(t,2*(t(2)-t(1)),74,2*(t(2)-t(1)));
W2=W2+2*mytrapezoid3(t,2*(t(2)-t(1)),24,2*(t(2)-t(1)));
W3=W3+2*mytrapezoid3(t,2*(t(2)-t(1)),16,2*(t(2)-t(1)));


opt2=optimset('lsqnonlin');


%xg=[0.5   0.1   7.6   0.0660  0.206  0.217  0.000215  0.0  12.0   2*dt];
xg=[0.5   0.1   7.0   0.0713  0.185  0.246  0.000215  0.0  12.0   2*dt];
xl=[0.0   0.0   0.1    1e-5   1e-5   1e-5   1e-7      0.0   3.0   1*dt];
xu=[6.0   4.0   12.0    10.0   1000   1000   10000    6.0  90.0  10*dt];


%xtyp=xg;
%opt2.TypicalX=xtyp(parms2fit);
opt2.TolX=1e-8;
opt2.TolPCG=1e-2;
opt2.TolFun=1e-8;
opt2.DiffMinChange=1e-10;

parms2fit=[3 4 5 6 7 8];
%parms2fit=[3 7 8];
%parms2fit2=parms2fit;
%parms2fit2=[7 8 9];			% original NIMG submission
parms2fit2=[7 9];			% exclusion of t0 modification
parms2fit3=[7];

xg1=xg; xg1(9)=60.0; xl(9)=56.0; xu(9)=64.0;
xx1=lsqnonlin(@lin42,xg1(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,xg1,parms2fit,[avgC1i],[W1]);
xx1new=xx1; load /Users/towi/Documents/Publications/VascularDynamics-Figures/lin42resW3b xx1

xg2=xg; xg2(9)=12.0; xl(9)=10.0; xu(9)=16.0;
xx2=lsqnonlin(@lin42,xg2(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,xg2,parms2fit,[avgC2i],[W2]);
xx2new=xx2; load /Users/towi/Documents/Publications/VascularDynamics-Figures/lin42resW3b xx2
xg2(parms2fit)=xx2;
xx2b=lsqnonlin(@lin42,xg2(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,t,xg2,parms2fit2,[avgC2bi],[W2]);
xg2b=xg2; xg2b(parms2fit2)=xx2b;
xg2c=xg2;
xx2c=lsqnonlin(@lin42,xg2(parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg2,parms2fit3,[avgC2bi],[W2]);

xg3=xg; xg3(9)=6.0; xl(9)=4.0; xu(9)=10.0;
xx3=lsqnonlin(@lin42,xg3(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,xg3,parms2fit,[avgC3i],[W3]);
xx3new=xx3; load /Users/towi/Documents/Publications/VascularDynamics-Figures/lin42resW3b xx3
xg3(parms2fit)=xx3;
xx3b=lsqnonlin(@lin42,xg3(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,t,xg3,parms2fit2,[avgC3bi],[W3]);
xg3b=xg3; xg3b(parms2fit2)=xx3b;
xg3c=xg3;
xx3c=lsqnonlin(@lin42,xg3(parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg3,parms2fit3,[avgC3bi],[W3]);


xg1(parms2fit)=xx1;
xg2(parms2fit)=xx2;
xg2b(parms2fit)=xx2;
xg3(parms2fit)=xx3;
xg3b(parms2fit)=xx3;
xg2b(parms2fit2)=xx2b;
xg3b(parms2fit2)=xx3b;
[xg1;xg2;xg2b;xg3;xg3b],
ans(:,3:end-1),


[yy1,ww1,vv1]=lin42(xx1,t,xg1,parms2fit);
[yy2,ww2,vv2]=lin42(xx2,t,xg2,parms2fit);
[yy2b,ww2b,vv2b]=lin42(xx2b,t,xg2,parms2fit2);
[yy2c,ww2c,vv2c]=lin42(xx2c,t,xg2c,parms2fit3);
[yy3,ww3,vv3]=lin42(xx3,t,xg3,parms2fit);
[yy3b,ww3b,vv3b]=lin42(xx3b,t,xg3,parms2fit2);
[yy3c,ww3c,vv3c]=lin42(xx3c,t,xg3c,parms2fit3);

err1=sum((avgC1i'-yy1).^2)/sum(W1>0);
err2=sum((avgC2i'-yy2).^2)/sum(W2>0);
err3=sum((avgC3i'-yy3).^2)/sum(W3>0);
err2b=sum((avgC2bi'-yy2b).^2)/sum(W2>0);
err3b=sum((avgC3bi'-yy3b).^2)/sum(W3>0);
err2c=sum((avgC2bi'-yy2c).^2)/sum(W2>0);
err3c=sum((avgC3bi'-yy3c).^2)/sum(W3>0);
format short e
[err1;err2;err2b;err3;err3b]
format

err1n=sum((avgC1i'-yy1).^2)/length(tt1)/max(avgC1i-1);
err2n=sum((avgC2i'-yy2).^2)/length(tt2)/max(avgC2i-1);
err3n=sum((avgC3i'-yy3).^2)/length(tt3)/max(avgC3i-1);
err2bn=sum((avgC2bi'-yy2b).^2)/length(tt2)/max(avgC2bi-1);
err3bn=sum((avgC3bi'-yy3b).^2)/length(tt3)/max(avgC3bi-1);

rel2b=sum((avgC2bi'-1).^2)/sum(W2>0);
rel3b=sum((avgC3bi'-1).^2)/sum(W3>0);
eff2b=1-err2b/rel2b;
eff3b=1-err3b/rel3b;
format short e
[eff2b;eff3b]
format


figure(1)
subplot(311)
plot(t,avgC1i,'b--',t,yy1,'b-')
ylabel('FAIR'), legend('Hyperox Data','Hyperox Fit')
axis('tight'), ax=axis; axis([0 tt1(end)-tt1(1) ax(3:4)]), grid('on'),
fatlines, dofontsize(15);
subplot(312)
plot(t,avgC2i,'b--',t,yy2,'b-',t,avgC2bi,'m--',t,yy2b,'m-')
ylabel('FAIR'), legend('Hyperox Data','Hyperox Fit','Hypercap Data','Hypercap Fit')
axis('tight'), ax=axis; axis([0 tt2(end)-tt2(1) ax(3:4)]), grid('on'),
fatlines, dofontsize(15);
subplot(313)
plot(t,avgC3i,'b--',t,yy3,'b-',t,avgC3bi,'m--',t,yy3b,'m-')
ylabel('FAIR'), xlabel('Time (s)'), legend('Hyperox Data','Hyperox Fit','Hypercap Data','Hypercap Fit'),
axis('tight'), ax=axis; axis([0 tt3(end)-tt3(1) ax(3:4)]), grid('on'),
fatlines, dofontsize(15);

figure(2)
subplot(211)
plot(t,avgC2i,t,avgC2bi,t,avgC3i,t,avgC3bi)
axis('tight'); ax=axis; axis([tt2(1) tt2(end) ax(3:4)]); grid('on'); fatlines;
ylabel('FAIR'); dofontsize(15);
subplot(212)
plot(t,W2,t,W3)
axis('tight'); ax=axis; axis([tt2(1) tt2(end) ax(3:4)]); grid('on'); fatlines;
ylabel('Weighting'); xlabel('Time'); dofontsize(15);


%y1p12=avgE2i+tshift(t,avgE2i,12)+tshift(t,avgE2i,24)+tshift(t,avgE2i,36)+tshift(t,avgE2i,48)-4;
%y1p6=avgE3i+tshift(t,avgE3i,6)+tshift(t,avgE3i,12)+tshift(t,avgE3i,18)+tshift(t,avgE3i,24);
%y1p6=y1p6+tshift(t,avgE3i,30)+tshift(t,avgE3i,36)+tshift(t,avgE3i,42)+tshift(t,avgE3i,48)+tshift(t,avgE3i,54)-9;
%y2p6=avgE3i+tshift(t,avgE3i,6)-1;
%
%figure(2)
%subplot(211)
%plot(t,avgE1i,'b-.',t,y1p12,'g-',t,y1p6,'c--')
%ylabel('BOLD'), legend('60s Resp','60s Pred from 12s','60s Pred from 6s')
%axis('tight'), grid('on'),
%fatlines, dofontsize(15);
%
%subplot(212)
%plot(t,avgE2i,'b-.',t,y2p6,'g-')
%ylabel('BOLD'), xlabel('Time'), legend('12s Resp','12s Pred from 6s')
%axis('tight'), ax=axis; axis([0 tt2(end)-tt2(1) ax(3:4)]), grid('on'),
%fatlines, dofontsize(15);
%

