function rr=estOrientVol1(data,parms)
% Usage ... r=estOrientVol1(data,parms)

do_verbose=1;

p12=mean(data,3);
p13=squeeze(mean(data,2));
p23=squeeze(mean(data,1));

rx=[-10:0.5:10]; rxi=[-10:0.1:10];
ry=[-10:0.5:10]; ryi=[-10:0.1:10];

for mm=1:length(rx),
  tmpim=imrotate(p13,rx(mm),'bilinear','crop');
  vx(:,mm)=squeeze(mean(tmpim,1));
end;
vxx=max(vx,[],1);
vxxi=interp1(rx,vxx,rxi,'spline');
[tmpmax_rx,tmpmaxi_rx]=max(vxxi);

for mm=1:length(ry),
  tmpim=imrotate(p23,ry(mm),'bilinear','crop');
  vy(:,mm)=squeeze(mean(tmpim,1));
end;
vyy=max(vy,[],1);
vyyi=interp1(ry,vyy,ryi,'spline');
[tmpmax_ry,tmpmaxi_ry]=max(vyyi);

rr=[rxi(tmpmaxi_rx),ryi(tmpmaxi_ry)];

if do_verbose,
  p13x=imrotate(p13,rr(1),'bilinear','crop');
  p23x=imrotate(p23,rr(2),'bilinear','crop');
  figure(1),
  subplot(221), show(p12),
  subplot(222), show([p13 p13x]),
  subplot(223), show([p23 p23x]),
  figure(2),
  subplot(211), plot(rxi,vxxi),
  subplot(212), plot(ryi,vyyi),
  disp(sprintf('  est rxy= [%.1f, %.1f]',rr(1),rr(2)));
end;

