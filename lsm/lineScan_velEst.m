function y=lineScan_velEst(lsmname,chName,vparms,ycols)
% Usage ... ystruct=lineScan_velEst(lsmname,chName,vparms,ycols)
%
% chName={'blue' or 'red' or 'green' or 'data'}
% vparms=[ynblock ynskip smw sthrf]  (e.g. [512 256 1.5 0.3])
% ycols=[10:10:100] 


fname=lsmname;
stk=tiffread2c(fname);
info=lsminfo(fname);

eval(sprintf('lns=double(stk.%s);',chName));
tln=info.TimeStamps.TimeStamps;
dx=info.VoxelSizeX;
dz=info.VoxelSizeZ;
dt=mean(diff(tln));

nlines=size(lns,1);
linedim=size(lns,2);
ynblock=vparms(1);
ynskip=vparms(2);
smw=vparms(3);
sthrf=vparms(4);

lns0=lns(1:ynblock,:);
smlns0=real(im_smooth(lns0,smw));

% from visual inspection: 20:20:90 looks good
nycols=length(ycols);

for nn=2:nycols,
  yl1=smlns0(:,ycols(1));
  yl2=smlns0(:,ycols(nn));
  ydd0_alt(nn-1,:)=disp1d_alt(yl1,yl2,1.25,[1 2 0]);
end;

for mm=1:floor(nlines/ynskip)-floor(ynblock/ynskip),
  %disp(sprintf('  %d to %d',(mm-1)*ynskip+1,(mm-1)*ynskip+ynblock));
  tmpii=[(mm-1)*ynskip+1:(mm-1)*ynskip+ynblock];
  tt1(mm)=tln(round(mean(tmpii)));
  lns1=lns(tmpii,:);
  smlns1=real(im_smooth(lns1,smw));
  yl1=smlns1(:,ycols(1));
  for nn=2:nycols,
    yl2=smlns1(:,ycols(nn));
    tmp_ydd_alt=disp1d_alt(yl1,yl2,1.25,[1 2 0]);
    ydd_alt(mm,nn-1,:)=tmp_ydd_alt;
  end;
end;

xi=ycols(2:end)'-ycols(1);
for mm=1:size(ydd_alt,1),
  tmp_ydd_alt=squeeze(ydd_alt(mm,:,1))';
  tmpii=find((tmp_ydd_alt>0)&(abs(tmp_ydd_alt)<sthrf*linedim));
  if isempty(tmpii),
    tmpbeta=[0 0 0];
  else,
    tmpbeta=polyfit([0;xi(tmpii)],[0;tmp_ydd_alt(tmpii)],1);
    %tmpval=polyval(tmpbeta,xi);
    %plot(xi,[tmp_ydd_alt(:) tmpval(:)])
    %pause,
    tmpbeta(3)=length(tmpii);
  end;
  ydd_beta(:,mm)=tmpbeta';
end;

yv_est=ydd_beta(1,:)*dt/dx*1e-3;

%plot(tt1,yv_est)


y.yv_est=yv_est;
y.ydd_beta=ydd_beta;
y.tt1=tt1;
y.lsmname=lsmname;
y.chName=chName;
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


