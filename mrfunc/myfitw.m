function out=myfitw(y,cycles,avgrange,noskp,fit,outpt)
%
% Usage ... out=myfitw(y,cycles,avgrange,noskp,fit,outpt)
%
%

imperc=length(y)/cycles;

for n=1:cycles,
  tmpy(n,:)=y((n-1)*imperc+1:n*imperc);
end;

tmpmean=mean(tmpy);
tmpstd=std(tmpy);
tmpmed=median(tmpy);
tmpweight=0.34;
size(tmpy)
size(tmpmean)

for n=1:length(tmpmean),
  if (tmpmed(n)>tmpmean(n)), tmpsign=+1; else, tmpsign=-1; end;
  tmpmean(n)=tmpmean(n)+tmpsign*tmpweight*tmpstd(n);
end;

if (fit),
  out=myfit(tmpmean,[1:length(tmpmean)],[1:length(tmpmean)],1,2,0,1,0);
else,
  out=tmpmean;
end;

if (outpt),
  figure(1);
  plot([1:length(tmpy)],tmpy,'--',[1:length(out)],out,'-');
end;
