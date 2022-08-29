function maskLabel1_sup(im,mask,maski)
% Usage ... maskLabel1_sup(im,mask,maski)

tmpmask=double(mask>0);
for mm=1:max(mask(:)),
  tmpval=maski(mm,1);
  if (maski(mm,1)==1)&(maski(mm,2)==1), tmpval=3; end;
  if (maski(mm,1)==2)&(maski(mm,2)==1), tmpval=4; end;
  tmpmask(find(mask==mm))=tmpval;
end;

for mm=1:2,
  show(im), drawnow, pause(0.3),
  im_overlay4(im,tmpmask), drawnow, pause(0.3),
end;
title(sprintf('[%d %d]',min(tmpmask(:)),max(tmpmask(:))));


