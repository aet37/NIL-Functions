
clear all
load KazutoData

CBF6i=CBF6i-mean(CBF6i(1:100)-1);

tparms=[0.05 CBF6t(end)-CBF6t(1)]/60;
tparms(3)=1;

%    [F0 V0 Vk1 camp-1 P50 Vc Vct   PS    Pa  Pt  beta]
sparms=[60 2 12/60 0.3 26  1.0 98    6000 90  20  0.003];
slb=[30  1  1/60  -0.5 20 0.05 97.9  2000 80   0 0.00000];
sub=[120 10 40/60 +2.0 31 5.00 98.1  9000 300 50 10.00001];
sparms(11)=0.000;


% we are going to allow values over 1 after 5s
ttt=[0:tparms(1)*10:tparms(2)]';
tss=((ttt<7/60)|(ttt>=40/60)|((ttt>=14.6/60)&(ttt<=15.0/60)));
ifix=find(tss');
iunfix=find(~tss');
xfix=mytrapezoid3(ttt*60,9,5.5,[1.0 3.0]);
%xfix=mysol([1/.6],[1 1/.6],mytrapezoid(ttt*60,10.1,6,0.1),ttt*60);
%xfix=xfix/max(xfix);
xopt=optimset('lsqnonlin');
xopt.TolFun=1e-10;
xopt.TolX=1e-10;
%xopt.MaxIter=1000;
xopt.Display='iter';

parms2fit=[length(sparms)+[1:length(iunfix)]];
sparms=[sparms xfix(iunfix)'];
sub=[sub xfix(iunfix)'+1.0];
slb=[slb xfix(iunfix)'-1.0];

[CCt_0,CCc_0,CMRO2t_0,t]=myPO2est(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:)]);
%[CCt,CCc,CMRO2t,t]=myPO2est(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:)]);
[xx,xresn,xres,xexflag,xout,xlam,xjac]=lsqnonlin(@myPO2est,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:) PO26f(:)]);
[CCt,CCc,CMRO2t,t]=myPO2est(xx,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:)]);

save myPO2res

subplot(311)
plot(CBF6t,CBF6i,'b')
ylabel('CBF/CBF_0'),
axis('tight'), grid('on'), fatlines; dofontsize(15);
subplot(312)
plot(PO26t,PO26f,'b',t*60+CBF6t(1),CCt/CCt(1),'g')
ylabel('P_{tO2}/P_{tO20}'),
axis('tight'), grid('on'), fatlines; dofontsize(15);
legend('Data','Model')
subplot(313)
plot(t*60+CBF6t(1),CMRO2t/CMRO2t(1),'g')
ylabel('CMR_{O2}/CMR_{O20}'),
axis('tight'), grid('on'), fatlines; dofontsize(15);

