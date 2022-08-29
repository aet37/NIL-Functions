
clear all
load cbfres1b tf3 avgFF3 avgFF4
load cbvres1b tv3 avgVV3a avgVV3b tv4 avgVV4a avgVV4b 

tdata=tv3-tv3(1);
data=avgVV3a;

opt4=optimset('lsqnonlin');

tparms=[0.01 tdata(end)];

xg= [2.0  60.0  4.0  4.0  2.0  3.0  3.0  3.0  60.0];
xlb=[0.1  58.0  0.1  0.1  0.0  0.1  0.1  0.1  0.1];
xub=[4.0  62.5  9.0  10.0 10.0 5.0  100  100  1000];

parms2fit=[1 2 3 4 5 6 7 8 9];
xx=lsqnonlin(@complG4f,xg(parms2fit),xlb(parms2fit),xub(parms2fit),opt4,tparms,xg,parms2fit,data,tdata);
[yy,u1,uu,ff]=complG4f(xx,tparms,xg,parms2fit);
tt=[0:tparms(1):tparms(2)];

tdata2=tv3-tv3(1);
data2=avgVV3a-avgVV3b+1;

%xg2= [5.0  56.0  4.0  4.0  0.0  3.0 18.0 18.0  80.0];
xg2= [2.0  60.0  4.0  4.0  2.0  3.0  3.0  3.0  60.0];
xlb2=[0.1  54.0  0.1  0.1  0.0  0.1  0.1  0.1  0.1];
xub2=[8.0  67.5  12.0  10.0 10.0 5.0  100  100  1000];

tparms2=[0.01 tdata2(end)];
xx2=lsqnonlin(@complG4f,xg2(parms2fit),xlb2(parms2fit),xub2(parms2fit),opt4,tparms2,xg2,parms2fit,data2,tdata2);
[yy2,u2,uu2,ff2]=complG4f(xx2,tparms2,xg2,parms2fit);
tt2=[0:tparms2(1):tparms2(2)];

figure(1)
subplot(211)
plot(tdata,data,tt,yy)
subplot(212)
plot(tdata2,data2,tt2,yy2)

figure(2)
plot(tdata,data,'b--',tt,yy,'b-',tdata2,data2,'r--',tt2,yy2,'r-')
legend('AVIS unspoiled','Model Fit','AVIS','Model Fit')

