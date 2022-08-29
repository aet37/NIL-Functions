
clear all

load ratpo2combined_summ2lp
tt=avgdyn1lp_new.tt;
yo=avgdyn1lp_new.pO2Bcalfilt*avgdyn1lp_new.pO2Bcalfiltbase;
%load ratpo2combined_summ2
%tt=avgdyn1np_new.tt;
%yo=avgdyn1np_new.LDFfilt;

%load ratois_summ
%tt=avgdyn1lp_ois.tt;
%yo=avgdyn1lp_ois.pB_roi*mean(avgdyn1lp_ois.pB_roi_base_all);

ii0=find((tt<0)&(tt>-5));
ii9=find((tt<75)&(tt>70));
ii2=find((tt>-4)&(tt<70));
%ii2=find((tt>-4)&(tt<20));
%ii2=find((tt>16)&(tt<50));

dt=tt(2)-tt(1);
tmpp=polyfit(tt([ii0 ii9]),yo([ii0 ii9])',1);
tmpd=polyval(tmpp,tt);
yo_d=yo-tmpd'+mean(tmpd);
yo_d=myfilter(yo_d,4,dt);
yo_n=yo_d/mean(yo_d(ii0));

yy=1-yo_n;
%yy=yo_n-1;
ww=zeros(size(tt));
ww(ii2)=1;



opt2=optimset('lsqnonlin');
opt2.TolX=1e-8;
opt2.TolPCG=1e-2;
opt2.TolFun=1e-8;
opt2.DiffMinChange=1e-10;


% tau amp t0 u_wid u_ramp
xg=[5.0   0.2   0.0   21.0  dt];
xl=[0.0   -1.0  -2.0   15.0  dt/4];
xu=[20.0  4.0   12.0  25.0  20];

parms2fit=[1 2 3 4];
%parms2fit=[1 2];

xg1=xg;
xx1=lsqnonlin(@lin52,xg1(parms2fit),xl(parms2fit),xu(parms2fit),opt2,xg1,parms2fit,tt,yy,ww);

xg1(parms2fit)=xx1;
[zz1,uu1]=lin52(xx1,xg1,parms2fit,tt);

subplot(211)
plot(tt,uu1)
axis('tight'), grid('on'),
subplot(212)
plot(tt,yy,tt,zz1)
axis('tight'), grid('on'),


