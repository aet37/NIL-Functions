function y=lin41_scr(data,tt,x0)
% Usage ... y=lin41_scr(data,tt,x0)

opt2=optimset('lsqnonlin');

%xg=[1.0   0.1   7.04   0.057  0.126  0.312  0.0002];
xg=[0.5   0.1   7.6   0.0611  0.146  0.321  0.000215];
xl=[0.0   0.0   0.1    1e-5   1e-5   1e-5   1e-7];
xu=[6.0   4.0   12.0    10.0   1000   1000   10000];

%parms2fit=[1 3 4 5 6 7];
parms2fit=[1 3 7];

xtyp=xg;
opt2.TypicalX=xtyp(parms2fit);
opt2.TolX=1e-8;
opt2.TolPCG=1e-2;
opt2.TolFun=1e-8;
opt2.DiffMinChange=1e-10;


xg1=xg;
xx1=lsqnonlin(@lin41,xg1(parms2fit),xl(parms2fit),xu(parms2fit),opt2,t,u1,xg1,parms2fit,data);

[yy1,ww1,vv1]=lin41(xx1,t,u1,xg,parms2fit);

