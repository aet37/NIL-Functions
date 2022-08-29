function cm=imCenterMass(vol,mask)
% Usage ... cm=imCenterMass(vol,mask)
%
% mask can be labeled mask

if nargin<2, mask=ones(size(vol)); end;

[xx,yy,zz]=meshgrid([1:size(vol,1)]',[1:size(vol,2)]',[1:size(vol,3)]');
xx=xx; yy=yy; zz=zz;

for mm=1:max(mask(:)),
  maski=find(mask==mm);
  area=sum(vol(maski));

  cm(mm,1)=sum(vol(maski).*xx(maski))/area;
  cm(mm,2)=sum(vol(maski).*yy(maski))/area;
  cm(mm,3)=sum(vol(maski).*zz(maski))/area;
end;

