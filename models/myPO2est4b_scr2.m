
clear all
load KazuNPLPdata

CBFt=LDFt;
CBFi=mean(LDFnp')';
CBFi=CBFi/mean(CBFi(1:50));

PO2i=mean(PO2np')';
PO2i_base=mean(PO2i(1:50));
PO2i=PO2i/PO2i_base;
PO2hh=exp(-(PO2t-PO2t(1))/0.5);
PO2filt=zeros(size(PO2i)); PO2filt([[1:51] [352:401]])=1;
PO2d=fdeconv(PO2i-1,PO2hh,PO2filt);
PO2d=PO2d-mean(PO2d(1:50))+1;

FPenv=getFPenv(mean(FPnp'),FPt,6,10,1,CBFt);

tparms=[0.01 CBFt(end)-CBFt(1)]/60;
tparms(3)=0;
tparms(4)=0;

alpha_o2=1.39e-3;
hill=2.73;


dofit=0;
dotest=0;
dotest2=1;


F0=147;			% 147
V0=2;
Vk1=12/60;
dCMRO2=0.0;
cHb=mean(cHbnp);
P50=38;
Vc=3.2;			% 3.2,1.0
Vct=98;
PS=7000;		% 7000,2400
Pa=0.6*mean(PaO2np);	% 0.6,1.0
Pt=mean(PO2np_base);
beta=0.000;
fp2cmro2=1;
caAmp=0.000;		% 0.106, 0.200, 0.160
vcAmp=1.0;		% 0.0, 0.4, 1.0

sparms=[ F0  V0 Vk1 dCMRO2 P50 cHb Vc Vct  PS  Pa  Pt  beta fp2cmro2 caAmp vcAmp];
slb=[30  1  1/60  -0.5 20 1.0 0.01 97.9  2000 80   0 0.00000 0.001 2000 0 0 0];
sub=[120 10 40/60 +2.0 31 3.0 5.00 98.1  9000 300 70 10.00001 70   20e3 1e6 1 4];

%[CCt_1,CCc_1,CMRO2t_1,t]=myPO2est4b([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);

if (dotest2),
  [CCt_1,CCc_1,CMRO2t_1,t]=myPO2est4b([],tparms,sparms,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);

  Ca=Pa*alpha_o2+(4*cHb)*(1/(1+((P50/Pa)^hill)));
  CCv_1=2*CCc_1-Ca;

  %plot(t*60+CBFt(1),CCv_1/CCv_1(1)-1,CBFt,CBFi-1)

  subplot(211)
  plot(t*60+CBFt(1),CCt_1/alpha_o2,PO2t,mean(PO2np'))
  ylabel('Avg. P_{O2tiss} (mmHg)')
  legend('\DeltaCMRO2=0 (est)','Measured (w/CMRO2)')
  axis('tight'); grid('on'); fatlines; dofontsize(15);
  title(sprintf('F0= %.2f  PS= %.2f  P_{aO2}= %.2f',F0,PS,Pa));
  subplot(212)
  PO2ii=interp1(PO2t,mean(PO2np'),t*60+CBFt(1));
  PO2d2=fdeconv(mean(PO2lp')',PO2hh,PO2filt);
  PO2d2b=polyval(polyfit([[1:50] [351:401]]',PO2d2([[1:50] [351:401]]),1),[1:length(PO2d2)]');
  PO2d2=PO2d2-PO2d2b+mean(PO2d2b);
  PO2ii2=interp1(PO2t,PO2d2,t*60+CBFt(1));
  plot(t*60+CBFt(1),PO2ii-CCt_1/alpha_o2,'c',t*60+CBFt(1),PO2ii2-mean(PO2ii2(1:1000)),'r')
  ylabel('Diff. P_{O2tiss} (mmHg)')
  xlabel('Time (s)')
  legend('Estimated','Measured (LBP)',4)
  axis('tight'); grid('on'); fatlines; dofontsize(15);

end;


if (dotest),
  sparms1_orig=sparms1;
  %
  % Test the following:
  %  F0: 100, 150, 200
  %  dC: 0.1, 0.3, 0.5
  %  Vc: 0.1, 1.0, 10.0
  %
  sparms1=sparms1_orig; sparms1(1)=146;
  [CCt_1,CCc_1,CMRO2t_1,t]=myPO2est4b([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms1_orig; sparms1(1)=100;
  [CCt_2,CCc_2]=myPO2est4b([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms1_orig; sparms1(1)=200;
  [CCt_3,CCc_3]=myPO2est4b([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
  sparms1=sparms1_orig; sparms1(4)=0.1;
  [CCt_4,CCc_4]=myPO2est4b([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPe(:)]);
  sparms1=sparms1_orig; sparms1(4)=0.5;
  [CCt_5,CCc_5]=myPO2est4b([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPe(:)]);
  sparms1=sparms1_orig; sparms1(6)=0.1;
  [CCt_6,CCc_6]=myPO2est4b([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPe(:)]);
  sparms1=sparms1_orig; sparms1(6)=10.0;
  [CCt_7,CCc_7]=myPO2est4b([],tparms,sparms1,[],(CBFt-CBFt(1))/60,[CBFi(:) FPe(:)]);

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


if (dofit),
  xopt=optimset('lsqnonlin');
  xopt.TolFun=1e-10;
  xopt.TolX=1e-8;
  %xopt.MaxIter=1000;
  xopt.Display='iter';

  [CCt,CCc,CMRO2t,t]=myPO2est(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:)]);
  [xx,xresn,xres,xexflag,xout,xlam,xjac]=lsqnonlin(@myPO2est,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) PO2f(:)]);
  [CCt,CCc,CMRO2t,t]=myPO2est(xx,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:)]);

  save myPO2res4

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


