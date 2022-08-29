
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
PO2d=(fdeconv(PO2d/PO2d_base-1,PO2hh,PO2filt)+1)*PO2d_base;
PO2db=polyval(polyfit(dii,PO2d(dii),1),[1:length(PO2d)]');
PO2d=PO2d-PO2db+mean(PO2db);
PO2d=PO2d/mean(PO2d(10:40));

PO2d2=mean(PO2lp')';
PO2d2_base=mean(PO2d2(1:50));
PO2d2=PO2d2/PO2d2_base;
PO2d2=(fdeconv(PO2d2,PO2hh,PO2filt)+1)*PO2d2_base;
PO2d2b=polyval(polyfit(dii,PO2d2(dii),1),[1:length(PO2d2)]');
PO2d2=PO2d2-PO2d2b+mean(PO2d2b);
PO2d2=PO2d2/mean(PO2d2(10:40));

FPenv=getFPenv(mean(FPnp'),FPt,6,10,1,CBFt);
FP2env=getFPenv(mean(FPlp'),FPt,6,10,1,CBFt);

fpf=1/mean(FPenv(76:100));
fp2f=1/mean(FP2env(76:100));


tparms=[0.01 CBFt(end)-CBFt(1)]/60;
tparms(3)=0;
tparms(4)=0;

alpha_o2=1.39e-3;
hill=2.73;

do_test=0;		% test single case
do_test2=0;		% test many cases
do_fit=0;		% fit NP CMRO2 to PO2, find parameters
do_fit2=1;		% fit LP CMRO2 to PO2, find parameters


F0=147*CBFff;			% 147
V0=2;
Vk1=12/60;
dCMRO2=0.20;
cHb=mean(cHblp);
P50=38;
Vc=0.5;			% 3.2,1.0
Vct=98;
PS=7000;		% 7000,2400
Pa=0.6*mean(PaO2lp);	% 0.6,1.0
Pt=mean(PO2lp_base);
beta=0.000;
PS1=3000;
Vc1=0.1;
fp2cmro2=fp2f;
caAmp=0.000;		% 0.106, 0.200, 0.160
vcAmp=0.0;		% 0.0, 0.4, 1.0
ps1Amp=-0.00;
vc1Amp=0.0;

sparms=[ F0  V0 Vk1 dCMRO2 P50 cHb Vc Vct  PS  Pa  Pt  beta fp2cmro2 PS1 Vc1 caAmp vcAmp ps1Amp vc1Amp];
slb=[30  1  1/60  +0.05 20 1.0 0.01 97.9  2000 80   0 0.00000 0.001 2000 0 0 0 0 0 -1 0];
sub=[120 10 40/60 +0.50 40 3.0 50.00 1050.1  30000 300 70 10.00001 70   20e3 1e6 30000 5 1 4 4 4];

xopt=optimset('lsqnonlin');
xopt.TolFun=1e-10;
xopt.TolX=1e-8;
%xopt.MaxIter=1000;
xopt.Display='iter';


Cp_curve=[1:1e5]*(150/1e5)*alpha_o2;
Ctot_curve=Cp_curve+(4*cHb)*(1./(1+((alpha_o2*P50./Cp_curve).^hill)));


%[CCt_1,CCc_1,CCt_2,CCc_2,CMRO2t_1,t]=myPO2est4c([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);

if (do_test),
  [CCt_1,CCc_1,CCt_2,CCc_2,CMRO2t_1,t,CCa_2]=myPO2est4c([],tparms,sparms,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);

  Ca=interp1(Cp_curve,Ctot_curve,Pa*alpha_o2);
  CCv_2=2*CCc_2-Ca;
  CCpa_2=interp1(Ctot_curve,Cp_curve,CCa_2);

  %plot(t*60+CBFt(1),CCv_1/CCv_1(1)-1,CBFt,CBFi-1)

  subplot(311)
  plot(t*60+PO2t(1),CCpa_2/alpha_o2)
  ylabel('P_{artl} (mmHg)')
  axis('tight'); grid('on'); fatlines; 
  title(sprintf('F0= %.2f  PS= %.2f (%.2f)  P_{aO2}= %.2f',F0,PS,PS1,Pa));
  subplot(312)
  plot(t*60+PO2t(1),CCt_1/alpha_o2,PO2t,mean(PO2np'))
  ylabel('Avg. P_{O2tiss} (mmHg)')
  legend('\DeltaCMRO2=0 (est)','Measured (w/CMRO2)')
  axis('tight'); grid('on'); fatlines;
  subplot(313)
  PO2ii=interp1(PO2t,mean(PO2np'),t*60+CBFt(1));
  PO2ii2=interp1(PO2t,PO2d2,t*60+CBFt(1));
  plot(t*60+PO2t(1),PO2ii-CCt_1/alpha_o2,'c',t*60+PO2t(1),PO2ii2-mean(PO2ii2(1:1000)),'r')
  ylabel('Diff. P_{O2tiss} (mmHg)')
  xlabel('Time (s)')
  legend('Estimated','Measured (LBP)',4)
  axis('tight'); grid('on'); fatlines;

end;


if (do_test2),
  sparms1_orig=sparms1;
  %
  % Test the following:
  %  F0: 100, 150, 200
  %  dC: 0.1, 0.3, 0.5
  %  Vc: 0.1, 1.0, 10.0
  %
  sparms1=sparms1_orig; sparms1(1)=146;
  [CCt_1,CCc_1,CMRO2t_1,t]=myPO2est4c([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms1_orig; sparms1(1)=100;
  [CCt_2,CCc_2]=myPO2est4c([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms1_orig; sparms1(1)=200;
  [CCt_3,CCc_3]=myPO2est4c([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms1_orig; sparms1(4)=0.1;
  [CCt_4,CCc_4]=myPO2est4c([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPe(:)]);
  sparms1=sparms1_orig; sparms1(4)=0.5;
  [CCt_5,CCc_5]=myPO2est4c([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPe(:)]);
  sparms1=sparms1_orig; sparms1(6)=0.1;
  [CCt_6,CCc_6]=myPO2est4c([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPe(:)]);
  sparms1=sparms1_orig; sparms1(6)=10.0;
  [CCt_7,CCc_7]=myPO2est4c([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPe(:)]);

  subplot(411)
  plot(CBFt,CBFi)
  ylabel('CBF')
  axis('tight'); grid('on'); fatlines;
  title('F0=146  PS=7000  dC=1.3  Vc=1.0')
  subplot(412)
  plot(t*60+CBFt(1),CCc_1)
  ylabel('Cc')
  axis('tight'); grid('on'); fatlines;
  subplot(413)
  plot(t*60+CBFt(1),CCt_1)
  ylabel('Ct')
  axis('tight'); grid('on'); fatlines;
  subplot(414)
  plot(t*60+CBFt(1),CMRO2t_1)
  ylabel('CMRO2')
  xlabel('Time')
  axis('tight'); grid('on'); fatlines;

  subplot(311)
  plot(t*60+CBFt(1),[CCc_1/CCc_1(1);CCc_2/CCc_2(1);CCc_3/CCc_3(1)]')
  ylabel('Cc')
  legend('F0=100','F0=150','F0=200')
  axis('tight'); grid('on'); fatlines;
  subplot(312)
  plot(t*60+CBFt(1),[CCc_1/CCc_1(1);CCc_4/CCc_4(1);CCc_5/CCc_5(1)]')
  ylabel('Cc')
  legend('dC=1.3','dC=1.1','dC=1.5')
  axis('tight'); grid('on'); fatlines;
  subplot(313)
  plot(t*60+CBFt(1),[CCc_1/CCc_1(1);CCc_6/CCc_6(1);CCc_7/CCc_7(1)]')
  ylabel('Cc')
  legend('Vc=1.0','Vc=0.1','Vc=10.0')
  axis('tight'); grid('on'); fatlines;

  subplot(311)
  plot(t*60+CBFt(1),[CCt_1;CCt_2;CCt_3]')
  ylabel('Ct')
  legend('F0=100','F0=150','F0=200')
  axis('tight'); grid('on'); fatlines;
  subplot(312)
  plot(t*60+CBFt(1),[CCt_1;CCt_4;CCt_5]')
  ylabel('Ct')
  legend('dC=1.3','dC=1.1','dC=1.5')
  axis('tight'); grid('on'); fatlines;
  subplot(313)
  plot(t*60+CBFt(1),[CCt_1;CCt_6;CCt_7]')
  ylabel('Ct')
  legend('Vc=1.0','Vc=0.1','Vc=10.0')
  axis('tight'); grid('on'); fatlines;
end; 


if (do_fit),
  [CCt_1,CCc_1,CCt_2,CCc_2,CMRO2t_1,t,CCa_2]=myPO2est4c([],tparms,sparms,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  [xx1,xx1resn,xres,xx1exflag,xx1out,xx1lam,xx1jac]=lsqnonlin(@myPO2est4c,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  [CCt1,CCc1,CCt2,CCc2,CMRO2t1,t,CCa2]=myPO2est4c(xx1,tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);

  save myPO2res4c

  subplot(311)
  plot(CBFt,CBFi,'b')
  ylabel('CBF/CBF_0'),
  axis('tight'), grid('on'), fatlines; dofontsize(15);
  subplot(312)
  plot(PO2t,PO2f,'b',t*60+CBFt(1),CCt/CCt(1),'g')
  ylabel('P_{tO2}/P_{tO20}'),
  axis('tight'), grid('on'), fatlines; dofontsize(15);
  legend('Data','Model')
  subplot(313)
  plot(t*60+CBFt(1),CMRO2t/CMRO2t(1),'g')
  ylabel('CMR_{O2}/CMR_{O20}'),
  axis('tight'), grid('on'), fatlines; dofontsize(15);
end;

if (do_fit2),
  % Fit Vc and dCMRO2 with reasonable constraints
  parms2fit=[4 7 8];

  % Test initial guess, proceed with fit and calculate fit result
  [CCt_1,CCc_1,CCt_2,CCc_2,CMRO2t_1,t,CCa_2]=myPO2est4c([],tparms,sparms,[],(CBFt-CBFt(1))/60,[CBF2i(:) FP2env(:) PO2d2(:)]);
  [xx1,xx1resn,xres,xx1exflag,xx1out,xx1lam,xx1jac]=lsqnonlin(@myPO2est4c,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBF2i(:) FP2env(:) PO2d2(:)]);
  [CCt1,CCc1,CCt2,CCc2,CMRO2t1,t,CCa2]=myPO2est4c(xx1,tparms,sparms,parms2fit,(CBFt-CBFt(1))/60,[CBF2i(:) FP2env(:)]);

  save myPO2res4c

  subplot(311)
  plot(CBFt,CBF2i,'b')
  ylabel('CBF/CBF_0'),
  axis('tight'), grid('on'), fatlines; dofontsize(15);
  subplot(312)
  plot(PO2t,PO2d2,'b',t*60+CBFt(1),CCt1/CCt1(1),'g')
  ylabel('P_{tO2}/P_{tO20}'),
  axis('tight'), grid('on'), fatlines; dofontsize(15);
  legend('Data','Model')
  subplot(313)
  plot(t*60+CBFt(1),CMRO2t1/CMRO2t1(1),'g')
  ylabel('CMR_{O2}/CMR_{O20}'),
  axis('tight'), grid('on'), fatlines; dofontsize(15);
end;


