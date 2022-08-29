function y=myROIrefine1(rois,stk,mask,thr)
% Usage ... y=myROIrefine1(rois,stk,mask,thr)

verbose_flag=0;

smw=1;
if iscell(mask),
  for mm=1:length(mask), tmpmask(:,:,mm)=mask{mm}; end;
  clear mask
  mask=tmpmask;
  clear tmpmask
end;
if isempty(mask), mask=ones(size(rois)); end;

for mm=1:size(stk,3),
  tmpim=stk(:,:,mm);
  for nn=1:max(rois(:)), for oo=1:size(mask,3),
    tmpmask=(rois==nn)&(mask(:,:,oo));
    if sum(double(tmpmask(:)))<1, tmpmask=(rois==nn); end;
    roitc(mm,nn,oo)=mean(tmpim(find(tmpmask)));
  end; end;
end;

%if length(thr)>1, cthr=thr(2); thr=thr(1); else, cthr=4; end;

new_rois=zeros(size(rois));
for mm=1:max(rois(:)), for nn=1:size(mask,3),
  tmplab=(rois==mm)&(mask(:,:,nn));
  %sum(double(tmplab(:))),
  if sum(double(tmplab(:)))<1, 
    tmplab=(rois==mm); 
    tmplab2=mask(:,:,nn); 
    lthr=thr(2);
  else, 
    tmplab2=tmplab;
    lthr=thr(1);
  end;
  tmpcor=OIS_corr2(stk,roitc(:,mm,nn));
  tmpcors=im_smooth(tmpcor,smw);
  %tmpcorb=im_thr2(tmpcors.*(tmplab>0),thr,cthr);
  tmpthr=lthr*max(tmpcors(:).*(tmplab(:)>0));
  if verbose_flag,
    subplot(121), show(tmpcors), xlabel(sprintf('corr roi#%d mask#%d',mm,nn)),
    subplot(122), show(tmpcors>tmpthr), xlabel('corr thr based on roi'),
    drawnow, %pause,
  end;
  tmpcorb=(tmpcors>tmpthr).*(tmplab2>0);
  new_rois(find(tmpcorb))=mm;
  tmpnew(:,:,mm,nn)=tmpcorb.*tmpcors;
  if verbose_flag,
    subplot(121), show(tmplab2), xlabel('mask for roi'),
    subplot(122), show(tmpcorb), xlabel(sprintf('roi#%d mask#%d thr=%.2f',mm,nn,tmpthr)),
    drawnow, %pause,
  end;
end; end;

if nargout==0,
  clf, imagesc(new_rois), axis image, colorbar,
  return;
end;

y.roi=new_rois;
y.masks=tmpnew;

