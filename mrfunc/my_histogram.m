function [f,g]=my_histogram(data,bins)
% Usage ... [f,g]=my_histogram(data,bins)
%
% If bins is not provided unity bins will be
% used. Data must be a vector, not matrix.
% For matrix use imhist command.
% Bins must be at least 2 items long.

if ~exist('bins'),
  tmp=ceil(abs(max(data)));
  bins=[-1*tmp:tmp];
end;

h=zeros(size(bins));
half=0.5*abs(bins(2)-bins(1));
for m=1:length(data),
  for n=1:length(bins),
    if (data(m)>=(bins(n)-half))&(data(m)<=(bins(n)+half)),
      h(n)=h(n)+1;
    end;
  end;
end;

f=h;
g=bins;

if nargout==0,
  plot(g,f)
end;
