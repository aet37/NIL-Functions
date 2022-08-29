
clear all

opt2=optimset('lsqnonlin');

xg=[40 20 10 5 60 1 5 30 10 1e-5 1];
xlb=[30 10 4 0 30 0.01 1e-5 1e-5 1e-10 1e-5 1];
xub=[80 30 10 7 100 100 1e5 1e5 1e5 1e5 1];

uparms=[1/(60*20) 1 4/60 10/60 1/60 -1];
parms2fit=[5 6 7 8 9];

bparms=[uparms(3:5) 0.62 2/60 60 1 0.2];
[Fin,Fout,VV,t]=balloon1f([],uparms(1:2),bparms,[]);

%[P,V,C,Ri,u,Qi,Qo]=complG1f([],uparms,xg,[]);
xx1=lsqnonlin(@complG1f,xg(parms2fit),xlb(parms2fit),xub(parms2fit),opt2,uparms,xg,parms2fit,0,[Fin/Fin(1) Fout/Fout(1) VV/VV(1)]);
[P,V,C,Ri,u,Qi,Qo]=complG1f(xx1,uparms,xg,parms2fit);

subplot(321)
plot(t,-u)
ylabel('CMRO_2')
title('Model 1')
subplot(322)
plot(t,-u)
title('Model 2')
subplot(323)
plot(t,Fin,t,Fout)
ylabel('Flow')
legend('In','Out')
subplot(324)
plot(t,Qi,t,Qo)
legend('In','Out')
subplot(325)
plot(t,VV)
ylabel('Volume')
xlabel('Time')
subplot(326)
plot(t,V)
xlabel('Time')

