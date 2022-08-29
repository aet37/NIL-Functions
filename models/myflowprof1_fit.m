function [parms,vprof]=myflowprof1_fit(rr,vv,parms,parms2fit)
% Usage ... y=myflowprof1_fit(rr,vv,parms,parms2fit)
%
% parms=[r0pos, diam, pow, vmax];

xopt=optimset('lsqnonlin');
xopt.Tol=1e-8;

plb=[parms(1)-0.2*parms(2) parms(2)*0.9 1 1e-6];
pub=[parms(1)+0.2*parms(2) parms(2)*1.25 16 4e3];

xx=lsqnonlin(@myflowprof1,parms(parms2fit),plb(parms2fit),pub(parms2fit),xopt,parms,parms2fit,rr,vv);
vprof=myflowprof1(xx,parms,parms2fit,rr);

rri=[min(rr):(max(rr)-min(rr))/100:max(rr)];
vprofi=myflowprof1(xx,parms,parms2fit,rri);
%myflowprof1(xx,parms,parms2fit,rr,vv);

plot(rr,vv,'x',rri,vprofi)
parms(parms2fit)=xx;
title(sprintf('r0=%.2f dd=%.2f pow=%.2f vmax=%.3f',parms(1),parms(2),parms(3),parms(4)))

