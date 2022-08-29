
clear all
cd /net/aronofsky/data/towi
load co2_4vals

% 2 categories of types:
%  - first-order-hold sampler
%  - trapezoid-like

fittype=1;
noiseE1amp=0;
noiseC1amp=0;
nreps=20;
doplots=0;

opt4=optimset('lsqnonlin');
opt4.TolFun=1e-10;
opt4.TolX=1e-10;
opt4.MaxIter=1000;
opt4.Display='iter';

tt1=tt1-tt1(1);
if (tt1(2)>1), tt1=tt1/60; end;
tss=((tt1<2/60)|(tt1>=90/60)|((tt1>=30/60)&(tt1<=61/60)));
tparms=[1/(60*20) tt1(end)];

sparms=[1 3.5/60 59.5/60 0.5/60 2/60 rCBF-1 rCMRO2-1 F0 1  0.2 26 1 96 PS Pa Pt 0.5 1];
slb =  [1 0/60  56/60   0.1/60 1.0/60 0.0   0.0    30  0.1 0.0 20 0.1  70  2000 80  0  0.001 0];
sub =  [1 5/60  65/60   4.0/60 9.9/60 2.0   1.0    120 7.0 0.6 31 30.0 400 9000 100 40 10.0  2];

if (fittype==2),

  xfix=mytrapezoid(tt1,2/60,60/60,1/60);
  ifix=find(tss);
  iunfix=find(~tss);

  sparms2=[sparms(5:end) xfix(iunfix)];
  parms2fit2=[1 6 9 13 length(sparms(5:end))+[1:length(iunfix)] ];
  slb2=[slb(5:end) xfix(iunfix)-0.7];
  sub2=[sub(5:end) xfix(iunfix)+0.7];

  sparms2ft=rand(size(sparms2)).*(sub2-slb2)+slb2;
  [avgE1i,avgC1i,Fout,VVt,CMRO2t,EEt,q,t]=myBOLD2(spamrs2(parms2fit2),tparms,sparms2,parms2fit2,iunfix,[ifix;xfix(ifix)]',tt1);
  avgE1ft=interp1(t,avgE1i,tt1); avgE1ft=avgE1ft+noiseE1amp*randn(size(avgE1ft));
  avgC1ft=interp1(t,avgC1i,tt1); avgC1ft=avgC1ft/avgC1ft(1)+noiseC1amp*randn(size(avgC1ft));

  x2=lsqnonlin(@myBOLD2,sparms2ft(parms2fit2),slb2(parms2fit2),sub2(parms2fit2),opt4,tparms,sparms2,parms2fit2,iunfix,[ifix;xfix(ifix)]',tt1,[avgE1ft;avgC1ft]');
  [St,Fin,Fout,VVt,CMRO2t,EEt,q,t]=myBOLD2(x2,tparms,sparms2,parms2fit2,iunfix,[ifix;xfix(ifix)]',tt1);

  save cmro2fitvals2fittest

elseif (fittype==3),

  tt1i=[tt1(1):(tt1(2)-tt1(1))/4:tt1(end)];
  tssi=((tt1i<2/60)|(tt1i>=90/60)|((tt1i>=30/60)&(tt1i<=61/60)));

  xfix=mytrapezoid(tt1i,1/60,61/60,.25/60);
  ifix=find(tssi);
  iunfix=find(~tssi);

  sparms3=[sparms(5:end) xfix(iunfix)];
  parms2fit3=[1 6 9 13 length(sparms(5:end))+[1:length(iunfix)] ];
  slb3=[slb(5:end) xfix(iunfix)-0.7];
  sub3=[sub(5:end) xfix(iunfix)+0.7];

  sparms3ft=rand(size(sparms3)).*(sub3-slb3)+slb3;
  [avgE1i,avgC1i,Fout,VVt,CMRO2t,EEt,q,t]=myBOLD2(spamrs3(parms2fit3),tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1);
  avgE1ft=interp1(t,avgE1i,tt1i); avgE1ft=avgE1ft+noiseE1amp*randn(size(avgE1ft));
  avgC1ft=interp1(t,avgC1i,tt1i); avgC1ft=avgC1ft/avgC1ft(1)+noiseC1amp*randn(size(avgC1ft));

  x3=lsqnonlin(@myBOLD2,sparms3ft(parms2fit3),slb3(parms2fit3),sub3(parms2fit3),opt4,tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1i,[avgE1i;avgC1i]');
  [St,Fin,Fout,VVt,CMRO2t,EEt,q,t]=myBOLD2(x3,tparms,sparms3,parms2fit3,iunfix,[ifix;xfix(ifix)]',tt1);

  save cmro2fitvals3fittest

elseif (fittype==4),

  sparms=[sparms(1:4) 4*sparms(4)+4/60 sparms(5:end)];
  sparms(3)=sparms(3)-2/60;
  slb=[slb(1:4) slb(4) slb(5:end)];
  sub=[sub(1:4) 8*sub(4) sub(5:end)];

  % input[st,dur,ramp1,ramp2],tau,vk1,Vt,sk1
  parms2fit=[2 3 4 5 6 10 13 17];

  sparmsft=rand(size(sparms)).*(sub-slb)+slb;
  xft1=sparmsft(parms2fit);
  [avgE1i,avgC1i,Fout,VVt,CMRO2t,EEt,q,t]=myBOLDt(sparms(parms2fit),tparms,sparms,parms2fit);
  avgE1ft=interp1(t,avgE1i,tt1); avgE1ft=avgE1ft+noiseE1amp*randn(size(avgE1ft));
  avgC1ft=interp1(t,avgC1i,tt1); avgC1ft=avgC1ft/avgC1ft(1)+noiseC1amp*randn(size(avgC1ft));

  x1=lsqnonlin(@myBOLDt,sparmsft(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,[avgE1ft;avgC1ft]',tt1);
  [St,Fin,Fout,VVt,CMRO2t,EEt,q,t]=myBOLDt(x1,tparms,sparms,parms2fit);

  save cmro2fitvals4fittest

elseif (fittype==5),

  %ytype=[10 20 1 0.04];
  %ytype=[10 240 1 .01];
  sparms=[10 240 1 0.04 sparms(2:4) 4*sparms(4) sparms(5:end)];
  slb=[10 0.01 1e-3 1e-5 slb(2:4) slb(4) slb(5:end)];
  sub=[10 1e5 1e3 1e5 sub(2:4) 4*sub(4) sub(5:end)];

  % input[st,dur,ramp1,ramp2],tau,vk1,Vt,sk1
  parms2fit=[2 3 4 5 6 7 8 9 13 16 20];

  sparmsft=rand(size(sparms)).*(sub-slb)+slb;
  [avgE1i,avgC1i,Fout,VVt,CMRO2t,EEt,q,t]=myBOLDn(sparms(parms2fit),tparms,sparms,parms2fit);
  avgE1ft=interp1(t,avgE1i,tt1); avgE1ft=avgE1ft+noiseE1amp*randn(size(avgE1ft));
  avgC1ft=interp1(t,avgC1i,tt1); avgC1ft=avgC1ft/avgC1ft(1)+noiseC1amp*randn(size(avgC1ft));

  x1=lsqnonlin(@myBOLDn,sparmsft(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,[avgE1;avgC1]',tt1);
  [St,Fin,Fout,VVt,CMRO2t,EEt,q,t]=myBOLDn(x1,tparms,sparms,parms2fit);

  save cmro2fitvals5fittest

else,

  % input[st,dur,ramp],tau,vk1,Vt,sk1
  % input[st],tau,vk1,Vc,sk1
  parms2fit=[2 3 5 10 12 17];
  [avgE1i,avgC1i,Fout,VVt,CMRO2t,EEt,q,t]=myBOLD(sparms(parms2fit),tparms,sparms,parms2fit);
  avgE1ft=interp1(t,avgE1i,tt1); 
  avgE1ft=avgE1ft+noiseE1amp*randn(size(avgE1ft));
  avgC1ft=interp1(t,avgC1i,tt1); 
  avgC1ft=avgC1ft/avgC1ft(1)+noiseC1amp*randn(size(avgC1ft));

  for mmm=1:nreps,
    sparmsft=rand(size(sparms)).*(sub-slb)+slb;
    mmm,sparmsft,
    xft1(mmm,:)=lsqnonlin(@myBOLD,sparmsft(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,[avgE1ft;avgC1ft]',tt1);
    xft1o(mmm,:)=sparmsft(parms2fit);
    %[Stft(mmm,:),Finft(mmm,:),tmp1,tmp2,CMRO2tft(mmm,:)]=myBOLD(xft1(mmm,:),tparms,sparms,parms2fit);
    %err1(mmm,:)=[sum((avgE1i-Stft(mmm,:)).^2) sum((avgC1i-Finft(mmm,:)).^2)]; 
    save cmro2fitvals1fittest_tmp
  end;

  save cmro2fitvals1fittest


end;


if (doplots),
  figure(1)
  subplot(211)
  plot(tt1*60,avgC1ft,t*60,Fin/Fin(1))
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
end;

