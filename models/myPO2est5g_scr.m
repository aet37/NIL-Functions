

clear all
load KazuNPLPdata


dii=[[1:50] [351:401]]';
PO2hh=exp(-(PO2t-PO2t(1))/0.5);
PO2filt=zeros(size(PO2t)); PO2filt([[1:51] [352:401]])=1;


CBFt=LDFt;
CBFi=mean(LDFnp')';
CBFi_base=mean(CBFi(1:50));
CBFib=polyval(polyfit(dii,CBFi(dii),1),[1:length(CBFi)]');
CBFi=CBFi-CBFib+mean(CBFib);
CBFi=CBFi/mean(CBFi(10:40));

CBF2i=mean(LDFlp')';
CBF2i_base=mean(CBF2i(1:50));
CBF2ib=polyval(polyfit(dii,CBF2i(dii),1),[1:length(CBF2i)]');
CBF2i=CBF2i-CBF2ib+mean(CBF2ib);
CBF2i=CBF2i/mean(CBF2i(10:40));

CBFff=mean(LDFlp_base./LDFnp_base);

PO2d=mean(PO2np')';
PO2d_base=mean(PO2d(1:50));
PO2d=PO2d/PO2d_base;
PO2d=(fdeconv(PO2d-1,PO2hh,PO2filt)+1)*PO2d_base;
PO2db=polyval(polyfit(dii,PO2d(dii),1),[1:length(PO2d)]');
PO2d=PO2d-PO2db+PO2d_base;
PO2d=PO2d/PO2d_base;

PO2d2=mean(PO2lp')';
PO2d2_base=mean(PO2d2(1:50));
PO2d2=PO2d2/PO2d2_base;
PO2d2=(fdeconv(PO2d2-1,PO2hh,PO2filt)+1)*PO2d2_base;
PO2d2b=polyval(polyfit(dii,PO2d2(dii),1),[1:length(PO2d2)]');
PO2d2=PO2d2-PO2d2b+PO2d2_base;
PO2d2=PO2d2/PO2d2_base;

%PO2d2=(PO2d2-1)*0.8+1;


FPenv=getFPenv(mean(FPnp'),FPt,6,10,1,CBFt);
FP2env=getFPenv(mean(FPlp'),FPt,6,10,1,CBFt);

fpf=1/mean(FPenv(76:100));
fp2f=1/mean(FP2env(76:100));


tparms=[0.05 CBFt(end)-CBFt(1)]/60;
tparms(3)=0;	% neglect plasma
tparms(4)=0;	% rk flag


xopt=optimset('lsqnonlin');
xopt.TolFun=1e-10;
xopt.TolX=1e-8;
%xopt.MaxIter=1000;
xopt.Display='iter';



alpha_o2=1.39e-3;
hill=2.73;


F0=147;
Vv0=2;
Vvk1=12/60;
dCMRO2=0.00;
P50=38;
cHb=mean(cHbnp);
Vc=1.0;
Vct=98.0;
PS=7000;
Pa=0.9*mean(PaO2np);
Pt=mean(PO2np_base);
bbeta=0.000;
fp2cmro2f=fpf;
PS_inp=2000;
Pt_inp=mean(PO2np_base);
Vc_inp=1.0;
Vct_inp=98.0;
Vk1=1;
sk1=1;
sk2=1;
bpow=1;


%    [F0 V0 Vk1 camp-1 P50 Vc Vct   PS    Pa  Pt  beta]
sparms=[F0 Vv0 Vvk1 dCMRO2 P50 cHb Vc Vct PS  Pa Pt bbeta fp2cmro2f PS_inp Pt_inp Vc_inp Vct_inp Vk1 sk1 sk2 bpow];
slb=[30  1  1/60  +0.05 20 1.5 0.01 97.9  2000 80   0 0.00000 0.0 100 0 0.1 97.9 1.0 1e-6 1e-6 1];
sub=[25  100 40/60 +0.50 40 3.5 50.00 998.1  20000 300 70 10.00001 1e6 14000 50 4.0 101.0 1.0 1e6 1e6 2];


% we are going to allow values over 1 after 5s
ttt=[0:tparms(1)*10:tparms(2)]';
tss=((ttt<7/60)|(ttt>=65/60));
ifix=find(tss');
iunfix=find(~tss');
xfix=0.0*mytrapezoid3(ttt*60,9.5,8.0,0.2);




parms2fit=[length(sparms)+[1:length(iunfix)]];
sparms_orig=sparms;
sparms=[sparms_orig xfix(iunfix)'];
sub=[sub xfix(iunfix)'+0.5];
slb=[slb xfix(iunfix)'-0.5];


[CCt_0,CCc_0,CMRO2t_0,t,CCa_0,XX_0]=myPO2est5g(sparms(parms2fit),tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
%[CCt,CCc,CMRO2t,t,CCat,XXt]=myPO2est5g(sparms(parms2fit),tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:) PO2d(:)*PO2d_base (PO2d2(:)-1)*PO2d2_base]);
%[xx,xresn,xres,xexflag,xout,xlam,xjac]=lsqnonlin(@myPO2est5g,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:) PO2d(:)*PO2d_base (PO2d2(:)-1)*PO2d2_base]);
%[CCt,CCc,CMRO2t,t,CCa]=myPO2est5g(xx,tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);



PO2di=interp1(CBFt,PO2d*PO2d_base,t*60+CBFt(1));
PO2d2i=interp1(CBFt,(PO2d2-1)*PO2d2_base,t*60+CBFt(1));
FP2envi=interp1(CBFt,FP2env,t*60+CBFt(1));

Pa_max=150;
Cp_curve=[1:1e5]*(Pa_max/1e5)*alpha_o2;
Ctot_curve=Cp_curve+(4*cHb)*(1./(1+((alpha_o2*P50./Cp_curve).^hill)));

Pat_0=interp1(Ctot_curve,Cp_curve,CCa_0)/alpha_o2;


figure(1)
subplot(511)
plot(t*60+CBFt(1),Pat_0,'g',t*60+CBFt(1),Pa*ones(size(t)),'k')
ylabel('P_a')
axis('tight'), grid('on'), fatlines;
subplot(512)
plot(CBFt,CBFi,'b')
ylabel('CBF'),
axis('tight'), grid('on'), fatlines;
subplot(513)
plot(PO2t,PO2d*PO2d_base,'b',t*60+CBFt(1),CCt_0/alpha_o2,'g',t*60+CBFt(1),XX_0(:,1)/alpha_o2,'k')
ylabel('P_{tO2}'),
axis('tight'), grid('on'), fatlines;
subplot(514)
plot(t*60+CBFt(1),CMRO2t_0*0.0224,'g',t*60+CBFt(1),XX_0(:,12)*0.0224,'k')
ylabel('CMR_{O2}'),
axis('tight'), grid('on'), fatlines;
subplot(515)
plot(t*60+CBFt(1),PO2d2i,'b',t*60+CBFt(1),PO2di-CCt_0/alpha_o2,'r')
axis('tight'), grid('on'), fatlines;

figure(2)
subplot(511)
plot(t*60+CBFt(1),XX_0(:,3),t*60+CBFt(1),XX_0(:,5))
legend('Art','Ven')
ylabel('V')
axis('tight'), grid('on'), fatlines;
subplot(512)
plot(t*60+CBFt(1),interp1(Ctot_curve,Cp_curve,XX_0(:,2))/alpha_o2,t*60+CBFt(1),interp1(Ctot_curve,Cp_curve,CCc_0)/alpha_o2)
legend('Art','Ven')
ylabel('P_c')
axis('tight'), grid('on'), fatlines;
subplot(513)
plot(t*60+CBFt(1),XX_0(:,8:9))
ylabel('q_{Hb}')
legend('Art','Ven')
axis('tight'), grid('on'), fatlines;
subplot(514)
plot(t*60+CBFt(1),XX_0(:,6:7))
legend('Art','Ven')
ylabel('E')
axis('tight'), grid('on'), fatlines;
subplot(515)
plot(t*60+CBFt(1),XX_0(:,10:11))
legend('Art','Ven')
ylabel('BOLD')
axis('tight'), grid('on'), fatlines;

