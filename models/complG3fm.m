function y=complG3fm(x,tparms,xparms,parms2fit,data,wdata)
% Usage ... []=complG3fm(x,tparms,xparms,parms2fit,data,wdata)

ee2=[];
nex=size(data,1);
for mm=1:nex,
  xparms(mm,6)=x(end-nex+mm);
  yy(mm,:)=complG3f(x(1:end-nex),tparms,xparms(mm,:),parms2fit(1:end-nex));
  %xparms(mm,:),
  ee(mm,:)=yy(mm,:)-data(mm,:);
  ee(mm,:)=ee(mm,:).*wdata(mm,:);
  ee2=[ee2;ee(mm,:)/max(data(mm,:)-1)];
  %ee2=[ee2 ee(mm,:)];
end;
%keyboard,
y=ee2(find(ee2~=0));
[x sum(y.*y)/length(y)],
