function y=findRadius2(cropim,bii)
% Usage y=findRadius2(cropim,bii)
%

immin=min(min(cropim));

aa=[-30:5:30];
for mm=1:length(aa),
  tmpim=imrotate(cropim,aa(mm),'bilinear','crop');
  tmpim(find(tmpim<immin))=0;
  np=sum(tmpim>0);  
  proj(mm,:)=sum(tmpim)./np;
  [rr(mm,:),yr(mm,:),mse(mm)]=calcRadius2(proj(mm,:));
  plot(proj(mm,:)), aa(mm), pause,
end;

subplot(211)
plot(aa,mse)
subplot(212)
plot(aa,rr(:,1))

