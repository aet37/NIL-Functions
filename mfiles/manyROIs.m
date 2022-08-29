function [rois]=manyROIs(im,wlev)
% Usage ... rois=manyROIs(im,wlev)

if nargin==1, wlev=[min(min(im)) max(max(im))]; end;

cnt=1;
found=0;
while(~found),
  if (cnt==1),
    figure(1)
    show(im,wlev)
    drawnow,
    input(sprintf('  press enter to draw ROI #%d... ',cnt));
  else,
    disp(sprintf('  draw ROI #%d... ',cnt));
  end;
  roiok=0;
  while (~roiok),
    tmpmask=roipoly;
    show(im_super(im,tmpmask,0.1),wlev)
    drawnow,
    roiok=input(' roi ok? [0=no, 1=yes, 9=yes+exit]: ');
  end;
  %tmpedge=edge(double(tmpmask),'canny');
  rois(:,:,cnt)=tmpmask;
  %rois_edge(:,:,cnt)=tmpedge;
  if (roiok==9),
    found=1;
  end;
  figure(1)
  show(im_super(im,sum(rois,3)>0,0.1),wlev)
  drawnow,
  %figure(2)
  %show(im_super(im,sum(rois_edge,3),0.1),wlev)
  %drawnow,
  cnt=cnt+1;
end;


