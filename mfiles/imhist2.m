function [freq,ax]=imhist2(image)
%
% Usage ... [freq,ax]=imhist2(image)
%
%

maxval=max(max(image));
minval=min(min(image));
ax=[minval:1:maxval];
freq=zeros([1 length(ax)]);

isize=size(image);

for m=1:isize(1), for n=1:isize(2),
  tmppos=image(m,n);
  freq(1,tmppos-minval+1)=freq(1,tmppos-minval+1)+1;
end; end;

if (nargout==0),
  bar(ax,freq)
end;
