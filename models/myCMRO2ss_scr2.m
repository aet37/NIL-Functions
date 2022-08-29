
clear all

opt2=optimset('lsqnonlin');

dCMR=0.2370;
dF=0.6346;

load co2_4vals
dCMR=rCMRO2-1;
dF=rCBF-1;



E0=0.4; dE=0.2;
Pa=90;

x0=[50 7200 20];
xlb=[30 2000 1];
xub=[100 9000 40];

xx=lsqnonlin(@myCMRO2ss,x0,xlb,xub,opt2,[dF Pa],dCMR);

F0=xx(1);
PS=xx(2);
Pt=xx(3);

[CMRO2,EE]=valabregue3fff(F0*[1 1+dF],PS,Pt,Pa);


opt3=optimset('fminsearch');
x1=rand([500 3]);
x1(:,1)=x1(:,1)*(xub(1)-xlb(1))+xlb(1);
x1(:,2)=x1(:,2)*(xub(2)-xlb(2))+xlb(2);
x1(:,3)=x1(:,3)*(xub(3)-xlb(3))+xlb(3);

for mm=1:length(x1),
  xx2(mm,:)=fminsearch(@myCMRO2ss,x1(mm,:),opt3,[dF Pa],dCMR,2);
  [CMRO2b(mm),EEb(mm)]=valabregue3fff(xx2(mm,1),xx2(mm,2),xx2(mm,3),Pa);
end;
ii=find((EEb>(E0-dE))&(EEb<(E0+dE)));
EEavg=mean(EEb(ii)); EEstd=std(EEb(ii));
ii2=find((EEb>(EEavg-0.01))&(EEb<(EEavg+0.01)));
ii3=find((EEb>(EEavg+EEstd-0.01))&(EEb<(EEavg+EEstd+0.01)));
ii4=find((EEb>(EEavg-EEstd-0.01))&(EEb<(EEavg-EEstd+0.01)));

xx3a=fminsearch(@myCMRO2ss,mean(xx2),opt3,[dF Pa],dCMR,2);
xx3b=fminsearch(@myCMRO2ss,mean(xx2(ii,:)),opt3,[dF Pa],dCMR,2);
xx3c=fminsearch(@myCMRO2ss,mean(xx2(ii2,:)),opt3,[dF Pa],dCMR,2);
xx3d=fminsearch(@myCMRO2ss,mean(xx2(ii3,:)),opt3,[dF Pa],dCMR,2);
xx3e=fminsearch(@myCMRO2ss,mean(xx2(ii4,:)),opt3,[dF Pa],dCMR,2);

F0=xx3b(1);
PS=xx3b(2);
Pt=xx3b(3);

[CMRO2,EE]=valabregue3fff(F0*[1 1+dF],PS,Pt,Pa);
[CMRO2v,EEv]=valabregue3fff(F0*avgC1,PS,Pt,Pa);

xx2ii=ii;

save co2_4vals -append E0 dE Pa F0 PS Pt xx2 xx2ii EEb CMRO2b CMRO2 CMRO2v EE EEv

