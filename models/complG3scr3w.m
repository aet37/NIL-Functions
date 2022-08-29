
clear all

load cohenData
tt0=-3.330;
ttf=41.292;
dtt=0.3330;

%load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b tt2
tt4=(tt-tt(1))/60;
avgE4=1+normocapnia'/100;
avgE4b=1+hypercapnia'/100;
avgE4c=1+hypocapnia'/100;

dt=1/(20*60);
tfin4=(ttf-tt0)/60;

opt2=optimset('lsqnonlin');


% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
xg=[ 1    1    3   2.0   0     5    4.0  0.618  0.00  1.5/60 0.012 1.06/60 20.0 0.50 7.0 25e-3];
%xg=[ 1    1    3   1.0   0     5    4.0  0.618  0.00  1.5/60 0.012 1.06/60 20.0 0.50 7.0 25e-3];
xl=[0.1  0.1  0.1  0.1     0    2.0  3.0  0.4   0  0.1/60 1e-5 0.2/60 0 0.2 1.5 10e-3];
xu=[100  100  100  100    100    7    8.0  1.0   6    5/60 2  5.0/60 200 0.8 7.0 40e-3];

tparms=[dt tfin4 1];
parms2fit=[3 6 7 8 9 11 12 13 14];
%parms2fit2=parms2fit;
%parms2fit2=[3 6 13];		% original NIMG submission
parms2fit2=[3 13];		% removed t0 from fit list
doadjust=1;

t=[0:tparms(1):tparms(2)];
avgE4i=interp1(tt4,avgE4,t);
avgE4bi=interp1(tt4,avgE4b,t);
avgE4ci=interp1(tt4,avgE4c,t);
W4i=mytrapezoid3(t,2*(t(2)-t(1)),(8+10)/60,2*(t(2)-t(1)));
W4bi=mytrapezoid3(t,2*(t(2)-t(1)),(8+20)/60,2*(t(2)-t(1)));
W4ci=mytrapezoid3(t,2*(t(2)-t(1)),(8+8)/60,2*(t(2)-t(1)));

xg1=xg;
xg2=xg;
xg3=xg;


xx1=lsqnonlin(@complG3fw,xg1(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg1,parms2fit,avgE4i,t,W4i);
[yy,uu,u1,t]=complG3fw(xx1,tparms,xg1,parms2fit);
ee=sum((avgE4i-yy).^2)/length(t);
een=(avgE4i-yy)/(max(avgE4i)-1);
een=sum(een.^2)/length(t);

xg2(parms2fit)=xx1;
if (doadjust),
  xg2(14)=1-(1-xg2(14))^(1/1.27);
  xg2(12)=xg2(12)*(1.27^0.4)/1.27;
  xg2(11)=xg2(11)*(1.27^0.4);
end;
xx2=lsqnonlin(@complG3fw,xg2(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,tparms,xg2,parms2fit2,avgE4bi,t,W4bi);
[yy2,uu2,u2,t]=complG3fw(xx2,tparms,xg2,parms2fit2);
ee2=sum((avgE4bi-yy2).^2)/length(t);
ee2n=(avgE4bi-yy2)/(max(avgE4bi)-1);
ee2n=sum(ee2n.^2)/length(t);

xg3(parms2fit)=xx1;
if (doadjust),
  xg3(14)=1-(1-xg3(14))^(1/0.75);
  xg3(12)=xg3(12)*(0.75^0.4)/0.75;
  xg3(11)=xg3(11)*(0.75^0.4);
end;
xx3=lsqnonlin(@complG3fw,xg3(parms2fit2),xl(parms2fit2),xu(parms2fit2),opt2,tparms,xg3,parms2fit2,avgE4ci,t,W4ci);
[yy3,uu3,u3,t]=complG3fw(xx3,tparms,xg3,parms2fit2);
ee3=sum((avgE4ci-yy3).^2)/length(t);
ee3n=(avgE4ci-yy3)/(max(avgE4ci)-1);
ee3n=sum(ee3n.^2)/length(t);

ee1=sum((avgE4i-yy).^2)/length(t);
ee2=sum((avgE4bi-yy2).^2)/length(t);
ee3=sum((avgE4ci-yy3).^2)/length(t);

xg1(parms2fit)=xx1;
xg2(parms2fit2)=xx2;
xg3(parms2fit2)=xx3;


subplot(211)
plot(tt4*60+tt0,avgE4,'b--',tt4*60+tt0,avgE4b,'r--',t*60+tt0,yy,'b',t*60+tt0,yy2,'r')
ylabel('BOLD Signal'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Hyper Data','Normo Fit','Hyper Fit')
subplot(212)
plot(tt4*60+tt0,avgE4,'b--',tt4*60+tt0,avgE4c,'g--',t*60+tt0,yy,'b',t*60+tt0,yy3,'g')
ylabel('BOLD Signal'), xlabel('Time (s)'),
axis('tight'), grid('on'), fatlines, dofontsize(15);
legend('Normo Data','Hypo Data','Normo Fit','Hypo Fit')


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

