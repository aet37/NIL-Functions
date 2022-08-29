function y=tmp_myOIScmro2(ldf,ois620,ois570,parms)
% Usage ... y=tmp_myOIScmro2(ldf,ois620,ois570,parms)
%
% parms = [cHbT0 S0 gR gT]

if nargin<4, parms=[100e-6 0.6 1 1]; end;

do_interp=0;
if iscell(ois620),
  tt_ois620=ois620{1};
  ois620=ois620{2};
  do_interp=1;
  y.tt=tt_ois620;
end;
if iscell(ldf),
  tt_ldf=ldf{1};
  ldf=ldf{2};
  if do_interp, ldf=interp1(tt_ldf(:),ldf(:),tt_ois620(:)); end;
end;
if iscell(ois570),
  tt_ois570=ois570{1};
  ois570=ois570{2};
  if do_interp, ois570=interp1(tt_ois570(:),ois570(:),tt_ois620(:)); end;
end;


D_570=0.05;
D_620=0.25;
eHbO_570=mean(getNIRSec(572+[-7:7],'hbo'));
eHbR_570=mean(getNIRSec(572+[-7:7],'hbr'));
eHbO_620=mean(getNIRSec(620+[-7:7],'hbo'));
eHbR_620=mean(getNIRSec(620+[-7:7],'hbr'));

cHbT0=parms(1);
S0=parms(2); 
cHbR0=(1-S0)*cHbT0; 
cHbO0=S0*cHbT0;

gR=parms(3); 
gT=parms(4);

eInv=inv([eHbR_620 eHbO_620; eHbR_570 eHbO_570]');     


cHbR_620=-log(ois620)/(D_620*eHbR_620);
tmp_decomp=-[log(ois620(:))'/D_620; log(ois570(:))'/D_570]'*eInv;
cHbR=tmp_decomp(:,1);
cHbO=tmp_decomp(:,2);
cHbT=sum(tmp_decomp,2);

cmro2_620=ldf(:).*(1+cHbR_620(:)/cHbR0);
cmro2=ldf(:).*(1+gR*cHbR(:)/cHbR0)./(1+gT*cHbT(:)/cHbT0);

y.parms=parms;
y.cbf=ldf;
y.ois620=ois620;
y.ois570=ois570;
y.cHbR0=cHbR0;
y.cHbO0=cHbO0;
y.cHbT0=cHbT0;
y.cHbR=cHbR;
y.cHbO=cHbO;
y.cHbT=cHbT;
y.cmro2_620=cmro2_620;
y.cmro2=cmro2;

if nargout==0,
  clf,
  subplot(311), plot([ldf(:) ois620(:) ois570(:)]),
  axis('tight'), grid('on'), legend('LDF','620','570'),
  subplot(312), plot([cHbO(:)/cHbO0 cHbR(:)/cHbR0 cHbT(:)/cHbT0]),
  axis('tight'), grid('on'), legend('HbO','HbR','HbT'),
  subplot(313), plot([cmro2(:) cmro2_620(:)]),
  axis('tight'), grid('on'), legend('CMRO2','CMRO2 620'),
  clear y
end;

