function cm=imCenterMass(im,mask)
% Usage ... cm=imCenterMass(im,mask)

if nargin<2, mask=ones(size(im)); end;
if max(mask(:))==1,
  maski=find(mask);

  [xx,yy]=meshgrid([1:size(im,1)],[1:size(im,2)]);
  xx=xx'; yy=yy';
  area=sum(im(maski));

  cm(1)=sum(im(maski).*xx(maski))/area;
  cm(2)=sum(im(maski).*yy(maski))/area;
else,
  [xx,yy]=meshgrid([1:size(im,1)],[1:size(im,2)]);
  xx=xx'; yy=yy';
  for nn=1:max(mask(:)),
    tmpmask=(mask==nn);
    maski=find(tmpmask);
    if ~isempty(maski),
      area=sum(im(maski));
      cm(mm,1)=sum(im(maski).*xx(maski))/area;
      cm(mm,2)=sum(im(maski).*yy(maski))/area;
    else,
      cm(mm,1)=nan;
      cm(mm,2)=nan;
    end;
  end;
end;



