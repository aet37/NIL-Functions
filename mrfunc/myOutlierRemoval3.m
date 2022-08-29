function [xnew,tnew,iout]=myOutlierRemoval3(x,t,tper,wthr)
% Usage ... [y,t_new,out]=myOutlierRemoval3(x,t,tper,thr_om)
%
% This version of the outlier removal simply downsamples the data
% after taking outliers in a window of width tper outside thr_over_mean
% from the mean and taking the mean inside for each new sampling period
% if whtr is a logical vector, TRUE entries indicate outliers
% Right now this function can only handle a single vector at a time

dt=t(2)-t(1);
nper=floor(tper/dt);
pii=floor([0:nper-1]-nper/2);
tnew=[t(1)+tper/2:tper:t(end)-tper/2];
nbins=length(tnew);
nt=length(t);

x_orig=x;

do_type=1;
if ischar(wthr),
  if strcmp(wthr(1),'t'),
    do_type=1;
    wthr=str2num(wthr(2:end));
  elseif strcmp(wthr(1),'s'),
    do_type=2;
    wthr=str2num(wthr(2:end));
  elseif strcmp(wthr(1),'d'),
    do_type=3;
    xd=diff(x);
    xd=[0;xd(:)];
    wthr=str2num(wthr(2:end));
  else,
    do_type=1;
    wthr=str2num(wthr);
  end;
end;

if length(x)==length(wthr),
  do_type=4;
end;

i0=find((t>=-dt/4)&(t<=dt/4));
iout=[];

xnew=zeros(nbins,1);
xn=zeros(nbins,1);
for mm=1:nbins,
  tmpi=find(t>=tnew(mm)); tmpi=tmpi(1);
  tmppi=tmpi+pii;
  tmppi=tmppi(find((tmppi>=1)&(tmppi<=nt)));

  tmpx=x(tmppi);
  
  if do_type==4,
    tmpin=find(wthr(tmppi)<0.1);
    tmpout=find(wthr(tmppi)>=0.1);
  elseif do_type==3,
    tmpin=find(abs(xd(tmppi))<wthr);
    tmpout=find(abs(xd(tmppi))>=wthr);
  elseif do_type==2,
    tmpthr=mean(tmpx)+[-1 1]*wthr;
    tmpin=find((tmpx>tmpthr(1))&(tmpx<tmpthr(2)));
    tmpout=find((tmpx<=tmpthr(1))&(tmpx>=tmpthr(2)));
  end;
  
  if isempty(tmpin),
    xnew(mm)=NaN;
    xn(mm)=0;
  else,
    xnew(mm)=mean(tmpx(tmpin));
    xn(mm)=length(tmpin);
  end;
  if ~isempty(tmpout),
    iout=[iout;tmpout(:)+tmpi-1];
  end;
end;

%clf, plot(xnew), axis tight, grid on, drawnow, pause,

tmpnan=find(isnan(xnew));
if ~isempty(tmpnan),
  for mm=1:length(tmpnan);
    if tmpnan(mm)==1,
      xnew(tmpnan(mm))=xnew(2);
    elseif tmpnan(mm)==length(xnew),
      xnew(end)=xnew(end-1);
    else,
      xnew(tmpnan(mm))=mean(xnew([-1 1]+tmpnan(mm)));
    end;
  end;
end;
 

if nargout==0,
  clf,
  plot(t,x,tnew,xnew)
  if ~isempty(iout),
    hold('on'), plot(t(iout),x(iout),'ro'), hold('off'),
  end; 
end;

