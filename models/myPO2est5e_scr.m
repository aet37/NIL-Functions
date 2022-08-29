

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
tparms(3)=1;	% neglect plasma
tparms(4)=0;	% rk flag
tparms(5)=3;	% ps type (1= perm_only, 2= surfarea/vol only)


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
Pa=0.6*mean(PaO2np);
Pt=mean(PO2np_base);
bbeta=0.000;
fp2cmro2f=fpf;
PSamp=2.00;


%    [F0 V0 Vk1 camp-1 P50 Vc Vct   PS    Pa  Pt  beta]
sparms=[F0 Vv0 Vvk1 dCMRO2 P50 cHb Vc Vct PS  Pa Pt bbeta fp2cmro2f PSamp];
slb=[30  1  1/60  +0.05 20 1.5 0.01 97.9  2000 80   0 0.00000 0.0 -1.0];
sub=[25  100 40/60 +0.50 40 3.5 50.00 998.1  20000 300 70 10.00001 1e6 +1.0];


% we are going to allow values over 1 after 5s
ttt=[0:tparms(1)*10:tparms(2)]';
tss=((ttt<=10/60)|(ttt>=65/60));
ifix=find(tss');
iunfix=find(~tss');
xfix=0.0*mytrapezoid3(ttt*60,9.5,8.0,0.2);




parms2fit=[length(sparms)+[1:length(iunfix)]];
sparms_orig=sparms;
sparms=[sparms_orig xfix(iunfix)'];
sub=[sub xfix(iunfix)'+0.5];
slb=[slb xfix(iunfix)'-0.5];


[CCt_0,CCc_0,CMRO2t_0,t,PPSt_0]=myPO2est5e(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
%[CCt,CCc,CMRO2t,t,PPSt]=myPO2est5e(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:) PO2d(:)*PO2d_base (PO2d2(:)-1)*PO2d2_base]);
[xx,xresn,xres,xexflag,xout,xlam,xjac]=lsqnonlin(@myPO2est5e,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:) PO2d(:)*PO2d_base (PO2d2(:)-1)*PO2d2_base]);
[CCt,CCc,CMRO2t,t,PPSt]=myPO2est5e(xx,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);


tparms1=tparms; tparms1(5)=1;
tparms2=tparms; tparms2(5)=2;
tparms3=tparms; tparms3(5)=3;
sparms1=sparms;
sparms2=sparms;
sparms1(14)=0.2;
sparms2(14)=1.0;


[CCt_1,CCc_1,CMRO2t_1,t,PPS_1]=myPO2est5f(xx,tparms1,sparms1,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
[CCt_2,CCc_2,CMRO2t_2,t,PPS_2]=myPO2est5f(xx,tparms1,sparms2,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
[CCt_3,CCc_3,CMRO2t_3,t,PPS_3]=myPO2est5f(xx,tparms2,sparms1,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
[CCt_4,CCc_4,CMRO2t_4,t,PPS_4]=myPO2est5f(xx,tparms2,sparms2,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
[CCt_5,CCc_5,CMRO2t_5,t,PPS_5]=myPO2est5f(xx,tparms3,sparms1,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);
[CCt_6,CCc_5,CMRO2t_6,t,PPS_6]=myPO2est5f(xx,tparms3,sparms2,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBFi(:) FPenv(:)]);


PO2di=interp1(CBFt,PO2d*PO2d_base,t*60+CBFt(1));
PO2d2i=interp1(CBFt,(PO2d2-1)*PO2d2_base,t*60+CBFt(1));
FP2envi=interp1(CBFt,FP2env,t*60+CBFt(1));

Pa_max=150;
Cp_curve=[1:1e5]*(Pa_max/1e5)*alpha_o2;
Ctot_curve=Cp_curve+(4*cHb)*(1./(1+((alpha_o2*P50./Cp_curve).^hill)));

%Pat=interp1(Ctot_curve,Cp_curve,CCa)/alpha_o2;
%Patf=myfilter1(Pat,38);

%Pat_1=interp1(Ctot_curve,Cp_curve,CCa_1)/alpha_o2;
%Pat_2=interp1(Ctot_curve,Cp_curve,CCa_2)/alpha_o2;
%Pat_3=interp1(Ctot_curve,Cp_curve,CCa_3)/alpha_o2;
%Pat_4=interp1(Ctot_curve,Cp_curve,CCa_4)/alpha_o2;
%Pat_5=interp1(Ctot_curve,Cp_curve,CCa_5)/alpha_o2;


save myPO2res5e


figure(1)
subplot(511)
plot(t*60+CBFt(1),PPSt,'g')
ylabel('PS')
axis('tight'), grid('on'), fatlines;
subplot(512)
plot(CBFt,CBFi,'b')
ylabel('CBF'),
axis('tight'), grid('on'), fatlines;
subplot(513)
plot(PO2t,PO2d*PO2d_base,'b',t*60+CBFt(1),CCt/alpha_o2,'g')
ylabel('P_{tO2}'),
axis('tight'), grid('on'), fatlines;
subplot(514)
plot(t*60+CBFt(1),CMRO2t*0.0224,'g')
ylabel('CMR_{O2}'),
axis('tight'), grid('on'), fatlines;
subplot(515)
plot(t*60+CBFt(1),PO2d2i,'b',t*60+CBFt(1),PO2di-CCt/alpha_o2,'r')
axis('tight'), grid('on'), fatlines;

figure(2)
subplot(311)
plot(t*60+CBFt(1),[PPS_1;PPS_2]')
legend('1 10%','2 50%')
ylabel('PS'),
axis('tight'), grid('on'), fatlines;
subplot(312)
plot(t*60+CBFt(1),[CCt_1' CCt_2' CCt_3' CCt_4' CCt_5' CCt_6']/alpha_o2,PO2t,PO2d*PO2d_base,'k')
ylabel('P_{tO2} (Normal)'),
axis('tight'), grid('on'), fatlines;
legend('1 (1)','2 (1)','1 (2)','2 (2)','1 (3)','2 (3)')
subplot(313)
plot(PO2t,PO2d2*PO2d2_base,'k')
ylabel('P_{tO2} (CMR_{O2} ind.)'),
axis('tight'), grid('on'), fatlines;

figure(3)
subplot(333)
plot(t*60+CBFt(1),[PPS_1;PPS_2;PPSt]')
legend('+10% PS','+50% PS','Est. PS(t)')
ylabel('PS (Perm. only)'),
axis('tight'), grid('on'), fatlines; dofontsize(15);
ax=axis; axis([-5 60 ax(3:4)]);
subplot(336)
plot(t*60+CBFt(1),[CCt_1' CCt_2' CCt']/alpha_o2)
ylabel('P_{tO2} Delivery (mmHg)'),
legend('+10% PS','+50% PS','Est. PS(t)')
axis('tight'), grid('on'), fatlines; dofontsize(15);
ax=axis; axis([-5 60 ax(3:4)]);
subplot(339)
plot(t*60+CBFt(1),[CCt_1' CCt_2' CCt']/alpha_o2+tmp2*ones(1,3),kazu_res1(:,1),kazu_res1(:,7),'k--')
legend('+10% PS','+50% PS','Est. PS(t)','Meas.')
ylabel('P_{tO2} (mmHg)'),
axis('tight'), grid('on'), fatlines; dofontsize(15);
ax=axis; axis([-5 60 ax(3:4)]);


%tt=t(:)*60+CBFt(1);
%estPO2t=[CCt_1' CCt_2' CCt_3' CCt_4' CCt_5']/alpha_o2;
%est2PO2t=[Pat(:) CCt(:)/alpha_o2 CMRO2t(:)*0.0224 interp1(CBFt,CBFi,tt(:)) interp1(CBFt,FP2env,tt(:))];
%PO2t_np=PO2di(:);
%PO2t_lp=((PO2d2i(:)/PO2d2_base)+1)*PO2d2_base;
%kazu_res1=[tt estPO2t PO2t_np PO2t_lp est2PO2t];
%
%save kazu_nplp_res1.txt -ASCII -TABS kazu_res1
%
%
%figure(3)
%setpapersize([8 10])
%tmp1=kazu_res1(:,7)-mean(kazu_res1(1:190,7));
%tmp2=kazu_res1(:,8)-mean(kazu_res1(1:190,8));
%tmp3=tmp1-tmp2;
%subplot(323)
%plot(kazu_res1(:,1),tmp3,kazu_res1(:,1),tmp2)
%ylabel('\Delta P_{tO2} (mmHg)'),
%legend('Delivery (est.)','Consumption')
%fatlines; axis('tight'); grid('on'); dofontsize(15);
%ax=axis; axis([-5 60 ax(3:4)]);
%subplot(325)
%plot(kazu_res1(:,1),kazu_res1(:,7))
%ylabel('\Delta P_{tO2} (mmHg)'),
%legend('Measured')
%fatlines; axis('tight'); grid('on'); dofontsize(15);
%ax=axis; axis([-5 60 ax(3:4)]);
%subplot(321)
%plot(kazu_res1(:,1),kazu_res1(:,12),kazu_res1(:,1),(FP2envi/max(FP2envi))*(max(kazu_res1(:,12))-1)+1)
%ylabel('LDF, \Sigma FP'),
%fatlines; axis('tight'); grid('on'); dofontsize(15);
%ax=axis; axis([-5 60 ax(3:4)]);
%subplot(324)
%plot(kazu_res1(:,1),kazu_res1(:,[2 4 6 10]))
%ylabel('P_{tO2} Delivery (mmHg)'),
%legend('100% Part','80% Part','60% Part','Est. Part')
%fatlines; axis('tight'); grid('on'); dofontsize(15);
%ax=axis; axis([-5 60 ax(3:4)]);
%subplot(326)
%plot(kazu_res1(:,1),kazu_res1(:,[2 4 6 10])+tmp2*ones(1,4),kazu_res1(:,1),kazu_res1(:,7),'k--')
%ylabel('P_{tO2} (mmHg)'),
%legend('100% Part','80% Part','60% Part','Est. Part','Meas.')
%fatlines; axis('tight'); grid('on'); dofontsize(15);
%ax=axis; axis([-5 60 ax(3:4)]);
%subplot(322)
%plot(kazu_res1(:,1),mean(PaO2np)*[1.0 0.8 0.6]'*ones(1,length(kazu_res1)),kazu_res1(:,1),kazu_res1(:,9))
%ylabel('P_{O2input} (mmHg)');
%fatlines; axis('tight'); grid('on'); dofontsize(15);
%ax=axis; axis([-5 60 ax(3:4)]);
%
