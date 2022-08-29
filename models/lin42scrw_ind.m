
clear all

%load /net/stanley/home/towi/matlab/workdata/cohenData
load co2_4vals tt1 avgE1 avgC1 aaaC1 aaaE1
load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b aaaE2a aaaE2b aaaC2a aaaC2b
load co2_4vals tt3 avgE3 avgE3b avgC3 avgC3b aaaE3a aaaE3b aaaC3a aaaC3b
%co2scr6,

load co2_4vals i2a i2b i3a i3b aC2 aC3 aE2 aE3
load awfit
Fh2b=mean(aC2(i2b,:))./mean(aC2(i2a,:));
%Fh2b=mean(aC2(i2b,:))./mean(aC2(i2a-5,:));
Fh3b=mean(aC3(i3b,:))./mean(aC3(i3a,:));

dt=0.1;
tfin1=tt1(end);

t=[0:dt:tfin1];
avgE1i=interp1(tt1,avgE1,t);
avgC2i=interp1(tt2,avgC2,t);
avgC2bi=interp1(tt2,avgC2b,t);
avgE2i=interp1(tt2,avgE2,t);
avgE2bi=interp1(tt2,avgE2b,t);
avgC3i=interp1(tt3,avgC3,t);
avgC3bi=interp1(tt3,avgC3b,t);
avgE3i=interp1(tt3,avgE3,t);
avgE3bi=interp1(tt3,avgE3b,t);

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
parms2fit2=[7 8 9];		% original NIMG submission
parms2fit2=[7 9];		% modification to exclude t0
parms2fit3=[7];			% amplitude only

