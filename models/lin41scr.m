
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

u1=mytrapezoid(t,0.1,60,0.1);
u2=mytrapezoid(t,0.1,12,0.1);
u3=mytrapezoid(t,0.1,6,0.1);



opt2=optimset('lsqnonlin');



%xg=[1.0   0.1   7.04   0.057  0.126  0.312  0.0002];
xg=[0.5   0.1   7.6   0.0611  0.146  0.321  0.000215];
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

xg1=xg;
xx1=lsqnonlin(@lin41,xg1(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,u1,xg1,parms2fit,[avgE1i],[W1]);
xg2=xg;
xx2=lsqnonlin(@lin41,xg2(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,u2,xg2,parms2fit,[avgE2i],[W2]);
xg2(parms2fit)=xx2;
xx2b=lsqnonlin(@lin41,xg2(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,u2,xg2,parms2fit,[avgE2bi],[W2]);
xg3=xg;
xx3=lsqnonlin(@lin41,xg3(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,u3,xg3,parms2fit,[avgE3i],[W3]);
xg3(parms2fit)=xx3;
xx3b=lsqnonlin(@lin41,xg3(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,u3,xg3,parms2fit,[avgE3bi],[W3]);
%xx=xg(parms2fit);

[yy1,ww1,vv1]=lin41(xx1,t,u1,xg,parms2fit);
[yy2,ww2,vv2]=lin41(xx2,t,u2,xg,parms2fit);
[yy2b,ww2b,vv2b]=lin41(xx2b,t,u2,xg,parms2fit);
[yy3,ww3,vv3]=lin41(xx3,t,u3,xg,parms2fit);
[yy3b,ww3b,vv3b]=lin41(xx3b,t,u3,xg,parms2fit);

err1n=sum((avgE1i'-yy1).^2)/length(tt1)/max(avgE1i-1);
err2n=sum((avgE2i'-yy2).^2)/length(tt2)/max(avgE2i-1);
err3n=sum((avgE3i'-yy3).^2)/length(tt3)/max(avgE3i-1);
err2bn=sum((avgE2bi'-yy2b).^2)/length(tt2)/max(avgE2bi-1);
err3bn=sum((avgE3bi'-yy3b).^2)/length(tt3)/max(avgE3bi-1);

figure(1)
subplot(311)
plot(t,avgE1i,'b--',t,yy1,'b-')
ylabel('BOLD'), legend('Normo Data','Normo Fit')
axis('tight'), ax=axis; axis([0 tt1(end)-tt1(1) ax(3:4)]), grid('on'),
fatlines, dofontsize(15);

subplot(312)
plot(t,avgE2i,'b--',t,yy2,'b-',t,avgE2bi,'r--',t,yy2b,'r-')
ylabel('BOLD'), legend('Normo Data','Normo Fit','Hyper Data','Hyper Fit')
axis('tight'), ax=axis; axis([0 tt2(end)-tt2(1) ax(3:4)]), grid('on'),
fatlines, dofontsize(15);

subplot(313)
plot(t,avgE3i,'b--',t,yy3,'b-',t,avgE3bi,'r--',t,yy3b,'r-')
ylabel('BOLD'), xlabel('Time (s)'), legend('Normo Data','Normo Fit','Hyper Data','Hyper Fit'),
axis('tight'), ax=axis; axis([0 tt3(end)-tt3(1) ax(3:4)]), grid('on'),
fatlines, dofontsize(15);


y1p12=avgE2i+tshift(t,avgE2i,12)+tshift(t,avgE2i,24)+tshift(t,avgE2i,36)+tshift(t,avgE2i,48)-4;
y1p6=avgE3i+tshift(t,avgE3i,6)+tshift(t,avgE3i,12)+tshift(t,avgE3i,18)+tshift(t,avgE3i,24);
y1p6=y1p6+tshift(t,avgE3i,30)+tshift(t,avgE3i,36)+tshift(t,avgE3i,42)+tshift(t,avgE3i,48)+tshift(t,avgE3i,54)-9;
y2p6=avgE3i+tshift(t,avgE3i,6)-1;

figure(2)
subplot(211)
plot(t,avgE1i,'b-.',t,y1p12,'g-',t,y1p6,'c--')
ylabel('BOLD'), legend('60s Resp','60s Pred from 12s','60s Pred from 6s')
axis('tight'), grid('on'),
fatlines, dofontsize(15);

subplot(212)
plot(t,avgE2i,'b-.',t,y2p6,'g-')
ylabel('BOLD'), xlabel('Time'), legend('12s Resp','12s Pred from 6s')
axis('tight'), ax=axis; axis([0 tt2(end)-tt2(1) ax(3:4)]), grid('on'),
fatlines, dofontsize(15);


