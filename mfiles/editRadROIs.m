function [radnew,masksnew_all]=editRadROIs(rad,im,parms_cell)
% Usage ... function [radnew,masksnew_all]=editRadROIs(rad,im,parms_cell)

for mm=1:length(rad),
  [tmp1,tmpmsk1]=getRectImGrid(im,rad(mm));
  proj{mm}=mean(tmp1,2)';
  masks(:,:,mm)=tmpmsk1;
end;
masks_all=sum(masks,3)>0;

clf, im_overlay4(im,masks_all)
tmpin=input('Check individually and edit? [0=No, 1=Yes, 2=No&cont]: ');
if tmpin==1,
  for mm=1:length(rad),
    figure(1), clf, im_overlay4(im,masks(:,:,mm)), xlabel(num2str(mm)), drawnow,
    figure(2), clf, plot(proj{mm}), xlabel(num2str(mm)), drawnow,
    disp(sprintf(' displaying #%d, press enter for next...',mm));
    pause,
  end;
  tmpout=input('Enter ids to remove: ','s');
  if ~isempty(tmpout),
    tmpout=str2num(tmpout);
    tmpincl=[1:length(rad)];
    for mm=1:length(tmpout), tmpincl=tmpincl(find(tmpincl~=tmpout(mm))); end;
    radnew=rad(tmpincl);
  else,
    radnew=rad;
  end;
elseif tmpin==0,
  radnew=rad;
  masksnew_all=masks_all;
  return,
else,
  radnew=rad;
  masksnew_all=masks_all;    
end;

for mm=1:length(radnew),
  [tmp1,tmpmsk1]=getRectImGrid(im,radnew(mm));
  projnew{mm}=mean(tmp1,2)';
  masksnew(:,:,mm)=tmpmsk1;
end;
masksnew_all=sum(masks,3)>0;

clf, im_overlay4(im,masks_all)
tmpin=input('Add new? [0=No, 1=Yes]: ');
if tmpin,
  if exist('parms_cell'),
    [tmpmasks,tmprad]=manyRadROIs(im,parms_cell{1},parms_cell{2},parms_cell{3},parms_cell{4});  
  else,
    [tmpmasks,tmprad]=manyRadROIs(im,[],[],[],0);
  end;
  radnew(end+1:end+length(tmprad))=tmprad;
  for mm=1:length(radnew),
    [tmp1,tmpmsk1]=getRectImGrid(im,radnew(mm));
    projnew{mm}=mean(tmp1,2)';
    masksnew(:,:,mm)=tmpmsk1;
  end;
  masksnew_all=sum(masks,3)>0;
end;


  