for mm=1:size(aaaC2a,2),

  aaaE1i(:,mm)=interp1(tt1,aaaE1(:,mm),t);
  aaaE1i(find(isnan(aaaE1i(:,mm))),mm)=1;
  xg1(mm,:)=xg; xg1(9,mm)=60.0; xl(9)=56.0; xu(9)=64.0;
  xx1(mm,:)=lsqnonlin(@lin42,xg1(parms2fit,mm),xl(parms2fit),xu(parms2fit),opt2,t,xg1(mm,:),parms2fit,[aaaE1i(:,mm)],[W1]);
  xg1(mm,parms2fit)=xx1(mm,:);
  [yy1(:,mm),ww1(:,mm),vv1(:,mm)]=lin42(xx1(mm,:),t,xg1(mm,:),parms2fit);
  err1(mm)=sum((aaaE1i(:,mm)-yy1(:,mm)).^2)/sum(W1>0);

  aaaE2i(:,mm)=interp1(tt2,aaaE2a(:,mm),t);
  aaaE2bi(:,mm)=interp1(tt2,aaaE2b(:,mm),t);
  aaaE2i(find(isnan(aaaE2i(:,mm))),mm)=1;
  aaaE2bi(find(isnan(aaaE2bi(:,mm))),mm)=1;
  xg2(mm,:)=xg; xg2(mm,9)=12.0; xl(9)=10.0; xu(9)=18.0;
  xx2(mm,:)=lsqnonlin(@lin42,xg2(mm,parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,xg2(mm,:),parms2fit,[aaaE2i(:,mm)],[W2]);
  xg2(mm,parms2fit)=xx2(mm,:);
  xx2b(mm,:)=lsqnonlin(@lin42,xg2(mm,parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,t,xg2(mm,:),parms2fit2,[aaaE2bi(:,mm)],[W2]);
  xg2b(mm,:)=xg2(mm,:); xg2b(mm,parms2fit2)=xx2b(mm,:);
  xg2b(mm,parms2fit)=xx2(mm,:); xg2b(mm,parms2fit2)=xx2b(mm,:);
  xg2c(mm,:)=xg2(mm,:); 
  xx2c(mm,:)=lsqnonlin(@lin42,xg2c(mm,parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg2c(mm,:),parms2fit3,[aaaE2bi(:,mm)],[W2]);
  xg2d(mm,:)=xg2(mm,:); xg2d(mm,9)=1.170*xg2d(mm,9);
  xx2d(mm,:)=lsqnonlin(@lin42,xg2d(mm,parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg2d(mm,:),parms2fit3,[aaaE2bi(:,mm)],[W2]);
  %xg2e(mm,:)=xg2(mm,:); xg2e(mm,9)=polyval(w3,Fh2b(mm)-1)*xg2e(mm,9);
  xg2e(mm,:)=xg2(mm,:); xg2e(mm,9)=w1*exp(-(Fh2b(mm)-1)/w2)*xg2e(mm,9);
  xx2e(mm,:)=lsqnonlin(@lin42,xg2e(mm,parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg2e(mm,:),parms2fit3,[aaaE2bi(:,mm)],[W2]);
  %a2e(mm)=polyval(a3,Fh2b(mm)-1)*xx2e(mm,1);
  a2e(mm)=a1*exp(-(Fh2b(mm)-1)/a2)*xx2e(mm,1);
  [yy2(:,mm),ww2(:,mm),vv2(:,mm)]=lin42(xx2(mm,:),t,xg2(mm,:),parms2fit);
  [yy2b(:,mm),ww2b(:,mm),vv2b(:,mm)]=lin42(xx2b(mm,:),t,xg2(mm,:),parms2fit2);
  [yy2c(:,mm)]=lin42(xx2c(mm,:),t,xg2c(mm,:),parms2fit3);
  [yy2d(:,mm)]=lin42(xx2d(mm,:),t,xg2d(mm,:),parms2fit3);
  [yy2e(:,mm)]=lin42(xx2e(mm,:),t,xg2e(mm,:),parms2fit3);
  err2(mm)=sum((aaaE2i(:,mm)-yy2(:,mm)).^2)/sum(W2>0);
  err2b(mm)=sum((aaaE2bi(:,mm)-yy2b(:,mm)).^2)/sum(W2>0);
  err2c(mm)=sum((aaaE2bi(:,mm)-yy2c(:,mm)).^2)/sum(W2>0);
  err2d(mm)=sum((aaaE2bi(:,mm)-yy2d(:,mm)).^2)/sum(W2>0);
  err2e(mm)=sum((aaaE2bi(:,mm)-yy2e(:,mm)).^2)/sum(W2>0);

  aaaE3i(:,mm)=interp1(tt3,aaaE3a(:,mm),t);
  aaaE3bi(:,mm)=interp1(tt3,aaaE3b(:,mm),t);
  aaaE3i(find(isnan(aaaE3i(:,mm))),mm)=1;
  aaaE3bi(find(isnan(aaaE3bi(:,mm))),mm)=1;
  xg3(mm,:)=xg; xg3(mm,9)=6.0; xl(9)=4.0; xu(9)=11.0;
  xx3(mm,:)=lsqnonlin(@lin42,xg3(mm,parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,xg3(mm,:),parms2fit,[aaaE3i(:,mm)],[W3]);
  xg3(mm,parms2fit)=xx3(mm,:);
  xx3b(mm,:)=lsqnonlin(@lin42,xg3(mm,parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,t,xg3(mm,:),parms2fit2,[aaaE3bi(:,mm)],[W3]);
  xg3b(mm,:)=xg3(mm,:); xg3b(mm,parms2fit2)=xx3b(mm,:);
  xg3c(mm,:)=xg3(mm,:); 
  xx3c(mm,:)=lsqnonlin(@lin42,xg3c(mm,parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg3c(mm,:),parms2fit3,[aaaE3bi(:,mm)],[W3]);
  xg3d(mm,:)=xg3(mm,:); xg3d(mm,9)=1.170*xg3d(mm,9);
  xx3d(mm,:)=lsqnonlin(@lin42,xg3d(mm,parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg3d(mm,:),parms2fit3,[aaaE3bi(:,mm)],[W3]);
  %xg3e(mm,:)=xg3(mm,:); xg3e(mm,9)=polyval(w3,Fh3b(mm)-1)*xg3e(mm,9);
  xg3e(mm,:)=xg3(mm,:); xg3e(mm,9)=w1*exp(-(Fh3b(mm)-1)/w2)*xg3e(mm,9);
  xx3e(mm,:)=lsqnonlin(@lin42,xg3e(mm,parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg3e(mm,:),parms2fit3,[aaaE3bi(:,mm)],[W3]);
  %a3e(mm)=polyval(a3,Fh3b(mm)-1)*xx3e(mm,1);
  a3e(mm)=a1*exp(-(Fh3b(mm)-1)/a2)*xx3e(mm,1);
  [yy3(:,mm),ww3(:,mm),vv3(:,mm)]=lin42(xx3(mm,:),t,xg3(mm,:),parms2fit);
  [yy3b(:,mm),ww3b(:,mm),vv3b(:,mm)]=lin42(xx3b(mm,:),t,xg3(mm,:),parms2fit2);
  [yy3c(:,mm)]=lin42(xx3c(mm,:),t,xg3c(mm,:),parms2fit3);
  [yy3d(:,mm)]=lin42(xx3d(mm,:),t,xg3d(mm,:),parms2fit3);
  [yy3e(:,mm)]=lin42(xx3e(mm,:),t,xg3e(mm,:),parms2fit3);
  err3(mm)=sum((aaaE3i(:,mm)-yy3(:,mm)).^2)/sum(W3>0);
  err3b(mm)=sum((aaaE3bi(:,mm)-yy3b(:,mm)).^2)/sum(W3>0);
  err3c(mm)=sum((aaaE3bi(:,mm)-yy3c(:,mm)).^2)/sum(W3>0);
  err3d(mm)=sum((aaaE3bi(:,mm)-yy3d(:,mm)).^2)/sum(W3>0);
  err3e(mm)=sum((aaaE3bi(:,mm)-yy3e(:,mm)).^2)/sum(W3>0);

end;


for mm=1:size(aaaC2a,2),
  err2b_alt(mm)=sum((aaaE2bi(:,mm)-yy2(:,mm)).^2)/sum(W2>0);
  err3b_alt(mm)=sum((aaaE3bi(:,mm)-yy3(:,mm)).^2)/sum(W3>0);
end;

[mean(1-err2b./err2b_alt) std(1-err2b./err2b_alt)]

%format short e
%[err1;err2;err2b;err3;err3b],
%format

%err1n=sum((avgE1i'-yy1).^2)/length(tt1)/max(avgE1i-1);
%err2n=sum((avgE2i'-yy2).^2)/length(tt2)/max(avgE2i-1);
%err3n=sum((avgE3i'-yy3).^2)/length(tt3)/max(avgE3i-1);
%err2bn=sum((avgE2bi'-yy2b).^2)/length(tt2)/max(avgE2bi-1);
%err3bn=sum((avgE3bi'-yy3b).^2)/length(tt3)/max(avgE3bi-1);

%%rel2b=sum((avgE2bi'-avgE2i').^2)/sum(W2>0);
%rel2b=sum((avgE2bi'-1).^2)/sum(W2>0);
%%rel3b=sum((avgE3bi'-avgE3i').^2)/sum(W3>0);
%rel3b=sum((avgE3bi'-1).^2)/sum(W3>0);
%eff2b=1-err2b/rel2b;
%eff3b=1-err3b/rel3b;
%format short e
%[eff2b;eff3b]
%format


%
%figure(1)
%subplot(311)
%plot(t,avgE1i,'b--',t,yy1,'b-')
%ylabel('BOLD'), legend('Hyperox Data','Hyperox Fit')
%axis('tight'), ax=axis; axis([0 tt1(end)-tt1(1) ax(3:4)]), grid('on'),
%fatlines, dofontsize(15);
%subplot(312)
%plot(t,avgE2i,'b--',t,yy2,'b-',t,avgE2bi,'m--',t,yy2b,'m-')
%ylabel('BOLD'), legend('Hyperox Data','Hyperox Fit','Hypercap Data','Hypercap Fit')
%axis('tight'), ax=axis; axis([0 tt2(end)-tt2(1) ax(3:4)]), grid('on'),
%fatlines, dofontsize(15);
%subplot(313)
%plot(t,avgE3i,'b--',t,yy3,'b-',t,avgE3bi,'m--',t,yy3b,'m-')
%ylabel('BOLD'), xlabel('Time (s)'), legend('Hyperox Data','Hyperox Fit','Hypercap Data','Hypercap Fit'),
%axis('tight'), ax=axis; axis([0 tt3(end)-tt3(1) ax(3:4)]), grid('on'),
%fatlines, dofontsize(15);
%figure(2)
%subplot(211)
%plot(t,avgE2i,t,avgE2bi,t,avgE3i,t,avgE3bi)
%axis('tight'); ax=axis; axis([tt2(1) tt2(end) ax(3:4)]); grid('on'); fatlines;
%ylabel('BOLD Signal'); dofontsize(15);
%subplot(212)
%plot(t,W2,t,W3)
%axis('tight'); ax=axis; axis([tt2(1) tt2(end) ax(3:4)]); grid('on'); fatlines;
%ylabel('Weighting'); xlabel('Time'); dofontsize(15);
%
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

