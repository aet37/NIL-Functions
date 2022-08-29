function y=getMaskOverlap(mask,maskref)
% Usage ... y=getMaskOverlap(mask,maskref)
%
% returns the label index in maskref for which there are elements overlapping in mask
% actually a structure is returned with information about overlap and non-overlap
% y.n,y.ov,y.nov

cnt1=0; cnt2=0;
for mm=1:max(maskref(:)),
  tmpii=find(maskref==mm);
  yn(mm)=sum(mask(tmpii));
  if yn(mm)>0, 
    cnt1=cnt1+1; 
    y1(cnt1)=mm;
  else,
    cnt2=cnt2+1;
    y2(cnt2)=mm;
  end;
end;

y.n=yn;
y.ov=y1;
y.nov=y2;

