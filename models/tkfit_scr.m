
xopt=optimset('lsqnonlin');
xopt.TolFun=1e-10;
xopt.TolX=1e-8;
%xopt.MaxIter=1000;
xopt.Display='iter';

x0=[0.5 50 10 220 20 1];
xlb=[0.1 10 0.1 100 10 0];
xub=[0.9 150 40 250 100 1];

parms2fit=[1 2 3 4 5];

y0=tkfit([],x0,[],dd_bin2);
xx=lsqnonlin(@tkfit,x0(parms2fit),xlb(parms2fit),xub(parms2fit),xopt,x0,parms2fit,dd_bin2,rr_bin2);
yy=tkfit(xx,x0,parms2fit,dd_bin2);

plot(dd_bin2,rr_bin2,dd_bin2,yy)

xxs=lsqnonlin(@tkfit,x0(parms2fit),xlb(parms2fit),xub(parms2fit),xopt,x0,parms2fit,dd_s,rr_s);
yys=tkfit(xxs,x0,parms2fit,dd_s);
plot(dd_s,rr_s,dd_s,yys)

pause,

xx2=lsqnonlin(@tkfit,x0(parms2fit),xlb(parms2fit),xub(parms2fit),xopt,x0,parms2fit,dd_bin2_new,rr_bin2);
yy2=tkfit(xx2,x0,parms2fit,dd_bin2);

plot(dd_bin2,rr_bin2,dd_bin2,yy)

