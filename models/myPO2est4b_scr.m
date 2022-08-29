
clear all
load KazutoData

%CBF6i=CBF6i-mean(CBF6i(1:100)-1);
CBF6i=1+1.0*gammafun(CBF6t,0.9,3.5,1.2);
FP6e=mytrapezoid(CBF6t,0.5,4,0.01);

tparms=[0.01 CBF6t(end)-CBF6t(1)]/60;
tparms(3)=0;
tparms(4)=0;

dotest=1;
dofit=0;


%    [ F0  V0 Vk1 camp-1 P50 Vc Vct   PS   Pa  Pt  beta  Vm  PSm  fp2cmro2]
sparms=[146 2 12/60 0.3 31 2.3  1.0 98    7000 100  40  0.003 30 5000 1 0];
slb=[30  1  1/60  -0.5 20 1.8 0.01 97.9  2000 80   0 0.00000 0.001 2000 0 0];
sub=[120 10 40/60 +2.0 31 3.0 5.00 98.1  9000 300 70 10.00001 70   20e3 1e6 1];
sparms(11)=0.000;

sparms1=sparms([[1:11] 14]);
slb1=slb([[1:11] 14]);
aub1=sub([[1:11] 14]);

%[CCt_0,CCc_0,CCm_0,CMRO2t_0,t]=myPO2est4([],tparms,sparms,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);
%[CCt_1,CCc_1,CMRO2t_1,t]=myPO2est4b([],tparms,sparms1,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);

if (dotest),
  sparms1_orig=sparms1;
  %
  % Test the following:
  %  F0: 100, 150, 200
  %  dC: 0.1, 0.3, 0.5
  %  Vc: 0.1, 1.0, 10.0
  %
  sparms1=sparms1_orig; sparms1(1)=146;
  [CCt_1,CCc_1,CMRO2t_1,t]=myPO2est4b([],tparms,sparms1,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);
  sparms1=sparms1_orig; sparms1(1)=100;
  [CCt_2,CCc_2]=myPO2est4b([],tparms,sparms1,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);
  sparms1=sparms1_orig; sparms1(1)=200;
  [CCt_3,CCc_3]=myPO2est4b([],tparms,sparms1,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);
  sparms1=sparms1_orig; sparms1(4)=0.1;
  [CCt_4,CCc_4]=myPO2est4b([],tparms,sparms1,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);
  sparms1=sparms1_orig; sparms1(4)=0.5;
  [CCt_5,CCc_5]=myPO2est4b([],tparms,sparms1,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);
  sparms1=sparms1_orig; sparms1(6)=0.1;
  [CCt_6,CCc_6]=myPO2est4b([],tparms,sparms1,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);
  sparms1=sparms1_orig; sparms1(6)=10.0;
  [CCt_7,CCc_7]=myPO2est4b([],tparms,sparms1,[],(CBF6t-CBF6t(1))/60,[CBF6i(:) FP6e(:)]);

  subplot(411)
  plot(CBF6t,CBF6i)
  ylabel('CBF')
  axis('tight'); grid('on'); fatlines;
  title('F0=146  PS=7000  dC=1.3  Vc=1.0')
  subplot(412)
  plot(t*60+CBF6t(1),CCc_1)
  ylabel('Cc')
  axis('tight'); grid('on'); fatlines;
  subplot(413)
  plot(t*60+CBF6t(1),CCt_1)
  ylabel('Ct')
  axis('tight'); grid('on'); fatlines;
  subplot(414)
  plot(t*60+CBF6t(1),CMRO2t_1)
  ylabel('CMRO2')
  xlabel('Time')
  axis('tight'); grid('on'); fatlines;

  subplot(311)
  plot(t*60+CBF6t(1),[CCc_1/CCc_1(1);CCc_2/CCc_2(1);CCc_3/CCc_3(1)]')
  ylabel('Cc')
  legend('F0=146','F0=100','F0=200')
  axis('tight'); grid('on'); fatlines;
  subplot(312)
  plot(t*60+CBF6t(1),[CCc_1/CCc_1(1);CCc_4/CCc_4(1);CCc_5/CCc_5(1)]')
  ylabel('Cc')
  legend('dC=1.3','dC=1.1','dC=1.5')
  axis('tight'); grid('on'); fatlines;
  subplot(313)
  plot(t*60+CBF6t(1),[CCc_1/CCc_1(1);CCc_6/CCc_6(1);CCc_7/CCc_7(1)]')
  ylabel('Cc')
  legend('Vc=1.0','Vc=0.1','Vc=10.0')
  axis('tight'); grid('on'); fatlines;

  subplot(311)
  plot(t*60+CBF6t(1),[CCt_1;CCt_2;CCt_3]')
  ylabel('Ct')
  legend('F0=146','F0=100','F0=200')
  axis('tight'); grid('on'); fatlines;
  subplot(312)
  plot(t*60+CBF6t(1),[CCt_1;CCt_4;CCt_5]')
  ylabel('Ct')
  legend('dC=1.3','dC=1.1','dC=1.5')
  axis('tight'); grid('on'); fatlines;
  subplot(313)
  plot(t*60+CBF6t(1),[CCt_1;CCt_6;CCt_7]')
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

  [CCt,CCc,CMRO2t,t]=myPO2est(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:)]);
  [xx,xresn,xres,xexflag,xout,xlam,xjac]=lsqnonlin(@myPO2est,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:) PO26f(:)]);
  [CCt,CCc,CMRO2t,t]=myPO2est(xx,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:)]);

  save myPO2res4

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
end;


