function y=calcRaster1(data,thr,cthr,snipwin)
% Usage ... y=calcRaster1(data,thr,cthr,snipwin)
%
% Ex.
% raster1=calcRaster1(strm2,'3',[],[-round(0.001*samprate):+round(0.002*samprate)]);
% lrast1=calcRaster1(data2,{'2.5',data2f},[2],[-20:60]);

if ~exist('cthr','var'),
  cthr=1;
end
do_cthr=length(cthr);

do_win=0;
if exist('snipwin','var'),
  do_win=1;
end

datasz=size(data);

data_avg=mean(data,1);
data_std=std(data,[],1);

dthr=1;
if do_win, dthr=floor(length(snipwin)/2); end;

do_data2=0;
if iscell(thr),
  thr_orig=thr;
  thr=thr_orig{1};
  data2=data;
  data=thr_orig{2};
  
  do_data2=1;
  data_avg=mean(data,1);
  data_std=std(data,[],1);
  thr=str2num(thr)*data_std + data_avg;
elseif ischar(thr),
  thr_orig=thr;
  thr=str2num(thr)*data_std + data_avg;  
end;


raster1all=zeros(datasz);
raster1lab=zeros(datasz);
raster1=zeros(datasz);
for mm=1:datasz(2),
  if thr(mm)>0,
    raster1all(:,mm)=(data(:,mm)>thr(mm));
  else,
    raster1all(:,mm)=(data(:,mm)<thr(mm));
  end;
  tmpii=find(raster1all(:,mm));
  tmpii=[tmpii(1);tmpii(find(diff(tmpii)>1))];
  tmpid=diff(tmpii);
  raster1lab(:,mm)=bwlabel(raster1all(:,mm));
  raster1max(mm)=max(raster1lab(:,mm));
  if raster1max(mm)<1, disp(sprintf('  warning: no hits in data-col %d',mm)); end; 
  tmpcnt=0; tmpupdate=0;
  for nn=1:raster1max(mm),
    raster1n{mm}(nn)=sum(raster1lab(:,mm)==nn);
    tmpi=find(raster1lab(:,mm)==nn,1);
    if do_cthr,
      if do_cthr==1,
        if raster1n{mm}(nn)>=cthr(1), raster1(tmpi,mm)=1; tmpupdate=1; end;
      elseif do_cthr==2,
        if (raster1n{mm}(nn)>=cthr(1))&(raster1n{mm}(nn)<cthr(2)), raster1(tmpi,mm)=1; tmpupdate=1; end
      end;
    else
      raster1(tmpi,mm)=1;
      tmpupdate=1;
    end
    if (nn>1)&(tmpupdate),
      if (tmpid(nn-1)<dthr),
        tmpupdate=0;
        raster1(tmpi,mm)=0;
      end; 
    end;
    if do_win&tmpupdate,
      tmpcnt=tmpcnt+1;
      if ((tmpi+snipwin(1))>0)&((tmpi+snipwin(end))<=datasz(1)),
        if do_data2, snip1{mm}(:,tmpcnt)=data2(tmpi+snipwin,mm); else, snip1{mm}(:,tmpcnt)=data(tmpi+snipwin,mm); end;
      else
        snip1{mm}(:,tmpcnt)=zeros(length(snipwin),1);
      end
      tmpupdate=0;
    end
  end
  if nargout==0,
    clf,
    subplot(211), plot([1:datasz(1)],data(:,mm),[1 datasz(1)],[1 1]*thr(mm),'r'), axis tight, grid on,
    title(sprintf('Raster %d of %d, thr=%.2f',mm,datasz(2),thr(mm))),
    subplot(212), plot([1:datasz(1)],raster1(:,mm)), axis tight, grid on,
    drawnow,
    pause
  end
end

if do_win,
  % align maxima? 
end

y.thr=thr;
y.cthr=cthr;
y.raster1all=raster1all;
%y.raster1lab=raster1lab;
%y.raster1n=raster1n;
y.raster1=raster1;

if do_win,
  y.snip_win=snipwin;
  y.snip1=snip1;
end
