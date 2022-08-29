
clear all

opt2=optimset('lsqnonlin');

dCMR=0.2370;
dF=0.6346;

load co2_4vals
dCMR=rCMRO2-1;
dF=rCBF-1;


clear x1 xx xx2 EEb CMRO2b
F0=50;
PS=6070;


E0=0.4; dE=0.2;
Pa=90;

x0=[20];
xlb=[1];
xub=[40];

xx=lsqnonlin(@myCMRO2ss3,x0,xlb,xub,opt2,[dF Pa F0 PS],dCMR);

[CMRO2,EE]=valabregue3fff(F0*[1 1+dF],PS,Pt,Pa);


opt3=optimset('fminsearch');
x1=rand([50 1]);
x1(:,1)=x1(:,1)*(xub(1)-xlb(1))+xlb(1);

for mm=1:length(x1),
  xx2(mm,:)=fminsearch(@myCMRO2ss3,x1(mm,:),opt3,[dF Pa F0 PS],dCMR,2);
  [CMRO2b(mm),EEb(mm)]=valabregue3fff(F0,PS,xx2(mm,1),Pa);
end;
%ii=find((EEb>(E0-dE))&(EEb<(E0+dE)));
%EEavg=mean(EEb(ii)); EEstd=std(EEb(ii));
%ii2=find((EEb>(EEavg-0.01))&(EEb<(EEavg+0.01)));
%ii3=find((EEb>(EEavg+EEstd-0.01))&(EEb<(EEavg+EEstd+0.01)));
%ii4=find((EEb>(EEavg-EEstd-0.01))&(EEb<(EEavg-EEstd+0.01)));

xx3b=fminsearch(@myCMRO2ss3,mean(xx2),opt3,[dF Pa F0 PS],dCMR,2);

Pt=xx3b(1);

[CMRO2,EE]=valabregue3fff(F0*[1 1+dF],PS,Pt,Pa);
[CMRO2v,EEv]=valabregue3fff(F0*avgC1,PS,Pt,Pa);


