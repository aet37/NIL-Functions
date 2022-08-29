
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
xg=[ 1    1    3   0.1   0     3    60   0.5    0   1.5/60];
xl=[0.1  0.1  2.0  0.1     0    0.1  50.0  0.2   0  0.1/60];
xu=[100  100  100  100    100    6    70.0  2.0   2    5/60];

tparms=[dt tfin1];
%parms2fit=[3 6];
%parms2fit=[3 6 8 10];
parms2fit=[3 6 7 8];
%parms2fit=[3 6 7];

t=[0:tparms(1):tparms(2)];
avgC1i=interp1(tt1,avgC1,t);
avgV1i=interp1(tt1,avgV1,t);
avgE1i=interp1(tt1,avgE1,t);

xx=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,avgC1,tt1);
[yy,uu,u1,t]=complG3f(xx,tparms,xg,parms2fit);
ee=sum((avgC1i-yy).^2)/length(t);

xx2=lsqnonlin(@complG3f,xg(parms2fit),xl(parms2fit),xu(parms2fit),opt2,tparms,xg,parms2fit,avgV1,tt1);
[yy2,uu2,u2,t]=complG3f(xx2,tparms,xg,parms2fit);
ee2=sum((avgV1i-yy).^2)/length(t);
%[yo,uo]=complG3f(xg(parms2fit),tparms,xg,parms2fit);

%u0=mytrapezoid(t,0.1/60,xg(7)/60,0.1/60,[1]);

subplot(211)
plot(tt1,avgC1,t,yy)
subplot(212)
plot(tt1,avgV1,t,yy2)

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

