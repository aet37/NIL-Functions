function plot_raster(t,y,thr,dthr)
% Usage ... plot_raster(t,y,thr,dthr)
%
% Generates a stacked line plot of the columns of y
% vs time t. If no time vector is supplied, indeces are used
% if thr is supplied, raw data is expected in y and
% will be subjected to thr and diff-thr (default=2)


if nargin==1,
  y=t;
  t=[1:size(y,1)];
end;

do_thr=0;
if (max(abs(y(:)))>10*eps)&(max(abs(y(:)))<1), do_thr=1; end;
if (max(abs(y(:)))>1.1), do_thr=1; end;

if ~exist('thr','var'), thr=mean(y,1)-3*std(y,[],1); end;
if ~exist('dthr','var'), dthr=2; end;
if ischar(thr), do_thr=2; thrf=str2num(thr); end;

if do_thr,
  for mm=1:size(y,2),
    tmpy=y(:,mm);
    if do_thr==2, thr=mean(tmpy(:))+thrf*std(tmpy(:)); disp(sprintf('  thr=%.2e',thr)); end;
    if thr<0,
      tmpi1=find(tmpy<thr);
    else,
      tmpi1=find(tmpy>thr);
    end;
    tmpi2=find(diff(tmpi1)>dthr);
    tmpi3=tmpi1(1);
    tmpi3(2:length(tmpi2)+1)=tmpi1(tmpi2+1);
    tmpy=zeros(size(tmpy));
    tmpy(tmpi3)=1;
    ri{mm}=tmpi3;
    ry(:,mm)=tmpy;
  end;
  y=ry;
end;

clf,
for mm=1:size(y,2),
  if mm==1, hold('on'), end;
  plot([t(1) t(end)],mm+[0 0],'k-'),
  plot(t,mm+single(y(:,mm)>0.5)*0.5,'k-'),
end;
hold('off'),

ylabel('Raster'),

if nargin==1,
  xlabel('Index #'),
else,
  xlabel('Time'),
end;

axis('tight'), grid('on'),
drawnow,


