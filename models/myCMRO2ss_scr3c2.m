
clear all
cd /net/aronofsky/data/towi
load co2_4vals

% 2 categories of types:
%  - first-order-hold sampler
%  - trapezoid-like

fittype=8;
opt4=optimset('lsqnonlin');
opt4.TolFun=1e-10;
opt4.TolX=1e-10;
opt4.MaxIter=1000;
opt4.Display='iter';

F0=55;
PS=7000;
Pa=500;
Pt=41.2;

tt1=tt1-tt1(1);
if (tt1(2)>1), tt1=tt1/60; end;
tss=((tt1<2/60)|(tt1>=90/60)|((tt1>=30/60)&(tt1<=61/60)));
tparms=[1/(60*20) tt1(end)];
sparms=[1 3.5/60 59.8/60 0.2/60 3/60 rCBF-1 rCMRO2-1 F0 1 0.2 26 1 96 PS Pa Pt 0.5 1];

slb=[1 0/60 58/60 0.1/60 2.0/60 0.0 0.0 20  0.1 0.0 20 0.1  40  2000 80  0  0.001 0];
%sub=[4 5/60 65/60 4.0/60 7.0/60 1.5 1.0 150 5.0 0.6 31 30.0 4000 9000 100 40 10.0  2];
sub=[4 5/60 65/60 4.0/60 7.0/60 1.5 1.0 150 5.0 0.6 31 30.0 100 9000 100 40 10.0  2];

