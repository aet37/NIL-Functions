function [f,binx]=hist2(x,y,bins,operator1)
% Usage ... f=hist2(x,y,bins,operator1)

if nargin<4, operator1='+'; end;
if nargin<3, bins=10; end;

xmin=min(x);
xmax=max(x);
xrange=xmax-xmin;
binsize=xrange/bins;

binx(1)=xmin;
for m=1:bins,
  binx(m+1)=binx(m)+binsize;
end;
binx(bins)=xmax+0.5*binsize;

for m=1:bins,
  tmp=find( (x>=binx(m))&(x<binx(m+1)) );
  tmp2=0;
  if ~isempty(tmp),
    if length(tmp)==1,
      tmp2=y(tmp);
    else,
      for n=1:length(tmp),
	eval(['tmp2=tmp2',operator1,'y(tmp(n));']);
      end;
    end;
  end;
  f(m)=tmp2;
end;
binx=binx(1:length(binx)-1);

if nargout==0,
  bar(binx,f)
  clear f binx
end;

