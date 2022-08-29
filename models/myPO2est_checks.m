
clear all
cdt
cd workdata
load KazutoData

CBF6i=CBF6i-mean(CBF6i(1:100)-1);
ii=[1:length(CBF6i)];

tparms=[0.05 CBF6t(end)-CBF6t(1)]/60;
tparms(3)=0;

%    [F0 V0 Vk1 camp-1 P50 Vc Vct   PS    Pa  Pt  beta]
sparms=[150 2 12/60 0.3 26  1.0 98    7000 100  40  0.003];
slb=[30  1  1/60  -0.5 20 0.01 97.9  2000 80   0 0.00000];
sub=[200 10 40/60 +2.0 31 5.00 98.1  9000 300 70 10.00001];
sparms(11)=0.000;

sparms2=sparms;
sparms2(1,:)=sparms; sparms2(1,1)=100;
sparms2(2,:)=sparms; sparms2(2,1)=125;
sparms2(3,:)=sparms; sparms2(3,1)=150;
sparms2(4,:)=sparms; sparms2(4,4)=0.1;
sparms2(5,:)=sparms; sparms2(5,4)=0.3;
sparms2(6,:)=sparms; sparms2(6,4)=0.5;
sparms2(7,:)=sparms; sparms2(7,6)=0.2;
sparms2(8,:)=sparms; sparms2(8,6)=1.0;
sparms2(9,:)=sparms; sparms2(9,6)=5.0;
sparms2(10,:)=sparms; sparms2(10,8)=3000;
sparms2(11,:)=sparms; sparms2(11,8)=5000;
sparms2(12,:)=sparms; sparms2(12,8)=7000;
sparms2(13,:)=sparms; sparms2(13,9)=70;
sparms2(14,:)=sparms; sparms2(14,9)=90;
sparms2(15,:)=sparms; sparms2(15,9)=110;

% we are going to allow values over 1 after 5s
ttt=[0:tparms(1)*10:tparms(2)]';
tss=((ttt<7/60)|(ttt>=40/60)|((ttt>=14.6/60)&(ttt<=15.0/60)));
ifix=find(tss');
iunfix=find(~tss');
% fast initial guess
xfix=mytrapezoid3(ttt*60,9.5,8.0,0.2);
% moderately slow initial guess
%xfix=mytrapezoid3(ttt*60,9,5.5,[1.0 3.0]);
% other initial guesses
%xfix=mysol([1/.6],[1 1/.6],mytrapezoid(ttt*60,10.1,6,0.1),ttt*60);
%xfix=xfix/max(xfix);
xopt=optimset('lsqnonlin');
xopt.TolFun=1e-10;
xopt.TolX=1e-8;
%xopt.MaxIter=1000;
xopt.Display='iter';

parms2fit=[length(sparms)+[1:length(iunfix)]];
sparms=[sparms xfix(iunfix)'];
sub=[sub xfix(iunfix)'+1.5];	% around +1.0
slb=[slb xfix(iunfix)'-1.5];	% around -1.0

[CCt_0,CCc_0,CMRO2t_0,t]=myPO2est(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6sim(:)]);
%[CCt,CCc,CMRO2t,t]=myPO2est(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:)]);

for mm=1:size(sparms2,1),
  xx(mm,:)=lsqnonlin(@myPO2est,sparms2(parms2fit,mm),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms2(mm,:),parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:) PO26f(:)]);
  [CCt(mm,:),CCc(mm,:),CMRO2t(mm,:),t]=myPO2est(xx(mm,:),tparms,sparms2(mm,:),parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6i(:)]);
end;

save myPO2res_checks


