function y=myOISdecomp(yOIS,wlen,wlen_wid,parms)
% Usage ... y=myOISdecomp(yOIS,wlen,wlen_wid,parms)
%
% Simple linear decomposition of HbR and HbO2 in that order for
% OIS data using the modified Beer Lambert Law (yout.yHb=[HbR_calc HbO_calc])
% Assumes the data are baseline normalized to 1
% yHb_norm outputs [HbR HbO HbT]
% parms = [cHbT0 S0 gR gT]
%
% Ex. yd=myOISdecomp(tcA.atc_an(:,2:3),[572 620]);

%if nargin<5, src=3; end;
if nargin<3, wlen_wid=[]; end;
if nargin<4, 
    %parms=[70e-6 0.6 1 1]; 
    parms=[100e-6 0.6 1 1];
end;

for mm=1:length(wlen),
  if isempty(wlen_wid),
    [ecs,plen(mm)]=getNIRSext2(wlen(mm));
    eHbO2(mm)=ecs(1); eHbR(mm)=ecs(2);
    %[eHbR(mm),plen(mm)]=getNIRSec(wlen(mm),'hbr',src);
    %[eHbO2(mm)]=getNIRSec(wlen(mm),'hbo',src);
  else,
    wlen_all=wlen(mm)+[-round(wlen_wid(mm)/2):round(wlen_wid(mm)/2)];
    [ecs,plen_all{mm}]=getNIRSext2(wlen_all);
    eHbO2_all{mm}=ecs(:,1); eHbR_all{mm}=ecs(:,2);
    %[eHbR_all{mm},plen_all{mm}]=getNIRSec(wlen_all,'hbr',src);
    %[eHbO2_all{mm}]=getNIRSec(wlen_all,'hbo',src);
    eHbR(mm)=mean(eHbR_all{mm});
    eHbO2(mm)=mean(eHbO2_all{mm});
    plen(mm)=mean(plen_all{mm});
  end;
end;

% cHb=150g/L, Hb=64500g/mol, cHb=2.303mM, 3% CBV = 69.1e-6M
cHbT0=parms(1);
S0=parms(2); 
cHbR0=(1-S0)*cHbT0; 
cHbO0=S0*cHbT0;

% these are not necessary for decomposition
gR=parms(3); 
gT=parms(4);

%load NIRS_extData.mat
%estPath=interp1(lambda,(1./(mean([0.8*eHb 1.2*eHbO2],2)/1e4)).^0.75,[500:700]);
%clear eHb eHbO2 lambda
%plen2=interp1(lambda,estPath,wlen);


eInv=inv([eHbR' eHbO2']');     

if iscell(yOIS),
  for nn=1:length(yOIS), for oo=1:size(yOIS{1},2),
    yOIS_all(:,nn,oo)=yOIS{nn}(:,oo);
  end; end;
  for nn=1:size(yOIS_all,3),
    tmp_yOIS=yOIS_all(:,:,nn);
    for mm=1:size(tmp_yOIS,2),
      cHbR(:,mm,nn)=-log(tmp_yOIS(:,mm))./(plen(mm)*eHbR(mm));
    end;

    y_decomp(:,:,nn)=-[log(tmp_yOIS)./(ones(size(tmp_yOIS,1),1)*plen)]*eInv;
    cHbT(:,nn)=sum(y_decomp(:,:,nn),2);
    yHb_norm(:,:,nn)=[y_decomp(:,1,nn)/cHbR0 y_decomp(:,2,nn)/cHbO0 cHbT(:,nn)/cHbT0];
  end;
else,
  for mm=1:size(yOIS,2),
    cHbR(:,mm)=-log(yOIS(:,mm))./(plen(mm)*eHbR(mm));
  end;

  y_decomp=-[log(yOIS)./(ones(size(yOIS,1),1)*plen)]*eInv;
  cHbT=sum(y_decomp,2);
  yHb_norm=[y_decomp(:,1)/cHbR0 y_decomp(:,2)/cHbO0 cHbT(:)/cHbT0];
end;

y.parms=parms;
y.wlen=wlen;
y.wwid=wlen_wid;
y.ecHbO=eHbO2;
y.ecHbR=eHbR;
y.yOIS=yOIS;
y.cHbR0=cHbR0;
y.cHbO0=cHbO0;
y.cHbT0=cHbT0;
y.yHb=y_decomp;
y.yHbT=cHbT;
y.yHbR_only=cHbR;
y.yHb_norm=yHb_norm;

if nargout==0,
  clf,
  subplot(311), plot([yOIS]),
  axis('tight'), grid('on'), legend(num2str(wlen)),
  ylabel('yOIS Data'),
  subplot(312), plot([y_decomp cHbT]*1e6),
  axis('tight'), grid('on'), legend('HbR','HbO2','HbT'),
  ylabel('Est. [Hb] (uM)'),
  subplot(313), plot([y.yHb_norm]),
  axis('tight'), grid('on'), legend('HbR','HbO2','HbT'),
  ylabel('Norm. \DeltaHb'),
  clear y
end;

