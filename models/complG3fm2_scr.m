
clear all

%load /net/stanley/home/towi/matlab/workdata/cohenData
load co2_4vals tt1 avgE1 avgC1 
load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b
load co2_4vals tt3 avgE3 avgE3b avgC3 avgC3b
%co2scr6,

dt=1/(20*60);
tfin1=tt1(end)/60;


tt1=tt1/60;
tt2=tt2/60;
tt3=tt3/60;


opt2=optimset('lsqnonlin');


% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
%xg=[ 1    1    3   2.4   0     1    12   0.62  0.00  1.5/60 0.0204 1.54/60 12.9 0.52 1 1 1];
xg=[ 1    1    3   2.4   0     1    12   0.62  0.00  1.5/60 0.0204 1.54/60 12.9 0.52 1 1 1];
xl=[0.1  0.1  0.5  0.1     0    0.0  9.0  0.55   0  0.1/60 1e-5 0.1/60 1 0.2 0 0 0];
xu=[100  100  100  100    100    5   16.0  0.75   2    5/60 2  10/60 50 0.7 5 5 5];

tparms=[dt tfin1 2];
%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
%parms2fit=[3 8 9  11  12 13 14   15 16 17];
%parms2fit=[3 8 9   11 13   15 16 17];
parms2fit=[3 8 9     15 16 17];
%parms2fit=[3 6 7];

t=[0:tparms(1):tparms(2)];
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

xg=[xg;xg;xg];
xg(:,7)=[60;12;6]+0;

xx=lsqnonlin(@complG3fm2,xg(1,parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,[avgC1i;avgC2i;avgC3i],[avgE1i;avgE2i;avgE3i],[W1;W2;W3]);

xg(:,6)=xx(end-2:end)';
yy1=complG3f(xx(1,1:end-3),tparms,xg(1,:),parms2fit(1:end-3));
yy2=complG3f(xx(1,1:end-3),tparms,xg(2,:),parms2fit(1:end-3));
yy3=complG3f(xx(1,1:end-3),tparms,xg(3,:),parms2fit(1:end-3));
%yy1=complG3f(xg(1,parms2fit),tparms,xg(1,:),parms2fit);
%yy2=complG3f(xg(2,parms2fit),tparms,xg(2,:),parms2fit);
%yy3=complG3f(xg(3,parms2fit),tparms,xg(3,:),parms2fit);

ee1=(sum(((avgC1i-yy1(1,:)).*W1).^2)/sum(W1))/max(avgC1i-1);
ee2=(sum(((avgC2i-yy2(1,:)).*W2).^2)/sum(W2))/max(avgC2i-1);
ee3=(sum(((avgC3i-yy3(1,:)).*W3).^2)/sum(W3))/max(avgC3i-1);

ee1=ee1+(sum(((avgE1i-yy1(2,:)).*W1).^2)/sum(W1))/max(avgE1i-1);
ee2=ee2+(sum(((avgE2i-yy2(2,:)).*W2).^2)/sum(W2))/max(avgE2i-1);
ee3=ee3+(sum(((avgE3i-yy3(2,:)).*W3).^2)/sum(W3))/max(avgE3i-1);

ee1n=ee1/2;
ee2n=ee2/2;
ee3n=ee3/2;

[ee1n ee2n ee3n]*1000,


subplot(321)
plot(tt1*60,avgC1,'b--',t*60,yy1(1,:),'b-')
ylabel('FAIR'),
axis([tt1(1)*60 tt1(end)*60 min([avgC1 yy1(1,:)]) max([avgC1 yy1(1,:)])]), grid('on'),
fatlines, dofontsize(15);
subplot(323)
plot(tt2*60,avgC2,'b--',t*60,yy2(1,:),'b-')
ylabel('FAIR'),
axis([tt2(1)*60 tt2(end)*60 min([avgC2 yy2(1,:)]) max([avgC2 yy2(1,:)])]), grid('on'),
fatlines, dofontsize(15);
subplot(325)
plot(tt3*60,avgC3,'b--',t*60,yy3(1,:),'b-')
ylabel('FAIR'), xlabel('Time (s)'),
axis([tt3(1)*60 tt3(end)*60 min([avgC3 yy3(1,:)]) max([avgC3 yy3(1,:)])]), grid('on'),
fatlines, dofontsize(15);

subplot(322)
plot(tt1*60,avgE1,'b--',t*60,yy1(2,:),'b-')
ylabel('BOLD'),
axis([tt1(1)*60 tt1(end)*60 min([avgE1 yy1(2,:)]) max([avgE1 yy1(2,:)])]), grid('on'),
fatlines, dofontsize(15);
subplot(324)
plot(tt2*60,avgE2,'b--',t*60,yy2(2,:),'b-')
ylabel('BOLD'),
axis([tt2(1)*60 tt2(end)*60 min([avgE2 yy2(2,:)]) max([avgE2 yy2(2,:)])]), grid('on'),
fatlines, dofontsize(15);
subplot(326)
plot(tt3*60,avgE3,'b--',t*60,yy3(2,:),'b-')
ylabel('BOLD'), xlabel('Time (s)'),
axis([tt3(1)*60 tt3(end)*60 min([avgE3 yy3(2,:)]) max([avgE3 yy3(2,:)])]), grid('on'),
fatlines, dofontsize(15);


