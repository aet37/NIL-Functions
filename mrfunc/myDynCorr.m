function y=myDynCorr(x,nw,nskp)
% Usage ... y=myDynCorr(x,nw,nskp)

if nargin<3, nskp=1; end;

ii=[1:nskp:length(x)-nw];
for mm=1:length(ii),
  tmpi=[1:nw]+ii(mm)-1;
  [rr(:,:,mm),pp(:,:,mm)]=corrcoef(x(tmpi,:));
end;
xi=ii+nw/2;

y.xi=xi;
y.r=rr;
y.p=pp;


