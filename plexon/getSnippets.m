function [ys,ts,tts,noii]=getSnippets(data,tt,thr,bsize,nobins,rmsaturated)
% Usage ... [ys,ts,tts,noii]=getSnippets(data,time,thr,sniptime,nolooktime,rmsaturated)
%
% data and time need to be arranged in ROW vectors
% assume data and threshold are all for negative deflections
% sniptime is [start_time end_time] for each snippet relative to

do_interp=0;
do_rmsaturated=0;

if nargin==6, do_rmsaturated=rmsaturated(1); end;

dthr=2;         % thr sample different threshold
satval=1710; 	% plexon saturation value for spike channel
satnthr=2;	    % discard depending on #sat samples in snippet

if ~exist('bsize'), sniptime=[]; else, sniptime=bsize; end;
if isempty(sniptime), sniptime=[-0.4 1.4]*1e-3; end;

if ~exist('nobins'), nobins=[]; end;

nbi=floor((sniptime(2)-sniptime(1))/(tt(2)-tt(1)));
bi0=abs(round(sniptime(1)/(tt(2)-tt(1))));
bii=[0:nbi-1]-bi0;
tti=[sniptime(1):tt(2)-tt(1):sniptime(2)]; 
tts=tt([1:nbi])-tt(bi0);

if ischar(thr), 
  tmpthr=mean(data(:))+std(data(:))*str2num(thr); thr=tmpthr;
  disp(sprintf('  thr= %.2e',tmpthr));
end;

% find no_look bins indeces
if ~isempty('nobins'),
  do_nobins=1;
  yno=zeros(1,length(tt));
  for mm=1:floor(length(nobins)/2),
    tmpynoii=find((tt>=nobins(2*mm-1))&(tt<=nobins(2*mm)));
    if ~isempty(tmpynoii), yno(tmpynoii)=1; end;
  end;
  noii=find(yno);
else,
  do_nobins=0;
end;

nno=0;
%disp(sprintf('  nobins= %d  many= %d',do_nobins,many_flag));

data=data(:).';
tt=tt(:).';
if thr<0, y1=(data<=thr); else, y1=(data>=thr); end;
y1i=find(y1);
if isempty(y1i),
  disp('  No hits, try a different threshold, returning zeros...');
  ys=[];
  ts=[];
  yt=tts;
  return;
end;

% delete no_look areas
if do_nobins,
  y1(noii)=0;
  y1i=find(y1);
end;

% look for thresholds over 1 sample long
y2i=diff(y1i);
y2di=find(y2i>dthr);
if isempty(y2di),
  ydi=[y1i(1)];
else,
  ydi=[y1i(1) y1i(y2di+1)];
end;
ydi=ydi(find((ydi>bi0)&(ydi<length(tt)-length(tts))));
if isempty(ydi),
  disp('  No hits, try a different threshold, returning zeros...');
  ys=[];
  ts=[];
  yt=tts;
  return;
end;

% get snippets
ts=tt(ydi);
ys=zeros(length(tts),length(ydi));
if do_interp, yi=zeros(length(tti),length(ydi)); end;
for mm=1:length(ydi),
  ys(:,mm)=data(ydi(mm)+bii).';
  if do_interp,
    yi(:,mm)=interp1(tt(ydi(mm)+bii),data(ydi(mm)+bii),tti).'; 
  end;
end;

% discard bad snippets
if do_rmsaturated,
  disp(sprintf('  looking for and removing saturated snippets (%f) ...',satval));
  tmpok=[]; tmpnok=[];
  for mm=1:size(ys,2),
    tmpsii=find((ys(:,mm)>satval)|(ys(:,mm)<-1*satval));
    if length(tmpsii)>satnthr, tmpnok=[tmpnok mm]; else, tmpok=[tmpok mm]; end;
  end;
  disp(sprintf('  keeping %d of %d ...',length(tmpok),size(ys,2)));
  if ~isempty(tmpnok),
    yd=ys(:,tmpnok);
    td=ts(tmpnok);
  else,
    yd=[];
    td=[];
  end;
  ys=ys(:,tmpok);
  ts=ts(tmpok);
end;


if nargout==0,
  figure(1), clf,
  plot(tts*1000,ys,'g',tts*1000,mean(ys,2),'k')
  figure(2), clf,
  plot(tt,data,ts,data(ydi),'ko'),
  figure(3), clf,
  plot(ts,ones(size(ts)),'k.')
  ts,
end;

if nargout==1,
  tmpys=ys; clear ys
  ys.ys=tmpys;
  ys.ts=ts;
  ys.ti=ydi;
  ys.tt=tts;
  ys.thr=thr;
  ys.noii=noii;
  if do_rmsaturated,
    ys.yd=yd;
    ys.td=td;
  end;
end;

