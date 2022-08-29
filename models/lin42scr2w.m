
clear all

load cohenData
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
W4b=ones(size(avgE4i));
W4c=ones(size(avgE4i));
%W4=W4+2*mytrapezoid3(t,-tt0,4+16,[2*(t(2)-t(1))]);
%W4b=W4b+2*mytrapezoid3(t,-tt0,4+16,[2*(t(2)-t(1))]);
%W4c=W4c+2*mytrapezoid3(t,-tt0,4+16,[2*(t(2)-t(1))]);
%W4=W4+4*mytrapezoid3(t,-tt0,4+8,[2*(t(2)-t(1)) 8]);
%W4b=W4b+4*mytrapezoid3(t,-tt0,4+8,[2*(t(2)-t(1)) 8]);
%W4c=W4c+4*mytrapezoid3(t,-tt0,4+8,[2*(t(2)-t(1)) 8]);
W4=W4+4*mytrapezoid3(t,-tt0,14,[2*(t(2)-t(1))]);
W4b=W4b+4*mytrapezoid3(t,-tt0,20,[2*(t(2)-t(1))]);
W4c=W4c+4*mytrapezoid3(t,-tt0,11,[2*(t(2)-t(1))]);

u4=mytrapezoid(t,0.1,4,0.1);


opt2=optimset('lsqnonlin');



xg=[0.0   0.1   5.7   0.028  0.123  0.302  0.0017    3.7   4.0  2*dt];
xl=[0.0   0.0   0.1    1e-5   1e-5   1e-5   1e-7     0.0   2.0  1*dt];
xu=[0.0   4.0   12.0    10.0   1000   1000   10000  10.0   8.0  10*dt];


%xtyp=xg;
%opt2.TypicalX=xtyp(parms2fit);
opt2.TolX=1e-8;
opt2.TolPCG=1e-2;
opt2.TolFun=1e-8;
opt2.DiffMinChange=1e-10;

parms2fit=[3 4 5 6 7 8];
xx1=lsqnonlin(@lin42,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,xg,parms2fit,[avgE4i],[W4]);
xx1new=xx1; load /Users/towi/Documents/Publications/VascularDynamics-Figures/lin42resW1d xx1
xg(parms2fit)=xx1;
parms2fit2=parms2fit;
parms2fit2=[7 8 9];		% originally used for NIMG submission
parms2fit2=[7 9];		% modified to exclude t0
parms2fit3=[7];
xx2=lsqnonlin(@lin42,xg(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,t,xg,parms2fit2,[avgE4bi],[W4b]);
xx3=lsqnonlin(@lin42,xg(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,t,xg,parms2fit2,[avgE4ci],[W4c]);


xg1=xg; xg1(parms2fit)=xx1;
xg2=xg1; xg2(parms2fit2)=xx2;
xg3=xg1; xg3(parms2fit2)=xx3;


xg2c=xg1;
xx2c=lsqnonlin(@lin42,xg2c(parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg2c,parms2fit3,[avgE4bi],[W4b]);
xg3c=xg1;
xx3c=lsqnonlin(@lin42,xg3c(parms2fit3),xl(parms2fit3),xu(parms2fit3),opt2,t,xg3c,parms2fit3,[avgE4ci],[W4c]);

[yy1,ww1,vv1,uu1]=lin42(xx1,t,xg,parms2fit);
[yy2,ww2,vv2,uu2]=lin42(xx2,t,xg,parms2fit2);
[yy3,ww3,vv3,uu3]=lin42(xx3,t,xg,parms2fit2);
[yy2c,ww2c,vv2c]=lin42(xx2c,t,xg2c,parms2fit3);
[yy3c,ww3c,vv3c]=lin42(xx3c,t,xg3c,parms2fit3);

err1=sum((avgE4i'-yy1).^2)/sum(W4>0);
err2=sum((avgE4bi'-yy2).^2)/sum(W4b>0);
err3=sum((avgE4ci'-yy3).^2)/sum(W4c>0);
err2c=sum((avgE4bi'-yy2c).^2)/sum(W4b>0);
err3c=sum((avgE4ci'-yy3c).^2)/sum(W4c>0);
format short e
[err1;err2;err3],
format

err1n=sum((avgE4i'-yy1).^2)/length(t)/max(avgE4i-1);
err2n=sum((avgE4bi'-yy2).^2)/length(t)/max(avgE4bi-1);
err3n=sum((avgE4ci'-yy3).^2)/length(t)/max(avgE4ci-1);

%rel2=sum((avgE4bi'-avgE4i').^2)/sum(W4>0);
rel2=sum((avgE4bi'-1).^2)/sum(W4b>0);
%rel3=sum((avgE4ci'-avgE4i').^2)/sum(W4>0);
rel3=sum((avgE4ci'-1).^2)/sum(W4c>0);
eff2=1-err2/rel2;
eff3=1-err3/rel3;
[eff2;eff3]


figure(1)
subplot(211)
plot(t+tt0,avgE4i,'b--',t+tt0,yy1,'b-',t+tt0,avgE4bi,'r--',t+tt0,yy2,'r-')
ylabel('BOLD Signal'),
legend('Normo Data','Normo Fit','Hyper Data','Hyper Fit')
axis('tight'), grid('on'),
fatlines, dofontsize(15);

subplot(212)
plot(t+tt0,avgE4i,'b--',t+tt0,yy1,'b-',t+tt0,avgE4ci,'g--',t+tt0,yy3,'g-')
ylabel('BOLD Signal'), xlabel('Time (s)'),
axis('tight'), grid('on'),
legend('Normo Data','Normo Fit','Hypo Data','Hypo Fit')
fatlines, dofontsize(15);


