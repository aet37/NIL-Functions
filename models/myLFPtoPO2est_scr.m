
clear all
load KazutoData


LFPtl=LFPtl-LFPtl(1);
PO2tt=[LFPtl(1):LFPtl(2)-LFPtl(1):PO26t(end)];
LFPtt=PO2tt;

LFP6y=zeros(size(LFPtt));
LFP6y(1:length(LFPtl))=LFP6l';
PO26y=interp1(PO26t,PO26f,PO2tt);


tparms=[2 3];
sparms=[0.1 0.1 0.2 0.3 0.6 10];

sub=1e5*ones(size(sparms));
slb=1e-10*ones(size(sparms));
parms2fit=[1 2 3 4];

xopt=optimset('lsqnonlin');
xopt.TolFun=1e-10;
xopt.TolX=1e-8;
%xopt.MaxIter=1000;
xopt.Display='iter';

%[yy,hh]=myLFPtoPO2est(sparms,tparms,sparms,parms2fit,LFPtt(:),LFP6y(:));
[xx,xresn,xres,xexflag,xout,xlam,xjac]=lsqnonlin(@myLFPtoPO2est,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,LFPtt(:),LFP6y(:),PO26y(:));
[yy,hh]=myLFPtoPO2est(xx,tparms,sparms,parms2fit,LFPtt(:),LFP6y(:));

subplot(311)
plot(LFPtt,LFP6y)
subplot(312)
plot(LFPtt,hh)
subplot(313)
plot(PO2tt,PO26y,PO2tt,yy)