if (fittype==2),

  %xfix=mytrapezoid(tt1,2/60,60/60,1/60);
  %xfix=mytrapezoid(tt1,6/60,56/60,6/60);
  xfix=mytrapezoid(tt1,6.0/60,55.5/60,5/60);
  ifix=find(tss);
  iunfix=find(~tss);

  %[tau_a tau_v Vt kb]
  sparms2=[sparms(5:end) xfix(iunfix)];
  parms2fit2=[1 6 9 13 length(sparms(5:end))+[1:length(iunfix)] ];
  slb2=[slb(5:end) xfix(iunfix)-0.7];
  sub2=[sub(5:end) xfix(iunfix)+0.7];
  x2=lsqnonlin(@myBOLD2,sparms2(parms2fit2),slb2(parms2fit2),sub2(parms2fit2),opt4,tparms,sparms2,parms2fit2,iunfix,[ifix;xfix(ifix)]',tt1,[avgE1;avgC1]');
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD2(sparms2(parms2fit2),tparms,sparms2,parms2fit2,iunfix,[ifix;xfix(ifix)]',tt1,[avgE1;avgC1]');
  [St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD2(x2,tparms,sparms2,parms2fit2,iunfix,[ifix;xfix(ifix)]',tt1);

  save cmro2fitvals2

elseif (fittype==3),

  tt1i=[tt1(1):(tt1(2)-tt1(1))/4:tt1(end)];
  avgE1i=interp1(tt1,avgE1,tt1i);
  avgC1i=interp1(tt1,avgC1,tt1i);
  tssi=((tt1i<2/60)|(tt1i>=90/60)|((tt1i>=30/60)&(tt1i<=61/60)));

  %xfix=mytrapezoid(tt1i,1/60,61/60,.25/60);
  %xfix=mytrapezoid(tt1i,7.0/60,57/60,4/60);
  xfix=mytrapezoid(tt1i,6.0/60,55.5/60,5/60);
  ifix=find(tssi);
  iunfix=find(~tssi);

  %[tau_a tau_v Vt kb]
  sparms3=[sparms(5:end) 0.0  0 sparms([2 3 4]) 2.0/60 xfix(iunfix)];
  parms2fit3=[1 6 9 13 length(sparms(5:end))+[1:length(iunfix)] ];
  slb3=[slb(5:end) 0.0   0  slb([2 3 4]) 0.1/60 xfix(iunfix)-0.7];
  sub3=[sub(5:end) 100.0 2 slb([2 3 4]) 5.0/60 xfix(iunfix)+0.7];
  x3=lsqnonlin(@myBOLD2,sparms3(parms2fit3),slb3(parms2fit3),sub3(parms2fit3),opt4,tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1i,[avgE1i;avgC1i]');
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD2(sparms3(parms2fit3),tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1i,[avgE1i;avgC1i]');
  [St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD2(x3,tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1i);

  save cmro2fitvals3

elseif (fittype==4),

  sparms=[sparms(1:4) 4*sparms(4)+4/60 sparms(5:end)];
  sparms(3)=sparms(3)-2/60;
  slb=[slb(1:4) slb(4) slb(5:end)];
  sub=[sub(1:4) 8*sub(4) sub(5:end)];

  % input[st,dur,ramp1,ramp2],tau,vk1,Vt,sk1
  parms2fit=[2 3 4 5 6 10 13 17];
  x1=lsqnonlin(@myBOLDt,sparms(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLDt(x1,tparms,sparms,parms2fit,[avgE1;avgC1;(~tss)+1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLDt(x1,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  [St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLDt(x1,tparms,sparms,parms2fit);

  save cmro2fitvals4

elseif (fittype==5),

  %ytype=[10 20 1 0.04];
  %ytype=[10 240 1 .01];
  sparms=[10 240 1 0.04 sparms(2:4) 4*sparms(4) sparms(5:end)];
  slb=[10 0.01 1e-3 1e-5 slb(2:4) slb(4) slb(5:end)];
  sub=[10 1e5 1e3 1e5 sub(2:4) 4*sub(4) sub(5:end)];

  % input[st,dur,ramp1,ramp2],tau,vk1,Vt,sk1
  parms2fit=[2 3 4 5 6 7 8 9 13 16 20];
  x1=lsqnonlin(@myBOLDn,sparms(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLDn(x1,tparms,sparms,parms2fit,[avgE1;avgC1;(~tss)+1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLDn(x1,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  [St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLDn(x1,tparms,sparms,parms2fit);

  save cmro2fitvals5

elseif (fittype==7),

  tt1i=[tt1(1):(tt1(2)-tt1(1))/4:tt1(end)];
  avgE1i=interp1(tt1,avgE1,tt1i);
  avgC1i=interp1(tt1,avgC1,tt1i);

  tssi=((tt1i<1.5/60)|(tt1i>=100/60)|((tt1i>=36/60)&(tt1i<=61/60)));
  %xfix=mytrapezoid(tt1i,1/60,61/60,.25/60);
  %xfix=mytrapezoid(tt1i,7.0/60,57/60,4/60);
  xfix=mytrapezoid(tt1i,6.0/60,55.5/60,5/60);
  %xfix=mytrapezoid(tt1i,6.0/60,57.5/60,3/60);
  ifix=find(tssi);
  iunfix=find(~tssi);

  %[tau_a tau_v Vt kb]
  sparms7=[sparms(7:end) 0.003 xfix(iunfix)];
  sparms7(4)=12/60;
  parms2fit7=[11 length(sparms(7:end))+[1:length(iunfix)]+1 ];
  slb7=[slb(7:end) 0.0 xfix(iunfix)-0.7];
  sub7=[sub(7:end) 10.0 xfix(iunfix)+0.7];
  [x7,resn7,res7,ex7,out7,lam7,jac7]=lsqnonlin(@myBOLD4b,sparms7(parms2fit7),slb7(parms2fit7),sub7(parms2fit7),opt4,tparms,sparms7,parms2fit7,iunfix,[ifix;xfix(ifix)]',tt1i,[avgE1i;avgC1i]');
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD4b(sparms3(parms2fit3),tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1i,[avgE1i;avgC1i]');
  [Er,St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD4b(x7,tparms,sparms7,parms2fit7,iunfix,[ifix;xfix(ifix)]',tt1i,[avgE1i;avgC1i]');

  save cmro2fitvals7c_60

elseif (fittype==8),

  % input[st,dur,ramp],tau,vk1,Vc,Vt,sk1
  %sparms=[sparms 0.0 1.5/60 1*0.05/60 0];
  %slb=[slb 0.0  0.0/60 1*0.05/60 0];
  sparms=[sparms  0.0   1.5/60   2.0/60   0  2.0/60];
  slb=[slb     0.0     0.1/60   10*0.05/60   0  0.1/60];
  sub=[sub    100.0    5.0/60  100*0.05/60   4  20.0/60];
  sparms(12:13)=[1 98];
  slb(12:13)=[0.1 98];
  sub(12:13)=[15  98];
  % sparms(22) = [0-f_neu ; 1-U(21)  ; 2-F(5)  ; 3- t_cmro2(23) ]
  sparms(22)=2;

  parms2fit=[2 3 5 10 12 17 19];
  if (sparms(22)==3),
    parms2fit=[2 3 5 10 17 19];
    parms2fit=[parms2fit 23];
  elseif (sparms(22)==5),
    %parms2fit=[2 3 5 17 19 23]; sparms(10)=1.5/60;
    parms2fit=[2 3 5 10 17 19]; sparms(23)=10/60;
    sparms(22)=3;
  end;
  %x8=sparms(parms2fit);
  [x8,resn8,res8,ex8,out8,lam8,jac8]=lsqnonlin(@myBOLDnc2b,sparms(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,Ut,t]=myBOLDnc2b(x8,tparms,sparms,parms2fit,[avgE1;avgC1;(~tss)+1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,Ut,t]=myBOLDnc2b(x8,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  %myBOLDnc2b(x8,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  [St,Fin,Fout,VV,CMRO2t,EEt,q,Ut,t,UUt,CCt,CCc]=myBOLDnc2b(x8,tparms,sparms,parms2fit);

  save cmro2fitvals8c_2_60

elseif (fittype==9),

  % input[st,dur,ramp],tau,vk1,Vc,Vt,sk1
  %sparms=[sparms 0.0 1.5/60 1*0.05/60 0];
  %slb=[slb 0.0  0.0/60 1*0.05/60 0];
  sparms=[sparms  0.0   1.5/60   2.0/60   3  2.0/60];
  slb=[slb     0.0     0.1/60   10*0.05/60   0  0.1/60];
  sub=[sub    100.0    5.0/60  100*0.05/60   4  20.0/60];

  parms2fit=[2 3 5 10 12 13 17 19 23];
  %x9=sparms(parms2fit);
  x9=lsqnonlin(@myBOLDnc,sparms(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,Ut,t]=myBOLDnc(x9,tparms,sparms,parms2fit,[avgE1;avgC1;(~tss)+1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,Ut,t]=myBOLDnc(x9,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  %myBOLDnc(x9,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  [St,Fin,Fout,VV,CMRO2t,EEt,q,Ut,t]=myBOLDnc(x9,tparms,sparms,parms2fit);

  save cmro2fitvals9


else,

  % input[st,dur,ramp],tau,vk1,Vc,Vt,sk1
  parms2fit=[2 3 5 10 12 17];
  x1=lsqnonlin(@myBOLD,sparms(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD(x1,tparms,sparms,parms2fit,[avgE1;avgC1;(~tss)+1]',tt1);
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD(x1,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  [St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD(x1,tparms,sparms,parms2fit);

  save cmro2fitvals1


end;


figure(1)
subplot(211)
plot(tt1*60,avgC1,t*60,Fin/Fin(1))
ylabel('rCBF'),
axis('tight'), grid('on'),
fatlines, dofontsize(15);
subplot(212)
plot(t*60,CMRO2t/CMRO2t(1))
ylabel('CMRO2'), xlabel('Time'),
axis('tight'), grid('on'),
fatlines, dofontsize(15);

figure(2)
subplot(211)
plot(t*60,EEt)
ylabel('OEF'),
axis('tight'), grid('on'),
fatlines, dofontsize(15);
subplot(212)
plot(tt1*60,avgE1,t*60,St)
ylabel('BOLD'), xlabel('Time'),
axis('tight'), grid('on'),
fatlines, dofontsize(15);

