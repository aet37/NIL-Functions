function [atc,ntc]=avgmissing1(data,thr,tt,tstim,tavg,nthr)
% Usage ... [y,nty]=avgmissing1(data,thr,tt,tstim,tavg,nthr)
%
% Ex: avgmissing1(data,3500,tt,tstim,[-10:200]*.02,[0 1 2]);

warning('off');

if nargin<6, nthr=0; end;

tmpi=find(data>thr);
nthr,
data(tmpi+nthr)=NaN;


for mm=1:length(tstim),
  tmptc(:,mm)=interp1(tt(:),data(:),tavg(:)+tstim(mm));
end;

for mm=1:size(tmptc,1),
  tmpi=find(~isnan(tmptc(mm,:)));
  ntc(mm)=length(tmpi);
  if (ntc(mm)==0),
    atc(mm)=sum(tmptc(mm,:));
  else,
    atc(mm)=sum(tmptc(mm,tmpi))/ntc(mm);
  end;
end;

if nargout==0,
  subplot(311)
  plot(tt,data,[tt(1) tt(end)],[1 1]*thr)
  subplot(312)
  plot(tavg,atc)
  subplot(313)
  plot(tavg,ntc)
end;

warning('on');

