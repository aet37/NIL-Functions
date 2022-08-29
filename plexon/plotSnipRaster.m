function r=plotSnipRaster(y)
% Usage ... r=plotSnipRaster(ys)

ntrials=length(y);

for mm=1:ntrials,
  r{mm}=y(mm).ts;
  plot(y(mm).ts,mm*ones(size(y(mm).ts)),'k.')
  if mm==1,
    hold('on'),
  end;
end;
hold('off'),

if nargout==0,
  clear r
end;
