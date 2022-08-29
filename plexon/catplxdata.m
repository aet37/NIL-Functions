function [cdata,crts,cii]=catplxdata(plx,nend,stop_flag)
% Usage ... [catdata,catrts,catii]=catplxdata(plx,nend,stop_flag)

stop_thr=0.99;

if nargin==1, nend=round(plx.adfreq*0.5); end;

if ~exist('stop_flag'), stop_flag=[]; end;
if isempty(stop_flag), stop_flag=0; end;

nev=length(plx.tt1);
tmpstot=0;
for mm=1:nev,
  clear tmpdata tmprts tmpeq 
  % load data
  eval(sprintf('tmprts=plx.rts%02d;',mm));
  eval(sprintf('tmpdata=plx.data%02d;',mm));
  tmpstot=tmpstot+length(tmpdata);

  % main loop
  if mm==1,
    tmpi9=length(tmpdata)-nend;
    crts=tmprts(1:tmpi9);
    cdata=tmpdata(1:tmpi9);
    cii(mm,:)=[tmpi9 length(cdata) find(crts<0,1,'last')+1];
    tmp=tmpdata(tmpi9:end);
    tmplen=length(tmp);
    disp(sprintf('  1: %d %d',length(cdata),tmpi9));
  else,
    tmpeq=zeros(length(tmpdata)-tmplen+1,1);
    for nn=1:length(tmpdata)-tmplen+1;
      tmpdiff=tmpdata(nn:nn+tmplen-1)-tmp;
      tmpeq(nn)=sum(abs(tmpdiff)<10*eps)/tmplen;
      if (stop_flag)&(tmpeq(nn)>stop_thr), break; end;
    end;
    tmpii=find(tmpeq>stop_thr);
    tmprts9=crts(end);
    cdata=[cdata tmpdata(tmpii(1)+1:end-nend)];
    crts=[crts tmprts(tmpii(1)+1:end-nend)-tmprts(tmpii(1))+crts(end)];
    cii(mm,:)=[tmpii(1) length(cdata) find(crts+tmprts(tmpii(1))-tmprts9<0,1,'last')+1];
    clear tmp tmplen

    tmpi9=length(tmpdata)-nend;
    tmp=tmpdata(tmpi9:end);
    tmplen=length(tmp);
    disp(sprintf('  %d: %d %d %d %.3f (%.3f)',mm,length(cdata),tmpii(1),tmpi9,...
                       max(tmpeq),stop_thr));
    %[tmpdata(tmpii(1)+[-5:5])' cdata(cii(mm-1,2)+[-5:5])'],
    %clf, subplot(211), plot([tmpdata(tmpii(1)+[-5000:5000])' cdata(cii(mm-1,2)+[-5000:5000])']),
    %     subplot(212), plot(tmpdata(tmpii(1)+[-5000:5000])-cdata(cii(mm-1,2)+[-5000:5000])),
    %drawnow,
    %keyboard,
  end;
end;

disp(sprintf(' idiff= %d',tmpstot-length(cdata)));

if nargout==1,
  tmp.cdata=cdata;
  tmp.crts=crts;
  tmp.cii=cii;
  clear cdata
  cdata=tmp;
end;

clear tmp*

%if trig_flag,
%  for mm=1:nev;
%    clear tmp*
%    eval(sprintf('tmprts=plx.rts%02d;',mm));
%    eval(sprintf('tmpdata=plx.data%02d;',mm));
%    tmpi0=find(tmprts>=0,1);
%    tmp=tmpdata(tmpi0:tmpi0+nend);
%    tmplen=length(tmp);
%    for nn=1:length(tmpdata)-tmplen+1;
%      tmpdiff=tmpdata(nn:nn+tmplen-1)-tmp;
%      tmpeq(nn)=sum(abs(tmpdiff)<10*eps)/tmplen;
%      if (tmpeq(nn)>stop_thr), break; end;
%    end;
%    tmpii=find(tmpeq>stop_thr);
%    trii(mm)=tmpii(1);
%  end;
%  if nargout<4, trii, end;
%end;

