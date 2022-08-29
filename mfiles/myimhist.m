function [hh,ax]=myimhist(im,nbins)
% Usage ... [hist,ax]=myimhist(im,nbins)

nn=prod(size(im));

stat_flag=1;
if (stat_flag),
  imavg=mean(reshape(im,nn,1));
  imstd=std(reshape(im,nn,1));
  disp(sprintf('  mean= %f',imavg));
  disp(sprintf('  stdev= %f',imstd));
end;

if nargin==1,
  if nargout==0,
    hist(reshape(im,nn,1));
  else,
    [hh,ax]=hist(reshape(im,nn,1));
  end;
else,
  if nargout==0,
    hist(reshape(im,nn,1),nbins);
  else,
    [hh,ax]=hist(reshape(im,nn,1),nbins);
  end;
end;
  
