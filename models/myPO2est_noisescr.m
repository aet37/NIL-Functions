
clear all
load KazutoData

CBF6i=CBF6i-mean(CBF6i(1:100)-1);
ii=[1:length(CBF6i)];

% PO2 noise level is about 1.25% or about 0.75% standard deviation
nn=[1 100 106 115 123 131 135 [145:10:185] 196 208 [218:30:480] 481 501];
PO26sim=interp1(nn(3:end),PO26f(nn(3:end)),ii(nn(3):end),'spline');
PO26sim=[ones(1,nn(3)-1)*PO26f(nn(3)) PO26sim];
PO26sim=PO26sim-(PO26sim(1)-1);
std_po2=0.0075;

% CBF noise level is about 4% or about 2% standard deviation
nn=[1 100 106 115 123 131 135 145 148 155 [165:10:195] 221 245 260 308 481 501];
CBF6sim=interp1(nn(3:end),CBF6i(nn(3:end)),ii(nn(3):end),'spline');
CBF6sim=[ones(1,nn(3)-1)*CBF6i(nn(3)) CBF6sim];
CBF6sim=CBF6sim-(CBF6sim(1)-1);
std_cbf=0.02;

tparms=[0.05 CBF6t(end)-CBF6t(1)]/60;
tparms(3)=0;

%    [F0 V0 Vk1 camp-1 P50 Vc Vct   PS    Pa  Pt  beta]
sparms=[150 2 12/60 0.3 26  1.0 98    7000 100  40  0.003];
slb=[30  1  1/60  -0.5 20 0.01 97.9  2000 80   0 0.00000];
sub=[120 10 40/60 +2.0 31 5.00 98.1  9000 300 70 10.00001];
sparms(11)=0.000;

nreps=20;

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

PO26sim=PO26sim(:);
CBF6sim=CBF6sim(:);

PO26sim_orig=PO26sim;
CBF6sim_orig=CBF6sim;
for mm=1:nreps,
  PO26sim(:,mm)=PO26sim_orig+std_po2*randn(size(PO26sim_orig));
  CBF6sim(:,mm)=CBF6sim_orig+std_cbf*randn(size(CBF6sim_orig));

  xx(mm,:)=lsqnonlin(@myPO2est,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6sim(:,mm) PO26sim(:,mm)]);
  [CCt(mm,:),CCc(mm,:),CMRO2t(mm,:),t]=myPO2est(xx(mm,:),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBF6t-CBF6t(1))/60,[CBF6sim(:,mm)]);

  save myPO2res_noisesim
end;



