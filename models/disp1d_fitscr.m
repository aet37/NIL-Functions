

xopt=optimset('lsqnonlin');
xopt.TolFun=1e-10;
xopt.TolX=1e-8;
%xopt.MaxIter=1000;
xopt.Display='iter';

x0=[0 0 0];
xlb=[0 0.25 0];
xub=[length(line)*0.6 4 1];

parms2fit=[1 2];

xx=lsqnonlin(@disp1d,x0(pamrs2fit),xlb(parms2fit),xub(parms2fit),xopt,parms,parms2fit,l1,l2);
[err,yline,cline]=disp1d(xx,parms,parms2fit,l1,l2);

