function [freq,ax]=myimhist(image,nbins)
%
% Usage ... [freq,ax]=myimhist(image,nbins)
%
%

maxval=max(max(image));
minval=min(min(image));

if (nargin==1),
  nbins=round(log2(prod(size(image)))^2/2);
end;

ax=([1:nbins]/nbins)*(maxval-minval)+minval;
binw=(maxval-minval)/nbins;
ax=ax-binw;

freq=zeros([1 nbins]);

isize=size(image);

for m=1:isize(1), for n=1:isize(2),
  tmppos=image(m,n);
  tmpii=find((tmppos>=(ax-binw))&(tmppos<=(ax+binw)));
  freq(tmpii)=freq(tmpii)+1;
end; end;

if (nargout==0),
  bar(ax,freq)
  clear freq ax
end;

