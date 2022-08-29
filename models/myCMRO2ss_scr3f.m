
clear all
cd /net/aronofsky/data/towi
load co2_4vals

% 2 categories of types:
%  - first-order-hold sampler
%  - trapezoid-like

opt4=optimset('lsqnonlin');
opt4.TolFun=1e-10;
opt4.TolX=1e-10;
opt4.MaxIter=1000;
opt4.Display='iter';

% fix time to start at 0 and be in mins
tt1=tt1-tt1(1);
tt2=tt2-tt2(1);
if (tt1(2)>1), tt1=tt1/60; end;
if (tt2(2)>1), tt2=tt2/60; end;

% determine steady-state periods
tss1=((tt1<2/60)|(tt1>=90/60)|((tt1>=30/60)&(tt1<=61/60)));
tss2=((tt2<2/60)|(tt2>=90/60)|((tt2>=30/60)&(tt2<=61/60)));

tt1i=[tt1(1):(tt1(2)-tt1(1))/4:tt1(end)];
avgE1i=interp1(tt1,avgE1,tt1i);
avgC1i=interp1(tt1,avgC1,tt1i);
tss1i=((tt1i<2/60)|(tt1i>=90/60)|((tt1i>=30/60)&(tt1i<=61/60)));
xfix1=mytrapezoid(tt1i,6.0/60,55.5/60,5/60);
tt2i=[tt2(1):(tt2(2)-tt2(1))/4:tt2(end)];
avgE2i=interp1(tt2,avgE2,tt2i);
avgC2i=interp1(tt2,avgC2,tt2i);
tss2i=((tt2i<2/60)|(tt2i>=90/60)|((tt2i>=30/60)&(tt2i<=61/60)));
xfix2=mytrapezoid(tt2i,6.0/60,6.5/60,5/60);

% determine data set to use and parameters
datalabel=1;
tdata=tt1;
tdatai=tt1i;
data=[avgE1;avgC1]';
datai=[avgE1i;avgC1i]';
tssi=tss1i;
xfix=xfix1;

%parms2fit=[1 5 6 9 13 15 17 18 22];
parms2fit=[1 5 6 13 15 17 18 22];

% parameter definitions
Vv0=1.0;
tparms=[0.001 tdata(end)*60 3 1];
sparms=[ 1.0  60.0  0.1  0.1  0.0  0.0  1.5  rCMRO2-1  0.5  2.0  F0  rCBF-1  2.0 Vv0  0.2  Pa Pt  PS  26  1   96  0.5 ];
slb =  [ 0.0  56.0  0.05 0.05 0.0  0.0  0.1  0.0      0.05 0.05 30.0  0.0   0.05 0.5 0.001 80 0.0 2000 15 0.1 70 0.0];
sub =  [ 4.0  64.0  4.0  4.0  2.0 10.0  5.0  1.0     10.0  10.0 120.0 1.2  10.0  20.0  0.75 100 40 14000 35 2.0 500 10.0];


% here we go, fit the model!
ifix=find(tssi);
iunfix=find(~tssi);
if (tparms(3)==0)|(tparms(4)==0)
  sparms=[sparms xfix(iunfix)];
  parms2fit=[parms2fit length(sparms)+[1:length(iunfix)] ];
  slb=[slb xfix(iunfix)-0.7];
  sub=[sub xfix(iunfix)+0.7];
end;
if (tparms(3)==0)|(tparms(4)==0)
  %xx=lsqnonlin(@myBOLDf,sparms(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,tdatai,datai,iunfix,[ifix;xfix(ifix)]');
  %[BOLD,Fin,Fout,Vv,CMRO2t,EEt,q,U,fneu,S,t]=myBOLDf(xx,tparms,sparms,parms2fit,tdatai);
  [BOLD,Fin,Fout,Vv,CMRO2t,EEt,q,U,fneu,S,t]=myBOLDf(sparms(parms2fit),tparms,sparms,parms2fit,tadatai,iunfix,[ifix;xfix(ifix)]');
  err=myBOLDf(sparms(parms2fit),tparms,sparms,parms2fit,tdatai,datai,iunfix,[ifix;xfix(ifix)]');
else,
  %xx=lsqnonlin(@myBOLDf,sparms(parms2fit),slb(parms2fit),sub(parms2fit),opt4,tparms,sparms,parms2fit,tdata,data);
  %[BOLD,Fin,Fout,Vv,CMRO2t,EEt,q,U,fneu,S,t]=myBOLDf(xx,tparms,sparms,parms2fit,tdata);
  [BOLD,Fin,Fout,Vv,CMRO2t,EEt,q,U,fneu,S,t]=myBOLDf(sparms(parms2fit),tparms,sparms,parms2fit);
  err=myBOLDf(sparms(parms2fit),tparms,sparms,parms2fit,tdata,data);
end;

% save the data
outname=sprintf('cmro2fitvals%d_%d_%d',datalabel,tparms(3),tparms(4));
eval(sprintf('save %s',outname));

% plot the results
figure(1)
subplot(211)
plot(tdata*60,data(:,2),t*60,Fin/Fin(1))
ylabel('rCBF'),
axis('tight'), grid('on'),
fatlines, dofontsize(15);
subplot(212)
plot(t*60,CMRO2t/CMRO2t(1))
ylabel('CMRO2'), xlabel('Time'),
axis('tight'), grid('on'),
fatlines, dofontsize(15);
eval(sprintf('print -dpng %s_fig1',outname));
figure(2)
subplot(211)
plot(t*60,EEt)
ylabel('OEF'),
axis('tight'), grid('on'),
fatlines, dofontsize(15);
subplot(212)
plot(tdata*60,data(:,1),t*60,BOLD)
ylabel('BOLD'), xlabel('Time'),
axis('tight'), grid('on'),
fatlines, dofontsize(15);
eval(sprintf('print -dpng %s_fig2',outname));

