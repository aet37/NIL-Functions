function [ynA,ynE]=myOISrecomp(ysHb,wlen,wlen_wid,parms)
% Usage ... y=myOISrecomp(ysHb,wlen,wlen_wid,parms)
%
% Simple linear recomposition from HbR and HbO2 to OIS data at a certain
% wavelength(s) using the modified Beer Lambert Law.
% parms = [] (none defined yet)
%
% Ex. yd=myOISrecomp(yHb_out,520);

if nargin<3, wlen_wid=[]; end;
if nargin<4, parms=[100e-6 0.6 1 1]; end;

for mm=1:length(wlen),
  if isempty(wlen_wid),
    [eHbR(mm),plen(mm)]=getNIRSec(wlen(mm),'hbr');
    [eHbO2(mm)]=getNIRSec(wlen(mm),'hbo');
  else,
    if iscell(wlen_wid),
      wlen_all=wlen(mm)+wlen_wid{mm};
      [eHbR_all{mm},plen_all{mm}]=getNIRSec(wlen_all,'hbr');
      [eHbO2_all{mm}]=getNIRSec(wlen_all,'hbo');
    else,
      wlen_all=wlen(mm)+[-wlen_wid(mm)/2:wlen_wid(mm)/2];
      [eHbR_all{mm},plen_all{mm}]=getNIRSec(wlen_all,'hbr');
      [eHbO2_all{mm}]=getNIRSec(wlen_all,'hbo');
    end;
    eHbR(mm)=mean(eHbR_all{mm});
    eHbO2(mm)=mean(eHbO2_all{mm});
    plen(mm)=mean(plen_all{mm});
  end;
end;

cHbT0=parms(1);
S0=parms(2); 
cHbR0=(1-S0)*cHbT0; 
cHbO0=S0*cHbT0;

gR=parms(3); 
gT=parms(4);

if ~isstruct(ysHb),
  tmpy.yHb=ysHb; %[yHbR yHbO2]
  clear ysHb
  ysHb=tmpy;
end;

for mm=1:length(wlen),
  ynA(:,mm)=exp(-(eHbR(mm)*ysHb.yHb(:,1)+eHbO2(mm)*ysHb.yHb(:,2))*plen(mm));
  ynE(:,mm)=1-(eHbR(mm)*ysHb.yHb_norm(:,1)+eHbO2(mm)*ysHb.yHb_norm(:,2))/(eHbR(mm)+eHbO2(mm));
end;

if nargout==0,
  clf,
  subplot(211), plot([ynA]),
  axis('tight'), grid('on'), legend(num2str(wlen)),
  ylabel('yOIS Recomposed'),
  subplot(212), plot([ysHb.yHb_norm]),
  axis('tight'), grid('on'), legend('HbR','HbO2','HbT'),
  ylabel('Provided Hb Estimates'),
  clear ynA
end;

