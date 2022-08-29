function [y,tnew,ny,ii]=myOutlierRemoval2(x,t,tper,ii,nord)
% Usage ... [y,t_new,ny]=myOutlierRemoval2(x,t,tper,ii_or_thr,nord)
%
% This version of the outlier removal simply downsamples the data
% after taking outliers instead of replacing outlier points
%
% Ex. ii_rem=find((y(ii)<thr)&(y(ii)>thr));
% Ex. [ynew,tnew]=myOutlierRemoval(y,t,0.2,ii(ii_remove))
% Ex. [ynew,tnew]=myOutlierRemoval2({tmpy1,tmpy2},tt,0.25,1.05);
% Ex. [ynew,tnew]=myOutlierRemoval2({tmpy1,tmpy2},tt,0.25,1.05,[2 2]);


% check x
if iscell(x),
  x1=x{1};
  x2=x{2};
  clear x
  x=x1;
  if length(ii)==1,
    thr=ii;
    if thr<0,
      ii=find(x2<thr);
    else,
      ii=find(x2>thr);
    end;
  end;
  if nargout==0,
    clf, 
    subplot(211), plot(t,x,t(ii),x(ii),'o'), axis('tight'), grid('on'),
    subplot(212), plot(t,x2,t(ii),x2(ii),'o'), axis('tight'), grid('on'),
    disp('  press enter to continue...'); pause;
  end;
end;

% find outliers if thr is given instead of outlier entries
if length(ii)==1,
  thr=ii;
  disp(sprintf('  looking for outliers in x with thr of %f',thr));
  if thr<0, 
    ii=find(x<thr);
  else,
    ii=find(x>thr);
  end;
end;

% setup spacing
dt=t(2)-t(1);
nbins=floor((t(end)-t(1))/tper);
i1=floor(t(1)/tper);

% align data to t=0 ???
i0=find((t>=-dt/4)&(t<=dt/4),1);

% resample data
for mm=1:nbins,
  tmpi1=i1+mm-1;
  tmpi=find(floor(t/tper)==tmpi1); 
  cnt=0;
  for nn=1:length(tmpi),
    if isempty(find(ii==tmpi(nn))),
      cnt=cnt+1;
      tmpi2(cnt)=tmpi(nn);
    end;
  end;
  if cnt,
    y(mm)=mean(x(tmpi2));
    ny(mm)=length(tmpi2);
    tnew(mm)=t(tmpi2(1));
  else,
    disp(sprintf('  warning: empty bin found, replicating bin (%d)...',mm));
    y(mm)=y(mm-1);
    ny(mm)=0;
    tnew(mm)=tnew(mm-1)+dt;
  end;
  clear tmpi2
end;

if exist('nord','var'),
  disp('  fixing baseline');
  if length(nord)==1, nord(2)=1; end;
  tmpi1=find(tnew<t(ii(1)));
  tmpi2=find(tnew>t(ii(end)));
  tmpii2=[tmpi1(end-nord(2)+1:end) tmpi2(1:nord(2))];
  tmpp=polyfit(tnew(tmpii2),y(tmpii2),nord(1));
  tmpii3=[tmpii2(1):tmpii2(end)];
  tmpy=polyval(tmpp,tnew(tmpii3));
  ynew=y;
  %ynew(tmpii3)=y(tmpii3)-mean(y(tmpii3))+tmpy;
  ynew(tmpii3)=y(tmpii3)-y(tmpii3(1))+tmpy;
  if nargout==0,
    clf,
    subplot(211), plot(tnew,y,tnew(tmpii2),y(tmpii2),'o',tnew(tmpii3),tmpy), axis('tight'), grid('on'),
    subplot(212), plot(tnew,y,tnew,ynew), axis('tight'), grid('on'),
    disp('  press enter to continue...'), pause,
  end;
  y_orig=y;
  y=ynew;
end;

if nargout==0,
  if exist('nord','var'),
    clf, plot(t,x,'-',tnew(tmpii3),tmpy,'-',tnew,y,'-'),
    axis('tight'), grid('on'),
  else,
    clf, 
    subplot(211), plot(t,x,t(ii),x(ii),'o')
    axis('tight'), grid('on'),
    subplot(212), plot(t,x,tnew,y)
    axis('tight'), grid('on'),
  end;
end;

