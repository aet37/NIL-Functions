
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
xg2=[ 1    1    3   2.4   0     1    12   0.62  0.00  1.5/60 0.0253 1.35/60 11.7 0.64 1 1];
xl2=[0.1  0.1  0.5  0.1     0    0.0  9.0  0.5   0  0.1/60 1e-5 0.1/60 1 0.2 0 0];
xu2=[100  100  100  100    100    5   16.0  0.7   2    5/60 2  10/60 50 0.7 5 5];

tparms2=[dt tfin1 1];
%parms2fit2=[3 6];
%parms2fit2=[3 6 8 10];
%parms2fit2=[3 8 9    11 12 13 14   15 16];
parms2fit2=[3 8 9   12 13 14    15 16];
%parms2fit2=[3 9      15 16];
%parms2fit2=[3 6 7];

t=[0:tparms2(1):tparms2(2)];
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

xg2=[xg2;xg2];
xg2(:,7)=[12;6]+0;

xx2=lsqnonlin(@complG3fm,xg2(1,parms2fit2),xl2(parms2fit2),xu2(parms2fit2),opt2,tparms2,xg2,parms2fit2,[avgE2bi;avgE3bi],[W2;W3]);

xg2(:,6)=xx2(end-1:end)';
%yy1=complG3f(xx2(1,1:end-2),tparms2,xg2(1,:),parms2fit2(1:end-2));
yy2=complG3f(xx2(1,1:end-2),tparms2,xg2(1,:),parms2fit2(1:end-2));
yy3=complG3f(xx2(1,1:end-2),tparms2,xg2(2,:),parms2fit2(1:end-2));

%yy1=complG3f(xg2(1,parms2fit2),tparms2,xg2(1,:),parms2fit2);
%yy2=complG3f(xg2(2,parms2fit2),tparms2,xg2(2,:),parms2fit2);
%yy3=complG3f(xg2(3,parms2fit2),tparms2,xg2(3,:),parms2fit2);

%ee1=sum(((avgE1i-yy1).*W1).^2)/sum(W1);
ee2=sum(((avgE2bi-yy2).*W2).^2)/sum(W2);
ee3=sum(((avgE3bi-yy3).*W3).^2)/sum(W3);

%ee1n=ee1/max(avgE1i-1);
ee2n=ee2/max(avgE2bi-1);
ee3n=ee3/max(avgE3bi-1);

[ee2n ee3n]*1000,


%subplot(311)
%plot(tt1*60,avgE1,'b--',t*60,yy1,'b-')
%ylabel('BOLD'),
%axis([tt1(1)*60 tt1(end)*60 min([avgE1 yy1]) max([avgE1 yy1])]), grid('on'),
%fatlines, dofontsize(15);
subplot(211)
plot(tt2*60,avgE2b,'b--',t*60,yy2,'b-')
ylabel('BOLD'),
axis([tt2(1)*60 tt2(end)*60 min([avgE2 yy2]) max([avgE2 yy2])]), grid('on'),
fatlines, dofontsize(15);
subplot(212)
plot(tt3*60,avgE3b,'b--',t*60,yy3,'b-')
ylabel('BOLD'), xlabel('Time (s)'),
axis([tt3(1)*60 tt3(end)*60 min([avgE3 yy3]) max([avgE3 yy3])]), grid('on'),
fatlines, dofontsize(15);

