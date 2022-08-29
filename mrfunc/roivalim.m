function [y,yr]=roivalim(roi,val)
% Usage ... y=roivalim(roi,val)

y=zeros(size(roi));
for mm=1:max(roi(:)),
  tmpii=find(roi==mm);
  if ~isempty(tmpii), y(tmpii)=val(mm); end;
end;
yr=[min(val)-0.1*(max(val)-min(val)) max(val)];

if nargout==0, 
  show(y,yr);
  clear y
end;

