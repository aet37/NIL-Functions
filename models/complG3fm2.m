function y=complG3fm(x,tparms,xparms,parms2fit,data,data2,wdata)
% Usage ... []=complG3fm(x,tparms,xparms,parms2fit,data,data2,wdata)

eee=[];
nex=size(data,1);
for mm=1:nex,
  xparms(mm,6)=x(end-nex+mm);
  aa=complG3f(x(1:end-nex),tparms,xparms(mm,:),parms2fit(1:end-nex));
  yy(mm,:)=aa(1,:); zz(mm,:)=aa(2,:);
  %xparms(mm,:),
  ee(mm,:)=yy(mm,:)-data(mm,:);   ee2(mm,:)=zz(mm,:)-data2(mm,:);
  ee(mm,:)=ee(mm,:).*wdata(mm,:); ee2(mm,:)=ee2(mm,:).*wdata(mm,:);
  eee=[eee ee(mm,:)/max(data(mm,:)-1) ee2(mm,:)/max(data2(mm,:)-1)];
  %ee2=[ee2 ee(mm,:)];
end;
y=eee(find(eee~=0));
[x sum(y.*y)/length(y)],
%keyboard,

