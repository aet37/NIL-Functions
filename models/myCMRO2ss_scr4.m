
clear all
load co2_4vals

% 2 types:
%  - first-order-hold sampler
%  - trapezoid-like

fittype=1;
opt4=optimset('lsqnonlin');
opt4.TolFun=1e-10;
opt4.TolX=1e-10;
opt4.MaxIter=1000;
opt4.Display='iter';

tt1=tt1-tt1(1);
if (tt1(2)>1), tt1=tt1/60; end;
tss=((tt1<2/60)|(tt1>=90/60)|((tt1>=30/60)&(tt1<=61/60)));
tparms=[1/(60*20) tt1(end)];
sparms=[1 3.5/60 59.5/60 0.5/60 2/60 rCBF-1 rCMRO2-1 F0 1 0.2 26 1 96 PS Pa Pt 0.5 1];

slb=[1 0 56/60 0.1/60 1.0/60 0.0 0.0 10 0.1 0.0 20 0.1 90 2000 80 0 0.001 0];
sub=[4 5/60 65/60 2.0/60 5.0/60 1.5 1.0 110 5 0.6 31 2.0 99 9000 100 40 10.0 2];

if (fittype==2),

  xfix=mytrapezoid(tt1,2/60,60/60,1/60);
  ifix=find(tss);
  iunfix=find(~tss);

  sparms2=[sparms(5:end) xfix(iunfix)];
  parms2fit2=[1 6 9 13 length(sparms(5:end))+[1:length(iunfix)] ];
  slb2=[slb(5:end) xfix(iunfix)+0.5];
  sub2=[sub(5:end) xfix(iunfix)-0.2];
  x2=lsqnonlin(@myBOLD2,sparms2(parms2fit2),slb2,sub2,opt4,tparms,sparms2,parms2fit2,iunfix,[ifix;xfix(ifix)]',tt1,[avgE1;avgC1]');
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD2(sparms2(parms2fit2),tparms,sparms2,parms2fit2,iunfix,[ifix;xfix(ifix)]',tt1,[avgE1;avgC1]');
  [St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD2(x2,tparms,sparms2,parms2fit2,iunfix,[ifix;xfix(ifix)]',tt1);

  save cmro2fitvals2

elseif (fittype==3),

  tt1i=[tt1(1):(tt1(2)-tt1(1))/4:tt1(end)];
  avgE1i=interp1(tt1,avgE1,tt1i);
  avgC1i=interp1(tt1,avgC1,tt1i);
  tssi=((tt1i<2/60)|(tt1i>=90/60)|((tt1i>=30/60)&(tt1i<=61/60)));

  xfix=mytrapezoid(tt1i,2/60,60/60,.25/60);
  ifix=find(tss);
  iunfix=find(~tss);

  sparms3=[sparms(5:end) xfix(iunfix)];
  parms2fit3=[1 6 9 13 length(sparms(5:end))+[1:length(iunfix)] ];
  slb3=[slb(5:end) xfix(iunfix)+0.5];
  sub3=[sub(5:end) xfix(iunfix)-0.2];
  x3=lsqnonlin(@myBOLD2,sparms3(parms2fit3),slb3,sub3,opt4,tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1i,[avgE1i;avgC1i]');
  %[St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD2(sparms3(parms2fit3),tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1i,[avgE1i;avgC1i]');
  [St,Fin,Fout,VV,CMRO2t,EEt,q,t]=myBOLD2(x3,tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1i);

  save cmro2fitvals3

else,

  parms2fit=[2 5 10 13 17];
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

