function masks=commonMask(mask1,mask2,c2min)
% Usage ... masks=commonMask(mask1,mask2,c2min)

if nargin<3, c2min=0; end;

mask1lab=bwlabel(mask1>0);

mask1common=bwlabel((mask1>0)&(mask2>0));
mask1common1all=zeros(size(mask1));

mask1new=zeros(size(mask1));
mask1new2=zeros(size(mask1));
for mm=1:max(mask1lab(:)),
  if sum(sum((mask1lab==mm).*(mask2>0)))==0,
    mask1new(find(mask1lab==mm))=mm;
    mask1new2(find(mask1lab==mm))=mm;
   else,
    tmpii=find((mask1lab==mm)&(mask2==0));
    if ~isempty(tmpii), mask1new2(tmpii)=mm; end;
  end;
  if sum(sum((mask1lab==mm).*(mask1common>0)))>0,
    mask1common1all(find(mask1lab==mm))=mm;
  end;
end;
mask1new2=bwlabel(mask1new2>0);


if c2min>0,
  for mm=1:max(mask1new2(:)),
    if length(find(mask1new2==mm))<c2min,
      mask1new2(find(mask1new2==mm))=0;
    end;
  end;
  for mm=1:max(mask1common(:)),
    if length(find(mask1common==mm))<c2min,
      mask1common(find(mask1common==mm))=0;
    end;
  end;
end;

masks.unique1only=mask1new>0;
masks.unique1not2=mask1new2>0;
masks.common=mask1common>0;
masks.common1all=mask1common1all>0;

