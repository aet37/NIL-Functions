
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

FPenv=getFPenv(mean(FPnp'),FPt,6,10,1,CBFt);
FP2env=getFPenv(mean(FPlp'),FPt,6,10,1,CBFt);

fpf=1/mean(FPenv(76:100));
fp2f=1/mean(FP2env(76:100));


alpha_o2=1.39e-3;
hill=2.73;


tparms=[0.01 CBFt(end)-CBFt(1)]/60;
tparms(3)=0;
tparms(4)=0;

xopt=optimset('lsqnonlin');
xopt.TolFun=1e-10;
xopt.TolX=1e-8;
%xopt.MaxIter=1000;
xopt.Display='iter';



dotest=0;
dofit=1;


F0=147;
Vv0=2;
Vvk1=12/60;
dCMRO2=0.20;
cHb=mean(cHblp);
P50=38;
Vc=1.0;
Vct=98.0;
PS=7000;
Pa=1.0*mean(PaO2lp);
Pt=mean(PO2lp_base);
beta=0.000;
Vm=20.0;
PSm=5000;
fp2cmro2f=fpf;



%    [ F0  V0 Vk1 camp-1 P50 Vc Vct   PS   Pa  Pt  beta  Vm  PSm  fp2cmro2f]
sparms=[F0 Vv0 Vvk1 dCMRO2 P50 cHb Vc  Vct  PS  Pa Pt  beta  Vm  PSm  fp2cmro2f];
slb=[30  1  1/60  0.02 20  1.8  1.00 50.9  2000 80   0 0.00000 1.0 200 0];
sub=[250 100 40/60 +0.50 40 3.5  20.00 998.1  13000 500 70 10.00001 70.0 20e3 1e6];



%[CCt_0,CCc_0,CCm_0,CMRO2t_0,t]=myPO2est4([],tparms,sparms,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);


if (dofit),
  parms2fit=[4 7 13];

  [CCt_1,CCc_1,CCm_1,CMRO2t_1,t]=myPO2est4([],tparms,sparms,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  [CCt,CCc,CMRO2t,t]=myPO2est4(sparms(parms2fit),tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  [x1x,x1resn,x1res,x1exflag,x1out,x1lam,x1jac]=lsqnonlin(@myPO2est4,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:) PO2d(:)]);
  [CCt,CCc,CCm,CMRO2t,t]=myPO2est4(x1x,tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);

  save myPO2res4

  subplot(311)
  plot(CBFt,CBFi,'b')
  ylabel('CBF/CBF_0'),
  axis('tight'), grid('on'), fatlines; dofontsize(15);
  subplot(312)
  plot(PO2t,PO2d,'b',t*60+CBFt(1),CCt/CCt(1),'g')
  ylabel('P_{tO2}/P_{tO20}'),
  axis('tight'), grid('on'), fatlines; dofontsize(15);
  legend('Data','Model')
  subplot(313)
  plot(t*60+CBFt(1),CMRO2t/CMRO2t(1),'g')
  ylabel('CMR_{O2}/CMR_{O20}'),
  axis('tight'), grid('on'), fatlines; dofontsize(15);
end;



if (dotest),
  sparms_orig=sparms;
  %
  % Test the following:
  %  F0: 100, 150, 200
  %  dC: 0.1, 0.3, 0.5
  %  Vc: 0.1, 1.0, 10.0
  %  Vm: 1.0, 5.0, 30.0
  %
  sparms1=sparms_orig; sparms1(1)=146;
  [CCt_1,CCc_1,CCm_1,CMRO2t_1,t]=myPO2est4([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms_orig; sparms1(1)=100;
  [CCt_2,CCc_2,CCm_2]=myPO2est4([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms_orig; sparms1(1)=200;
  [CCt_3,CCc_3,CCm_3]=myPO2est4([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms_orig; sparms1(4)=0.1;
  [CCt_4,CCc_4,CCm_4]=myPO2est4([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms_orig; sparms1(4)=0.5;
  [CCt_5,CCc_5,CCm_5]=myPO2est4([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms_orig; sparms1(6)=0.1;
  [CCt_6,CCc_6,CCm_6]=myPO2est4([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms_orig; sparms1(6)=10.0;
  [CCt_7,CCc_7,CCm_7]=myPO2est4([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms_orig; sparms1(12)=1.0;
  [CCt_8,CCc_8,CCm_8]=myPO2est4([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms_orig; sparms1(12)=5.0;
  [CCt_9,CCc_9,CCm_9]=myPO2est4([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);

  figure(1)
  setpapersize([8 10])

  subplot(511)
  plot(CBFt,CBFi)
  ylabel('CBF')
  axis('tight'); grid('on'); fatlines;
  title('F0=146  PS=7000  dC=1.3  Vc=1.0')
  subplot(512)
  plot(t*60+CBFt(1),CCc_1)
  ylabel('Cc')
  axis('tight'); grid('on'); fatlines;
  subplot(513)
  plot(t*60+CBFt(1),CCt_1)
  ylabel('Ct')
  axis('tight'); grid('on'); fatlines;
  subplot(514)
  plot(t*60+CBFt(1),CCm_1)
  ylabel('Cm')
  axis('tight'); grid('on'); fatlines;
  subplot(515)
  plot(t*60+CBFt(1),CMRO2t_1)
  ylabel('CMRO2')
  xlabel('Time')
  axis('tight'); grid('on'); fatlines;

  subplot(411)
  plot(t*60+CBFt(1),[CCc_1/CCc_1(1);CCc_2/CCc_2(1);CCc_3/CCc_3(1)]')
  ylabel('Cc')
  legend('F0=146','F0=100','F0=200')
  axis('tight'); grid('on'); fatlines;
  subplot(412)
  plot(t*60+CBFt(1),[CCc_1/CCc_1(1);CCc_4/CCc_4(1);CCc_5/CCc_5(1)]')
  ylabel('Cc')
  legend('dC=1.3','dC=1.1','dC=1.5')
  axis('tight'); grid('on'); fatlines;
  subplot(413)
  plot(t*60+CBFt(1),[CCc_1/CCc_1(1);CCc_6/CCc_6(1);CCc_7/CCc_7(1)]')
  ylabel('Cc')
  legend('Vc=1.0','Vc=0.1','Vc=10.0')
  axis('tight'); grid('on'); fatlines;
  subplot(414)
  plot(t*60+CBFt(1),[CCc_1/CCc_1(1);CCc_8/CCc_8(1);CCc_9/CCc_9(1)]')
  ylabel('Cc')
  legend('Vm=30.0','Vm=1.0','Vm=5.0')
  axis('tight'); grid('on'); fatlines;

  subplot(411)
  plot(t*60+CBFt(1),[CCt_1;CCt_2;CCt_3]')
  ylabel('Ct')
  legend('F0=146','F0=100','F0=200')
  axis('tight'); grid('on'); fatlines;
  subplot(412)
  plot(t*60+CBFt(1),[CCt_1;CCt_4;CCt_5]')
  ylabel('Ct')
  legend('dC=1.3','dC=1.1','dC=1.5')
  axis('tight'); grid('on'); fatlines;
  subplot(413)
  plot(t*60+CBFt(1),[CCt_1;CCt_6;CCt_7]')
  ylabel('Ct')
  legend('Vc=1.0','Vc=0.1','Vc=10.0')
  axis('tight'); grid('on'); fatlines;
  subplot(414)
  plot(t*60+CBFt(1),[CCt_1;CCt_8;CCt_9]')
  ylabel('Ct')
  legend('Vm=30.0','Vm=1.0','Vm=5.0')
  axis('tight'); grid('on'); fatlines;

  subplot(411)
  plot(t*60+CBFt(1),[CCm_1;CCm_2;CCm_3]')
  ylabel('Cm')
  legend('F0=146','F0=100','F0=200')
  axis('tight'); grid('on'); fatlines;
  subplot(412)
  plot(t*60+CBFt(1),[CCm_1;CCm_4;CCm_5]')
  ylabel('Cm')
  legend('dC=1.3','dC=1.1','dC=1.5')
  axis('tight'); grid('on'); fatlines;
  subplot(413)
  plot(t*60+CBFt(1),[CCm_1;CCm_6;CCm_7]')
  ylabel('Cm')
  legend('Vc=1.0','Vc=0.1','Vc=10.0')
  axis('tight'); grid('on'); fatlines;
  subplot(414)
  plot(t*60+CBFt(1),[CCm_1;CCm_8;CCm_9]')
  ylabel('Cm')
  legend('Vm=30.0','Vm=1.0','Vm=5.0')
  axis('tight'); grid('on'); fatlines;
end; 




