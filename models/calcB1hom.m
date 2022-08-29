function [fa,fafit]=calcB1hom(fadata,maxfaguess,optvar)
% Usage ... fa=calcB1hom(fadata,maxfaguess)

if nargin<3,
  optvar=optimset('lsqnonlin');
  optvar.TolFun=1e-10;
  optvar.TolX=1e-10;
  optvar.MaxIter=600;
end;

famax=1000; famin=0;
ratemax=10;   ratemin=-1000;
ampmax=100000;  ampmin=0;

faguess=[maxfaguess 0 400];

x1=lsqnonlin('B1homfit',faguess,[famin ratemin ampmin],[famax ratemax ampmax],optvar,fadata);
[tmp,fafit]=B1homfit(x1,fadata);

if (nargout==0),
  fax=[1:length(fadata)];
  plot(fax,fadata,fax,fafit)
else,
  fa=x1(1);
  rate=x1(2);
  amp=x1(3);
end;

