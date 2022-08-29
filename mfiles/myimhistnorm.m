function [xn,ns]=myimhistnorm(x,scale)
% Usage ... y=myimhistnorm(x,scale)

x=round(x);
if nargin==1, scale=[min(min(x)) max(max(x))]; end;

dscale=scale(2)-scale(1)+1;

cnt=0;
for mm=scale(1):scale(2),
  cnt=cnt+1;
  hh(cnt)=length(find(x==mm));
end;
cdf=cumsum(hh);

cdfmin=min(cdf(find(cdf>0)));
tmpmin=find(cdf==cdfmin);
cdfminv=tmpmin(1);
cdfmax=max(cdf);
tmpmax=find(cdf==max(cdf));
cdfmaxv=tmpmax(1);

hhn=round(((cdf-cdfmin)/(prod(size(x))-cdfmin))*(dscale-1));

if min(min(x))~=min(hhn), x=x-min(min(x)); end;
if min(min(x))==0, x=x+1; end;
if min(hhn)==0, hhn=hhn+1; end;
%disp(sprintf('  x (min/max)= %d/%d   hn (min/max)= %d/%d',min(min(x)),max(max(x)),min(hhn),max(hhn)));
%for mm=1:size(x,1), for nn=1:size(x,2), xn(mm,nn)=hhn(x(mm,nn)); end; end;

xn=hhn(x);

cnt=0;
for mm=min(min(xn)):max(max(xn)),
  cnt=cnt+1;
  hhnew(cnt)=length(find(xn==mm));
end;
cdfnew=cumsum(hhnew);

ns.x=x;
ns.xh=hh;
ns.xcdf=cdf;
ns.scale=scale;
ns.xn=xn;
ns.xnh=hhnew;
ns.xncdf=cdfnew;

if nargout==0,
  subplot(221)
  show(x)
  subplot(223)
  plot([scale(1):scale(2)],hh,'k',[scale(1):scale(2)],cdf*max(hh)/max(cdf),'b')
  subplot(222)
  show(xn)
  subplot(224)
  plot([scale(1):scale(2)],hhnew,'k',[scale(1):scale(2)],cdfnew*max(hhnew)/max(cdfnew),'b')
  clear xn ns
end;

