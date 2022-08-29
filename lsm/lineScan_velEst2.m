function y=lineScan_velEst(lns,vparms,ycols)
% Usage ... ystruct=lineScan_velEst(ldata,vparms,ycols)
%
% vparms=[ynblock ynskip smw sthrf]  (e.g. [512 256 1.5 0.3])
% ycols=[10:10:100] 


tln=1;
dx=size(lns,2);
dz=size(lns,1);
dt=1;

nlines=size(lns,1);
linedim=size(lns,2);
ynblock=vparms(1);
ynskip=vparms(2);
smw=vparms(3);
sthrf=vparms(4);

lns0=lns(1:ynblock,:,1);
smlns0=real(im_smooth(lns0,smw));

% from visual inspection: 20:20:90 looks good
nycols=length(ycols);

for nn=2:nycols,
  yl1=smlns0(:,ycols(1));
  yl2=smlns0(:,ycols(nn));
  ydd0_alt(nn-1,:)=disp1d_alt(yl1,yl2,1.25,[1 2 0]);
end;

for oo=1:size(lns,3),
  for mm=1:floor(nlines/ynskip)-floor(ynblock/ynskip)+1,
    %disp(sprintf('  %d to %d',(mm-1)*ynskip+1,(mm-1)*ynskip+ynblock));
    tmpii=[(mm-1)*ynskip+1:(mm-1)*ynskip+ynblock];
    lns1=lns(tmpii,:,oo);
    smlns1=real(im_smooth(lns1,smw));
    yl1=smlns1(:,ycols(1));
    for nn=2:nycols,
      yl2=smlns1(:,ycols(nn));
      tmp_ydd_alt=disp1d_alt(yl1,yl2,1.25,[1 2 0]);
      ydd_alt(mm,nn-1,oo,:)=tmp_ydd_alt;
    end;
  end;
end;

xi=ycols(2:end)'-ycols(1);
for oo=1:size(ydd_alt,3), for mm=1:size(ydd_alt,1),
  tmp_ydd_alt=squeeze(ydd_alt(mm,:,oo,1))';
  tmpii=find((tmp_ydd_alt>0)&(abs(tmp_ydd_alt)<sthrf*linedim));
  if isempty(tmpii),
    tmpii=find((-tmp_ydd_alt>0)&(abs(tmp_ydd_alt)<sthrf*linedim));
  end;
  if isempty(tmpii),
    tmpbeta=[0 0 0];
  else,
    tmpbeta=polyfit([0;xi(tmpii)],[0;tmp_ydd_alt(tmpii)],1);
    %tmpval=polyval(tmpbeta,xi);
    %plot(xi,[tmp_ydd_alt(:) tmpval(:)])
    %pause,
    tmpbeta(3)=length(tmpii);
  end;
  ydd_beta(:,mm,oo)=tmpbeta';
end; end;

yv_est=ydd_beta(1,:,:)*dt/dx*1e-3;

%plot(yv_est)


y.yv_est=yv_est;
y.ydd_beta=ydd_beta;
y.nlines=nlines;
y.linedim=linedim;
y.vparms=vparms;
y.ycols=ycols;
y.dx=dx;
y.dz=dz;
y.dt=dt;
y.tln=tln;
y.lns0=lns0;
y.smlns0=smlns0;


