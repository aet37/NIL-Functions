
ctparms=[tparms(1:2) 1 0];

cparms=[9/60 6/60 0.1/60 0.0  1.5/60  0.5  3.0/60];
clb=[6/60  1.0/60  0.1/60 0.0 1.0/60  0.0 0.1/60];
cub=[14/60 10.0/60 2.0/60 10.0 2.0/60 4.0 20.0/60];

cparms2fit=[1 2 6 7];

copt=optimset('lsqnonlin');
copt.TolFun=1e-10;
copt.TolX=1e-8;
cxopt.MaxIter=1000;
copt.Display='iter';

[CMRO2m0,fneu0]=myCMRO2model([],ctparms,cparms,[]);
cxx=lsqnonlin(@myCMRO2model,cparms(cparms2fit),clb(cparms2fit),cub(cparms2fit),copt,ctparms,cparms,cparms2fit,t,CMRO2t/CMRO2t(1));
[CMRO2m,fneu,ct]=myCMRO2model(cxx,ctparms,cparms,cparms2fit);

[cxx([1 2])*60 cxx(3) cxx(4)*60],

subplot(211)
plot(ct*60,fneu)
ylabel('f_{neu}'),
axis('tight'), grid('on'), fatlines; dofontsize(15);
subplot(212)
plot(ct*60,CMRO2m,t*60,CMRO2t/CMRO2t(1))
ylabel('CMR_{02}/CMR_{O20}'), xlabel('Time'),
axis('tight'), grid('on'), fatlines; dofontsize(15);

