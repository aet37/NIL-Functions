function [maxc,ilag,ilag_sub]=cclag1(y,yref,irange,type,out_type)
% Usage ... [maxc,ilag,ilab_sub]=cclag1(y,yref,irange,type,out_type)
%
% finds peak corr (y,yref) shifting y
% irange in the index shifting to be used, must be integers
% type is the correlation type (1=max, 2=abs-max, -1=min]


if ~exist('type','var'), type=[]; end;
if isempty(type), type=1; end;

if ~exist('out_type','var'), out_type=0; end;
if isempty(out_type), out_type=0; end;
if ischar(out_type), 
  if strcmp(outtype,'all'), 
    out_type=2;
  elseif strcmp(type,'struc')|strcmp(type,'struct'),
    out_type=1;
  end;
end;

if length(irange)==2,
    disp('  expanding irange');
    irange=[irange(1):irange(2)]; 
end;
if mean(diff(irange))<1, disp('  using subsh'); subsh=1; else, subsh=0; end;

for mm=1:size(y,2),
  for nn=1:length(irange),
    if subsh,
      tmpcc(nn)=corr(yref,xshift2(y(:,mm),irange(nn)));
    else,
      tmpcc(nn)=corr(yref,xshift(y(:,mm),irange(nn)));
    end;
  end;
  if type==1,
    [maxc(mm),ilag(mm)]=max(tmpcc);
  elseif type==-1,
    [maxc(mm),ilag(mm)]=min(tmpcc);
  elseif type==2,
    [maxc(mm),ilag(mm)]=max(abs(tmpcc));
  end;
  if ((ilag(mm)>2)&(ilag(mm)<(length(irange)-1))),
    tmpp=polyfit(irange([-2:+2]+ilag(mm)),tmpcc([-2:+2]+ilag(mm)),2);
    ilag_sub(mm)=-tmpp(2)/(2*tmpp(1));
  else,
    ilag_sub(mm)=nan;
  end;
  ilag(mm)=irange(ilag(mm));
  ys.cc(:,mm)=tmpcc(:);
end;
maxc=maxc(:);
ilag=ilag(:);
ilag_sub=ilag_sub(:);

ys.cc_max=maxc;
ys.ilag=ilag;
ys.i_range=irange;
ys.ilag_sub=ilag_sub;


if nargout==0,
  subplot(311), plot(irange,tmpcc), axis tight, grid on,
  title(sprintf('cc-max= %f, lag= %f (%.3f)',maxc(1),ilag(1),ilag_sub(1)));
  subplot(312), plot([yref(:) xshift(y(:,1),[0 ilag(1)])]), axis tight, grid on,
  legend('yref','y1','y1s')
  subplot(313), plot(zscore([yref(:) xshift(y(:,1),[0 ilag(1)])])), axis tight, grid on,
  legend('yref','y1','y1s')
end;

if out_type==2,
  maxc=ys.cc;
elseif out_type==1,
  maxc=ys;
end;
