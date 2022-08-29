function y=imlabeloverlap(im1,imref,otype)
% Usage ... y=imlabeloverlap(im1,imref)

for mm=1:max(imref(:)),
  tmpimref=(imref==mm);
  for nn=1:max(im1(:)),
    tmpim1=(im1==nn);
    tmpoverlap=(sum(sum(tmpimref&tmpim1)));
    yo(mm,nn)=tmpoverlap;
  end;
  y1maxi=find(yo(mm,:)==max(yo(mm,:)));
end;

y.overlap=yo;
y.refimax=y1maxi;

