
clear all

ni=1;
nvols=32;
nreps=4;
slinfo=[64 64 2];
ni=2*ni-1;

for m=1:nvols,
  tmpm(:,:,m)=getslim('tap5/',1,m,slinfo);
  tmpp(:,:,m)=getslim('tap5/',1,m,slinfo,'phs')/1000;
end;

for m=1:nvols/2,
  tmpmd(:,:,m)=tmpm(:,:,2*m-1)-tmpm(:,:,2*m);
  tmpcd(:,:,m)=tmpm(:,:,2*m-1).*exp(j*tmpp(:,:,2*m-1));
  tmpcd(:,:,m)=tmpcd(:,:,m) - tmpm(:,:,2*m).*exp(j*tmpp(:,:,2*m));
end;

irtime=[15 50 100 300 1000 2000 4000 7000]*1e-3;
irf=[-1 -1 -1 -1 -1 -1 +1 +1];

zz=([1:slinfo(1)]-slinfo(1)/2)*200/slinfo(1);

thr=0.25*max(max(tmpm(:,:,1)));
mask=tmpm(:,:,1)>thr;
pix=getimpix(mask);
pix=[32 32;31 31;30 30];
disp(sprintf('Fitting %d locs...',size(pix,1)));

for m=1:size(pix,1),
  irval1(:,m)=(squeeze(tmpm(pix(m,1),pix(m,2),ni:nreps:nvols))'.*irf).';
  irval1c(:,m)=(squeeze(tmpm(pix(m,1),pix(m,2),ni:nreps:nvols).*exp(j*tmpp(pix(m,1),pix(m,2),ni:nreps:nvols))));
  irval2(:,m)=(squeeze(tmpm(pix(m,1),pix(m,2),ni+1:nreps:nvols))'.*irf).';
  irval2c(:,m)=(squeeze(tmpm(pix(m,1),pix(m,2),ni+1:nreps:nvols).*exp(j*tmpp(pix(m,1),pix(m,2),ni+1:nreps:nvols))));

  [T1_1(m),I0_1(m),alpha_1(m)]=calcT1(irtime(1:end)',irval1(1:end,m));
  [T1_2(m),I0_2(m),alpha_2(m)]=calcT1(irtime(1:end)',irval2(1:end,m));
  [T1_3(m),I0_3(m),alpha_3(m)]=calcT1(irtime(1:end)',abs(irval2(1:end,m)));
  %myopts=optimset('lsqnonlin');
  %xx=lsqnonlin('monoexpfit',[-500 0.2 800],[-1e5 1e-6 -1e5],[1e5 100 1e5],myopts,irtime',abs(irval2));

  y1(:,m)=irfit([I0_1(m) T1_1(m) alpha_1(m)],irtime');
  y2(:,m)=irfit([I0_2(m) T1_2(m) alpha_2(m)],irtime');
  y3(:,m)=irfit([I0_3(m) T1_3(m) alpha_3(m)],irtime');
  %y3=monoexpfit(xx,irtime);
end;

[aT1_1,aI0_1,aalpha_1]=calcT1(irtime(1:end)',mean(irval1(1:end,:)')');
[aT1_2,aI0_2,aalpha_2]=calcT1(irtime(1:end)',mean(irval2(1:end,:)')');
[aT1_3,aI0_3,aalpha_3]=calcT1(irtime(1:end)',abs(mean(irval2(1:end,:)')'));

ay1=irfit([aI0_1 aT1_1 aalpha_1],irtime');
ay2=irfit([aI0_2 aT1_2 aalpha_2],irtime');
ay3=irfit([aI0_3 aT1_3 aalpha_3],irtime');

if length(I0_1)==1,
  [T1_1 T1_2],
  [alpha_1 alpha_2],
else,
  [mean(T1_1) min(T1_1) max(T1_1)]
  [mean(T1_2) min(T1_2) max(T1_2)]
  [mean(alpha_1) min(alpha_1) max(alpha_1)]
  [mean(alpha_2) min(alpha_2) max(alpha_2)]
end;

save tmp_t1meas

subplot(211)
plot(irtime',mean(irval1')',irtime',ay1)
subplot(212)
plot(irtime',mean(irval2')',irtime',ay2)
%subplot(313)
%plot(zz,abs(tmpcd(32,:,1)),zz,tmpmd(32,:,1))


