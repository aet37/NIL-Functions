
co2scr6

%load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b tt2
tt1=tt1/60;
tt2=tt2/60;
tt3=tt3/60;

dt=1/(20*60);
tfin1=118/60;		
tfin2=48/60;		
tfin3=42/60;		

opt2=optimset('lsqnonlin');

% Notes (60s Stim):
%  N_U dur ~ 60.7,0.68,0.1,0.1 	N_U_filt dur ~ 59.9,0.68,0.1,7.4
% Notes (12s Stim):
%  N_U dur ~ 12.3,0.72,0.1,0.1	N_U_filt dur ~ 11.9,0.72,0.1,8.5
% Notes (6s Stim):
%  N_U dur ~ 6.8,0.68,0.1,0.1	N_U_filt dur ~ 5.9,0.68,0.1,6.0
%  N_U dur ~ 7.8,0.50,0.1,0.1	N_U_filt dur ~ 5.9,0.50,0.1,7.9

% [Qa0   V0  1/kf1 1/kn  kd    ust  udur   uamp  N   klpf]
xg=[ 1    1    3   0.1   0     3    12   0.5    0   1.5/60];
xl=[0.1  0.1  0.5  0.1     0    0.1  10.0  0.2   0  0.1/60];
xu=[100  100  100  100    100    6    15.0  2.0   2    5/60];

tparms=[dt tfin2];
%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
parms2fit=[3 4 6 7 8 9];
%parms2fit=[3 6 7];

t=[0:tparms(1):tparms(2)];
avgC2i=interp1(tt2,avgC2,t);
avgV2i=interp1(tt2,avgV2,t);
avgE2i=interp1(tt2,avgE2,t);
avgC2bi=interp1(tt2,avgC2b,t);
avgV2bi=interp1(tt2,avgV2b,t);
avgE2bi=interp1(tt2,avgE2b,t);

xx=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,avgC2,tt2);
[yy,uu,u1,t]=complG3f(xx,tparms,xg,parms2fit);
ee=sum((avgC2i-yy).^2)/length(t);

xx2=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,avgC2b,tt2);
[yy2,uu2,u2,t]=complG3f(xx2,tparms,xg,parms2fit);
ee2=sum((avgC2bi-yy2).^2)/length(t);

xx3=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,avgV2,tt2);
[yy3,uu3,u3,t]=complG3f(xx3,tparms,xg,parms2fit);
ee3=sum((avgV2i-yy).^2)/length(t);

xx4=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,avgV2b,tt2);
[yy4,uu4,u4,t]=complG3f(xx4,tparms,xg,parms2fit);
ee4=sum((avgV2bi-yy).^2)/length(t);


subplot(211)
plot(tt2,avgC2,tt2,avgC2b,t,yy,t,yy2)
subplot(212)
plot(tt2,avgV2,tt2,avgV2b,t,yy3,t,yy4)

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

