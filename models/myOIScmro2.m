function y=tmp_myOIScmro2(ldf,ois620,ois570,parms)
% Usage ... y=tmp_myOIScmro2(ldf,ois620,ois570,parms)
%
% Simple calculation of CMRO2 from OIS spectral time data
% If cells are given as data, the first entry is the time vector
% parms = [cHbT0 S0 gR gT grubb]

if nargin<4, 
    %parms=[100e-6 0.6 1 1 0.38]; 
    %parms=[70e-6 0.6 1 1 0.25]; 
    parms=[100e-6 0.6 1 1 0.25]; 
end;

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

%load NIRS_extData.mat
%estPath=interp1(lambda,(1./(mean([0.8*eHb 1.2*eHbO2],2)/1e4)).^0.75,[500:700]);
%clear eHb eHbO2 lambda
%D_570=interp1(lambda,estPath,570);
%D_620=interp1(lambda,estPath,620);

%D_570=0.5;
%D_620=2.5;
eHbO_570=mean(getNIRSec(572+[-7:7],'hbo'));
eHbR_570=mean(getNIRSec(572+[-7:7],'hbr'));
eHbO_620=mean(getNIRSec(620+[-7:7],'hbo'));
eHbR_620=mean(getNIRSec(620+[-7:7],'hbr'));
[~,D_570]=getNIRSec(572,'hbo');
[~,D_620]=getNIRSec(620,'hbo');

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

if isempty(ldf),
  if ~exist('grubb','var'), 
      % primates 0.38, rodents 0.2-0.25 but region dependent???
      grubb=0.25; 
  end;
  %tt_ldf=tt_ois570;
  ldf=(1+cHbT/cHbT0).^(1/grubb);
  ldf_est=ldf;
end;

cmro2_620=ldf(:).*(1+cHbR_620(:)/cHbR0);
cmro2=ldf(:).*(1+gR*cHbR(:)/cHbR0)./(1+gT*cHbT(:)/cHbT0);

y.parms=parms;
y.cbf=ldf;
if exist('ldf_est','var'), y.cbf_est=ldf_est; end;
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
  axis('tight'), grid('on'), legend('LDF','620','570'), ylabel('Data'),
  subplot(323), plot([cHbO(:)/cHbO0 cHbR(:)/cHbR0 cHbT(:)/cHbT0]),
  axis('tight'), grid('on'), legend('HbO','HbR','HbT'), ylabel('Decomp'),
  subplot(324), plot([cHbO(:) cHbR(:) cHbT(:)]*1e6),
  axis('tight'), grid('on'), legend('HbO','HbR','HbT'), ylabel('Decomp (\muM)'),
  subplot(313), plot([cmro2(:) cmro2_620(:)]),
  axis('tight'), grid('on'), legend('CMRO2','CMRO2 620'), ylabel('rCMRO2'),
  clear y
end;

